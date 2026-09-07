import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../movies/domain/entities/movie.dart';

/// The only file that talks to Firestore for watch history.
///
/// **One document, not a collection.** Everything lives in an `entries` array
/// at `users/{uid}/history/recent`.
///
/// A document per view would be the obvious shape and the wrong one: history
/// is written every time any movie is opened, so it would grow without bound
/// and need a cleanup job of its own. One capped document is a single write to
/// record, a single read to load, and a single listener for real time.
///
/// At roughly 200 bytes an entry a full [maxEntries] is about 20 KB, well
/// under Firestore's 1 MiB document limit.
class FirestoreHistoryDataSource {
  static const String _users = 'users';
  static const String _history = 'history';
  static const String _recent = 'recent';
  static const String _entries = 'entries';

  static const String _id = 'id';
  static const String _title = 'title';
  static const String _imdbCode = 'imdbCode';
  static const String _year = 'year';
  static const String _rating = 'rating';
  static const String _posterUrl = 'posterUrl';
  static const String _viewedAt = 'viewedAt';

  /// Newest first, oldest dropped past this.
  static const int maxEntries = 100;

  /// History is a convenience, not a record — an entry older than this is
  /// noise. Pruned on write *and* filtered on read, so nothing can outlive
  /// the window just because the app went unused for a week.
  static const Duration retention = Duration(days: 3);

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      FirebaseFirestore.instance
          .collection(_users)
          .doc(uid)
          .collection(_history)
          .doc(_recent);

  Stream<List<Movie>> watch(String uid) =>
      _doc(uid).snapshots().map((snapshot) => readEntries(snapshot.data(), DateTime.now()));

  Future<List<Movie>> load(String uid) async {
    try {
      return readEntries((await _doc(uid).get()).data(), DateTime.now());
    } on FirebaseException catch (e) {
      throw _readableMessage(e);
    }
  }

  /// Moves [movie] to the front of the list.
  ///
  /// Runs in a transaction rather than rewriting from a local copy: two views
  /// landing close together would otherwise each write the array they read at
  /// the start, and the second would silently erase the first.
  Future<void> record(String uid, Movie movie) async {
    try {
      final doc = _doc(uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(doc);
        transaction.set(doc, {
          _entries: mergeEntries(
            existing: rawEntries(snapshot.data()),
            movie: movie,
            now: DateTime.now(),
          ),
        });
      });
    } on FirebaseException catch (e) {
      throw _readableMessage(e);
    }
  }

  /// The array rules, kept pure so they can be tested without a Firebase app:
  /// dedupe by id, drop anything past [retention], newest first, capped at
  /// [maxEntries]. `Timestamp` is plain Dart, so nothing here touches a
  /// network.
  static List<Map<String, dynamic>> mergeEntries({
    required List<Map<String, dynamic>> existing,
    required Movie movie,
    required DateTime now,
  }) {
    final cutoff = now.subtract(retention);

    final kept = existing.where((entry) {
      // Re-watching moves a movie up rather than adding a second row.
      if (_intOf(entry[_id]) == movie.id) return false;
      final viewedAt = _dateOf(entry[_viewedAt]);
      return viewedAt != null && viewedAt.isAfter(cutoff);
    }).toList();

    final entries = [_toMap(movie, now), ...kept];

    return entries.length > maxEntries
        ? entries.sublist(0, maxEntries)
        : entries;
  }

  Future<void> clear(String uid) async {
    try {
      await _doc(uid).set({_entries: <Map<String, dynamic>>[]});
    } on FirebaseException catch (e) {
      throw _readableMessage(e);
    }
  }

  // Reading ------------------------------------------------------------------

  static List<Map<String, dynamic>> rawEntries(Map<String, dynamic>? data) {
    final entries = data?[_entries];
    if (entries is! List) return const [];
    return entries.whereType<Map<String, dynamic>>().toList();
  }

  /// Filters on the way out as well as pruning on the way in, so an entry
  /// cannot outlive [retention] just because nothing has been written since.
  static List<Movie> readEntries(Map<String, dynamic>? data, DateTime now) {
    final cutoff = now.subtract(retention);

    return rawEntries(data)
        .where((entry) {
          final viewedAt = _dateOf(entry[_viewedAt]);
          return viewedAt != null && viewedAt.isAfter(cutoff);
        })
        .map(_toMovie)
        .toList();
  }

  static Map<String, dynamic> _toMap(Movie movie, DateTime now) => {
    _id: movie.id,
    _title: movie.title,
    _imdbCode: movie.imdbCode,
    _year: movie.year,
    _rating: movie.rating,
    _posterUrl: movie.posterUrl,
    _viewedAt: Timestamp.fromDate(now),
  };

  static Movie _toMovie(Map<String, dynamic> entry) => Movie(
    id: _intOf(entry[_id]) ?? 0,
    title: entry[_title] as String? ?? 'Untitled',
    imdbCode: entry[_imdbCode] as String?,
    year: _intOf(entry[_year]),
    rating: (entry[_rating] as num?)?.toDouble(),
    posterUrl: entry[_posterUrl] as String?,
  );

  static int? _intOf(Object? value) => (value as num?)?.toInt();

  /// Entries written by an older build may carry no timestamp at all, and a
  /// `Timestamp` cast that throws here would take the whole list down.
  static DateTime? _dateOf(Object? value) =>
      value is Timestamp ? value.toDate() : null;

  String _readableMessage(FirebaseException e) {
    if (e.code == 'permission-denied') {
      return 'You do not have permission to do that. Please sign in again.';
    }
    if (e.code == 'unavailable') {
      return 'No internet connection. Check your network and try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
