import '../../../movies/domain/entities/movie.dart';

/// Watch history — the movies this user has opened, newest first.
///
/// ⚠️ AGREED INTERFACE. Deliberately narrow so the store behind it can change
/// without touching a screen: it has already been in-memory and is now a
/// capped Firestore document.
abstract class HistoryRepository {
  /// A live view. Opening a movie makes it appear here immediately.
  Stream<List<Movie>> watch();

  Future<List<Movie>> load();

  /// Records a view. Opening the same movie twice moves it to the top rather
  /// than adding a second entry.
  Future<void> record(Movie movie);

  Future<void> clear();
}
