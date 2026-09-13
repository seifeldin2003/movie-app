import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/network/response_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temp;
  late ResponseCache cache;

  setUp(() {
    // A real directory rather than a faked path_provider: the point of these
    // tests is the file handling, so the files should be real.
    temp = Directory.systemTemp.createTempSync('response_cache_test');
    cache = ResponseCache(rootDirectory: () async => temp);
  });

  tearDown(() => temp.deleteSync(recursive: true));

  test('reads back exactly what was written', () async {
    await cache.write('/list_movies.json?page=1', {
      'movie_count': 2,
      'movies': [
        {'id': 1, 'title': 'Iron Man 3'},
      ],
    });

    final read = await cache.read('/list_movies.json?page=1');

    expect(read, isNotNull);
    expect(read!['movie_count'], 2);
    expect((read['movies'] as List).first['title'], 'Iron Man 3');
  });

  test('keeps different requests apart', () async {
    await cache.write('/list_movies.json?genre=action', {'movie_count': 1});
    await cache.write('/list_movies.json?genre=drama', {'movie_count': 2});

    expect(
      (await cache.read('/list_movies.json?genre=action'))!['movie_count'],
      1,
    );
    expect(
      (await cache.read('/list_movies.json?genre=drama'))!['movie_count'],
      2,
    );
  });

  test('a key never written reads as null, not an error', () async {
    expect(await cache.read('/never_asked.json'), isNull);
  });

  test('the newest write wins', () async {
    await cache.write('/list_movies.json', {'movie_count': 1});
    await cache.write('/list_movies.json', {'movie_count': 99});

    expect((await cache.read('/list_movies.json'))!['movie_count'], 99);
  });

  test('a corrupt file reads as null rather than throwing', () async {
    // ⚠️ The case that matters: a half-written file from a kill mid-write
    // must not take down a screen. Fail closed, quietly.
    await cache.write('/list_movies.json', {'movie_count': 1});

    final file = Directory(
      '${temp.path}/api_cache',
    ).listSync().whereType<File>().single;
    file.writeAsStringSync('{ this is not json');

    expect(await cache.read('/list_movies.json'), isNull);
  });
}
