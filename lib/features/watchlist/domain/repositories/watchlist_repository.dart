import '../../../movies/domain/entities/movie.dart';

/// The saved-movies contract.
///
/// ⚠️ AGREED INTERFACE — same rule as `AuthRepository` and `MovieRepository`:
/// adding a method is fine, changing a signature breaks whoever is wiring a
/// screen against it.
///
/// Implementations throw a readable sentence, never a Firebase code.
abstract class WatchlistRepository {
  /// A live view of the saved movies, newest first.
  ///
  /// Profile watches this rather than re-reading each time its tab is opened,
  /// so a movie saved on Details appears immediately and a list left open in
  /// the background can never go stale.
  Stream<List<Movie>> watch();

  /// A one-off read of the same list.
  Future<List<Movie>> load();

  Future<void> add(Movie movie);

  Future<void> remove(int movieId);

  /// Whether [movieId] is saved. Used to set the bookmark control's initial
  /// state on Movie Details.
  Future<bool> contains(int movieId);
}
