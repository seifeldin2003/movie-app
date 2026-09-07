import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_endpoints.dart';
import 'api_exception.dart';

/// The single Dio instance for the whole app.
///
/// Registered as a lazy singleton in `core/di/injector.dart`. Data sources
/// take one of these; nothing above the data layer imports Dio at all.
class ApiClient {
  ApiClient({Dio? dio}) : dio = dio ?? _build();

  final Dio dio;

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
      return data is Map<String, dynamic> ? data : const {};
    } on DioException catch (error) {
      throw ApiException.from(error);
    }
  }
}
