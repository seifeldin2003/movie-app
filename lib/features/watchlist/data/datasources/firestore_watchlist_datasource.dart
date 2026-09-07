import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../movies/domain/entities/movie.dart';

/// The only file that talks to Firestore for the watch list.
///
/// Stored at `users/{uid}/watchlist/{movieId}` — a subcollection rather than
/// an array on the user document, for two reasons:
///
/// - the user document already carries a base64 avatar, and appending a
///   growing list to it would push every profile read past a megabyte;
/// - a subcollection lets one movie be added or removed on its own, instead
///   of rewriting the whole array every time the bookmark is tapped.
///
/// The movie's display fields are copied in rather than stored as a bare id.
/// The alternative is one API call per saved movie every time Profile opens,
/// which is slow and fails entirely offline. A document like this is about
/// 350 bytes, so a thousand saved movies is 0.4 MB against a 1 GiB free tier.
class FirestoreWatchlistDataSource {
  static const String _users = 'users';
  static const String _watchlist = 'watchlist';

  // Exactly what a card draws, plus two that earn their place: `imdbCode` is
  // the cross-database join key, and `largePosterUrl` lets the Details hero
  // paint before the API answers. `genres` and `backgroundUrl` are
  // deliberately absent — nothing on a card uses them, and Details re-fetches
  // the full record anyway.
  static const String _id = 'id';
  static const String _title = 'title';
  static const String _imdbCode = 'imdbCode';
  static const String _year = 'year';
  static const String _rating = 'rating';
  static const String _posterUrl = 'posterUrl';
  static const String _largePosterUrl = 'largePosterUrl';
  static const String _savedAt = 'savedAt';

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      FirebaseFirestore.instance
          .collection(_users)
          .doc(uid)
          .collection(_watchlist);

  Query<Map<String, dynamic>> _ordered(String uid) =>
      _collection(uid).orderBy(_savedAt, descending: true);

  /// A live view of the saved movies, newest first.
  ///
  /// Profile listens to this instead of re-reading on every visit, so saving a
  /// movie on Details shows up here immediately — even if Profile is already
  /// built behind it. Idle listeners cost nothing; a change costs one read.
  Stream<List<Movie>> watch(String uid) {
    return _ordered(uid).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => _toMovie(doc.data())).toList(),
    );
  }

  Future<List<Movie>> load(String uid) async {
    try {
      final snapshot = await _ordered(uid).get();
      return snapshot.docs.map((doc) => _toMovie(doc.data())).toList();
    } on FirebaseException catch (e) {
      throw _readableMessage(e);
    }
  }

  Future<void> add(String uid, Movie movie) async {
    try {
      // The movie id is the document id, so saving twice overwrites rather
      // than creating a duplicate row.
      await _collection(uid).doc('${movie.id}').set({
        _id: movie.id,
        _title: movie.title,
        _imdbCode: movie.imdbCode,
        _year: movie.year,
        _rating: movie.rating,
        _posterUrl: movie.posterUrl,
        _largePosterUrl: movie.largePosterUrl,
        _savedAt: Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw _readableMessage(e);
    }
  }

  Future<void> remove(String uid, int movieId) async {
    try {
      await _collection(uid).doc('$movieId').delete();
    } on FirebaseException catch (e) {
      throw _readableMessage(e);
    }
  }

  Future<bool> contains(String uid, int movieId) async {
    try {
      final doc = await _collection(uid).doc('$movieId').get();
      return doc.exists;
    } on FirebaseException catch (e) {
      throw _readableMessage(e);
    }
  }

  /// Defaults every read: a document written by an older build of the app can
  /// be missing fields that exist now.
  Movie _toMovie(Map<String, dynamic> data) => Movie(
    id: (data[_id] as num?)?.toInt() ?? 0,
    title: data[_title] as String? ?? 'Untitled',
    imdbCode: data[_imdbCode] as String?,
    year: (data[_year] as num?)?.toInt(),
    rating: (data[_rating] as num?)?.toDouble(),
    posterUrl: data[_posterUrl] as String?,
    largePosterUrl: data[_largePosterUrl] as String?,
  );

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
