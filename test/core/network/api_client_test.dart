import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/network/api_client.dart';
import 'package:movie_app/core/network/api_exception.dart';
import 'package:movie_app/core/network/network_status.dart';
import 'package:movie_app/core/network/response_cache.dart';

/// Answers every GET from a script instead of the network, so these tests are
/// offline, fast and deterministic.
class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.respond);

  /// Given the request, either return a body or throw.
  final Object Function(RequestOptions options) respond;

  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    final result = respond(options);
    if (result is DioException) throw result;
    return ResponseBody.fromString(
      result as String,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temp;
  late ResponseCache cache;
  late NetworkStatus status;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('api_client_test');
    cache = ResponseCache(rootDirectory: () async => temp);
    status = NetworkStatus();
  });

  tearDown(() => temp.deleteSync(recursive: true));

  ApiClient clientThat(Object Function(RequestOptions) respond) {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _ScriptedAdapter(respond);
    return ApiClient(dio: dio, cache: cache, status: status);
  }

  const okBody = '{"status":"ok","data":{"movie_count":2}}';

  /// ⚠️ `ApiClient` writes the cache without awaiting it, so the caller is not
  /// held up by a disk write. That makes "fetch, then read it back" a race in
  /// a test. Waiting for the entry to actually appear is what keeps these
  /// deterministic instead of passing on timing luck.
  Future<void> cached(String key) async {
    for (var i = 0; i < 50; i++) {
      if (await cache.read(key) != null) return;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    fail('nothing was cached for "$key" after 500ms');
  }

  DioException offline(RequestOptions options) => DioException(
    requestOptions: options,
    type: DioExceptionType.connectionError,
  );

  group('online', () {
    test('unwraps data and reports the app as online', () async {
      final client = clientThat((_) => okBody);

      final data = await client.get('/list_movies.json');

      expect(data['movie_count'], 2);
      expect(status.isOffline, isFalse);
    });

    test(
      'a success clears an offline flag left by an earlier failure',
      () async {
        status.report(isOffline: true);
        final client = clientThat((_) => okBody);

        await client.get('/list_movies.json');

        expect(status.isOffline, isFalse);
      },
    );
  });

  group('offline', () {
    test('serves the last real response and flags offline', () async {
      // One good call to fill the cache...
      await clientThat((_) => okBody).get('/list_movies.json');
      await cached('/list_movies.json');

      // ...then the network goes away.
      final data = await clientThat(offline).get('/list_movies.json');

      expect(data['movie_count'], 2, reason: 'should come from the cache');
      expect(status.isOffline, isTrue);
    });

    test('query parameters are part of the identity', () async {
      await clientThat(
        (_) => '{"status":"ok","data":{"movie_count":7}}',
      ).get('/list_movies.json', queryParameters: {'genre': 'action'});
      await cached('/list_movies.json?genre=action');

      final offlineClient = clientThat(offline);

      // The cached request comes back...
      final action = await offlineClient.get(
        '/list_movies.json',
        queryParameters: {'genre': 'action'},
      );
      expect(action['movie_count'], 7);

      // ...a different one was never cached, so it must still fail.
      expect(
        () => offlineClient.get(
          '/list_movies.json',
          queryParameters: {'genre': 'drama'},
        ),
        throwsA(isA<ApiException>()),
      );
    });

    test('parameter order does not split the cache entry', () async {
      await clientThat((_) => okBody).get(
        '/list_movies.json',
        queryParameters: {'genre': 'action', 'page': 1},
      );
      await cached('/list_movies.json?genre=action&page=1');

      // Same request, written the other way round. Without sorting the key
      // this would miss and throw.
      final data = await clientThat(offline).get(
        '/list_movies.json',
        queryParameters: {'page': 1, 'genre': 'action'},
      );

      expect(data['movie_count'], 2);
    });

    test(
      'with nothing cached it still fails, rather than inventing data',
      () async {
        expect(
          () => clientThat(offline).get('/list_movies.json'),
          throwsA(
            isA<ApiException>().having(
              (e) => e.isConnectionIssue,
              'isConnectionIssue',
              isTrue,
            ),
          ),
        );
      },
    );
  });

  group('real answers are not papered over', () {
    test('a 404 rethrows and does not read the cache', () async {
      // Cache a good response first, so if the 404 path wrongly fell back
      // there would be something for it to wrongly return.
      await clientThat((_) => okBody).get('/list_movies.json');
      await cached('/list_movies.json');

      final client = clientThat(
        (options) => DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: 404,
            data: const {'status_message': 'Movie not found'},
          ),
        ),
      );

      // ⚠️ The distinction the whole design rests on: a 404 is the server
      // answering. Showing yesterday's catalogue instead would be a lie.
      await expectLater(
        client.get('/list_movies.json'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Movie not found')
              .having((e) => e.isConnectionIssue, 'isConnectionIssue', isFalse),
        ),
      );
      expect(status.isOffline, isFalse, reason: 'a 404 is not being offline');
    });

    test('a YTS in-body failure on a 200 is not cached', () async {
      final client = clientThat(
        (_) => '{"status":"error","status_message":"Bad parameter"}',
      );

      await expectLater(
        client.get('/list_movies.json'),
        throwsA(isA<ApiException>()),
      );
      expect(await cache.read('/list_movies.json'), isNull);
    });
  });
}
