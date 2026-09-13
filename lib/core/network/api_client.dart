import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import './api_endpoints.dart';
import './api_exception.dart';
import './network_status.dart';
import './response_cache.dart';

/// The single Dio instance for the whole app.
///
/// Registered as a lazy singleton in `core/di/injector.dart`. Data sources
/// take one of these; nothing above the data layer imports Dio at all.
class ApiClient {
  ApiClient({Dio? dio, ResponseCache? cache, this.status})
    : dio = dio ?? _build(),
      cache = cache ?? const ResponseCache();

  final Dio dio;

  /// The last real response for each request, so a later cold start with no
  /// connection shows what this user actually browsed rather than the bundled
  /// demo snapshot.
  final ResponseCache cache;

  /// Nullable so a test can build a client without one. In the app it is
  /// always injected.
  final NetworkStatus? status;

  static Dio _build() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        // Short on purpose. The default is no timeout at all, so a dead
        // mirror leaves the user watching a spinner for a minute before the
        // offline fallback gets a chance to fire. The failure path has to be
        // fast to be worth having.
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        responseType: ResponseType.json,
      ),
    );

    if (kDebugMode) {
      // Debug only — this prints every payload, and a release build should
      // not be writing 77k-movie responses to the device log.
      dio.interceptors.add(
        LogInterceptor(requestBody: false, responseBody: false),
      );
    }

    return dio;
  }

  /// Runs a GET and hands back the decoded `data` object.
  ///
  /// Every YTS response is `{status, status_message, data, @meta}`, so
  /// unwrapping once here keeps `data['data']` out of every call site.
  /// Throws [ApiException] and nothing else.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final key = _cacheKey(path, queryParameters);

    try {
      final response = await dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );

      final body = response.data;
      if (body is! Map<String, dynamic>) {
        // A mirror that has been replaced by a landing page answers 200 with
        // HTML. Without this the cast below would throw somewhere far away.
        throw const ApiException(
          'The movie service returned an unexpected response.',
        );
      }

      // YTS reports its own failures in the body with a 200 status code, so
      // `response.statusCode == 200` is not enough on its own.
      if (body['status'] != 'ok') {
        throw ApiException(ApiException.readableBody(body));
      }

      final data = body['data'];
      final unwrapped = data is Map<String, dynamic>
          ? data
          : const <String, dynamic>{};

      // The request landed, so the app is online whatever it landed with.
      status?.report(isOffline: false);
      // Not awaited: the caller has the live response already and should not
      // wait on a disk write to render it.
      unawaited(cache.write(key, unwrapped));

      return unwrapped;
    } on DioException catch (error) {
      final failure = ApiException.from(error);
      if (!failure.isConnectionIssue) throw failure;

      status?.report(isOffline: true);

      // ⚠️ Connection failures only. A 404 or a rejected parameter is a real
      // answer, and serving yesterday's response instead would be a lie — the
      // same rule `MovieRepositoryImpl` already applies to the bundled
      // snapshot.
      final cached = await cache.read(key);
      if (cached != null) return cached;

      throw failure;
    }
  }

  /// Identifies a request by everything that changes its response.
  ///
  /// Query parameters are sorted because `{a, b}` and `{b, a}` are the same
  /// request, and an unsorted key would cache it twice and serve whichever
  /// happened to be written last.
  static String _cacheKey(String path, Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) return path;

    final pairs = query.entries.map((e) => '${e.key}=${e.value}').toList()
      ..sort();
    return '$path?${pairs.join('&')}';
  }
}
