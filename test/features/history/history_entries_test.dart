import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/features/history/data/datasources/firestore_history_datasource.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// The array rules behind the single history document, driven directly.
///
/// No Firebase app is stood up: `mergeEntries` and `readEntries` are pure, and
/// `Timestamp` is plain Dart. That is the reason they were pulled out of the
/// transaction — the interesting logic is testable without a network.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final now = DateTime(2026, 9, 7, 12);

  Map<String, dynamic> entry(int id, {required Duration age}) => {
    'id': id,
    'title': 'Movie $id',
    'viewedAt': Timestamp.fromDate(now.subtract(age)),
  };

  const movie = Movie(id: 99, title: 'Just Opened');

  group('mergeEntries', () {
    test('puts the movie just opened at the front', () {
      final merged = FirestoreHistoryDataSource.mergeEntries(
        existing: [entry(1, age: const Duration(hours: 1))],
        movie: movie,
        now: now,
      );

      expect(merged.first['id'], movie.id);
      expect(merged, hasLength(2));
    });

    test('re-opening a movie moves it up instead of duplicating it', () {
      final merged = FirestoreHistoryDataSource.mergeEntries(
        existing: [
          entry(1, age: const Duration(hours: 1)),
          entry(movie.id, age: const Duration(hours: 5)),
        ],
        movie: movie,
        now: now,
      );

      expect(merged.first['id'], movie.id);
      expect(merged.where((e) => e['id'] == movie.id), hasLength(1));
    });

    test('drops entries past the retention window', () {
      // Three days is the window, so two days survives and four does not.
      final merged = FirestoreHistoryDataSource.mergeEntries(
        existing: [
          entry(1, age: const Duration(days: 2)),
          entry(2, age: const Duration(days: 4)),
        ],
        movie: movie,
        now: now,
      );

      expect(merged.map((e) => e['id']), [movie.id, 1]);
    });

    test('drops an entry with no timestamp rather than keeping it forever', () {
      // Written by an older build. Without a date there is no way to expire
      // it, so it would otherwise sit at the bottom of the list for good.
      final merged = FirestoreHistoryDataSource.mergeEntries(
        existing: [
          {'id': 7, 'title': 'No timestamp'},
        ],
        movie: movie,
        now: now,
      );

      expect(merged.map((e) => e['id']), [movie.id]);
    });

    test('caps the array, dropping the oldest', () {
      const cap = FirestoreHistoryDataSource.maxEntries;

      // A full document, ordered newest (id 0) to oldest (id cap - 1). The
      // new movie uses an id none of them holds, so nothing is deduped and
      // the cap is the only thing under test.
      final existing = [
        for (var i = 0; i < cap; i++) entry(i, age: Duration(minutes: i)),
      ];

      final merged = FirestoreHistoryDataSource.mergeEntries(
        existing: existing,
        movie: const Movie(id: 12345, title: 'Brand New'),
        now: now,
      );

      expect(merged, hasLength(cap));
      expect(merged.first['id'], 12345);
      // The oldest fell off the end, rather than the newest failing to land.
      expect(merged.last['id'], cap - 2);
      expect(merged.map((e) => e['id']), isNot(contains(cap - 1)));
    });
  });

  group('readEntries', () {
    test('filters on read as well, not only on write', () {
      // An entry cannot outlive the window just because nothing has been
      // written since — the app can sit unused for a week.
      final movies = FirestoreHistoryDataSource.readEntries({
        'entries': [
          entry(1, age: const Duration(days: 1)),
          entry(2, age: const Duration(days: 9)),
        ],
      }, now);

      expect(movies.map((m) => m.id), [1]);
    });

    test('a missing or malformed document reads as empty, not a crash', () {
      expect(FirestoreHistoryDataSource.readEntries(null, now), isEmpty);
      expect(FirestoreHistoryDataSource.readEntries(const {}, now), isEmpty);
      expect(
        FirestoreHistoryDataSource.readEntries(
          const {'entries': 'not a list'},
          now,
        ),
        isEmpty,
      );
    });
  });
}
