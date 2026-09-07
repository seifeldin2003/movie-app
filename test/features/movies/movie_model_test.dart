import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/movies/data/models/movie_details_model.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';

/// Parsed against the real responses bundled in `assets/data/`, captured with
/// `curl` from the live API — not against invented JSON. A model that only
/// ever sees hand-written fixtures agrees with whatever the author assumed.
void main() {
  // Without this a plain `test` has no Flutter binding, so HTTP is NOT mocked
  // and anything that reaches the network hits the live API for real.
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> readData(String name) {
    final body = jsonDecode(File('assets/data/$name.json').readAsStringSync());
    return (body as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  group('MovieModel against the real list_movies response', () {
    test('parses the catalogue', () {
      final movies = MovieModel.listFrom(readData('list_movies'));

      expect(movies, hasLength(20));

      final first = movies.first.toEntity();
      expect(first.title, isNotEmpty);
      expect(first.id, greaterThan(0));
      expect(first.posterUrl, startsWith('http'));
      expect(first.backgroundUrl, startsWith('http'));
      expect(first.genres, isNotEmpty);
    });

    test('every row carries an imdb code', () {
      // The join key for any second API. If this ever fails, the plan to key
      // off imdb codes has quietly stopped working.
      final movies = MovieModel.listFrom(readData('list_movies'));

      expect(
        movies.map((movie) => movie.toEntity().imdbCode),
        everyElement(startsWith('tt')),
      );
    });

    test('suggestions carry an imdb code too', () {
      // Worth its own test: the suggestions *request* is numeric-only, which
      // is easy to mistake for the response lacking the code as well. It does
      // not — so a suggestion can be handed to any imdb-keyed service.
      final movies = MovieModel.listFrom(readData('movie_suggestions'));

      expect(movies, hasLength(4));
      expect(
        movies.map((movie) => movie.toEntity().imdbCode),
        everyElement(startsWith('tt')),
      );
    });
  });

  group('MovieModel edge cases', () {
    test('a no-results search returns an empty list, not a crash', () {
      // ⚠️ THE ONE THAT BITES. On zero matches YTS drops the `movies` key
      // entirely rather than sending an empty array, so `data['movies'] as
      // List` throws the first time anyone searches for something that does
      // not exist.
      final data = <String, dynamic>{
        'movie_count': 0,
        'limit': 20,
        'page_number': 1,
      };

      expect(MovieModel.listFrom(data), isEmpty);
    });

    test('reads a rating whether it arrives as an int or a double', () {
      // The same key is `8` on one record and `8.4` on the next. Reading it
      // as `double?` works until it meets a whole number.
      expect(MovieModel.fromJson({'rating': 8}).toEntity().rating, 8.0);
      expect(MovieModel.fromJson({'rating': 8.4}).toEntity().rating, 8.4);
      expect(MovieModel.fromJson({'rating': '7.5'}).toEntity().rating, 7.5);
      expect(MovieModel.fromJson({}).toEntity().rating, isNull);
    });

    test('an empty object still produces a usable entity', () {
      final movie = MovieModel.fromJson(const {}).toEntity();

      expect(movie.id, 0);
      expect(movie.title, 'Untitled');
      expect(movie.genres, isEmpty);
    });
  });

  group('MovieDetailsModel against the real movie_details response', () {
    test('parses cast, stills and the fields only this endpoint has', () {
      final model = MovieDetailsModel.from(readData('movie_details'));
      expect(model, isNotNull);

      final details = model!.toEntity();

      expect(details.cast, hasLength(4));
      expect(details.cast.first.name, isNotEmpty);
      expect(details.cast.first.imageUrl, startsWith('http'));

      // Three numbered keys collected into one list.
      expect(details.screenshots, hasLength(3));
      expect(details.screenshots, everyElement(startsWith('http')));

      // `like_count` exists only here — this is the heart figure in the
      // design, and reading it off a list row would always give null.
      expect(details.likeCount, greaterThan(0));

      expect(details.mpaRating, isNotEmpty);
      expect(details.runtimeMinutes, greaterThan(0));
      expect(details.ytTrailerCode, isNotEmpty);
      expect(details.movie.imdbCode, startsWith('tt'));
    });

    test('falls back to description_intro when there is no summary', () {
      // This endpoint has no `summary` or `synopsis` key at all — parsing it
      // with the list model gives a blank page rather than an error.
      final details = MovieDetailsModel.fromJson({
        'id': 10,
        'title': 'Thirteen',
        'description_intro': 'A short blurb.',
      }).toEntity();

      expect(details.movie.summary, 'A short blurb.');
      expect(details.descriptionFull, 'A short blurb.');
    });

    test('survives a record with no cast and no stills', () {
      // The shape returned without `with_cast` / `with_images`: those keys are
      // absent, not empty, so the parse must treat their absence as ordinary.
      final details = MovieDetailsModel.fromJson({
        'id': 10,
        'title': 'Thirteen',
      }).toEntity();

      expect(details.cast, isEmpty);
      expect(details.screenshots, isEmpty);
      expect(details.likeCount, isNull);
      expect(details.similar, isEmpty);
    });

    test('collects however many stills the record actually has', () {
      final details = MovieDetailsModel.fromJson({
        'id': 10,
        'title': 'Thirteen',
        'medium_screenshot_image1': 'https://example.test/1.jpg',
        // No 2.
        'medium_screenshot_image3': 'https://example.test/3.jpg',
      }).toEntity();

      expect(details.screenshots, hasLength(2));
    });

    test('a data object with no movie key returns null', () {
      expect(MovieDetailsModel.from(const {}), isNull);
    });
  });
}
