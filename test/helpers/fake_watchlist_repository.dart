import 'dart:async';

import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/watchlist/domain/repositories/watchlist_repository.dart';

/// An in-memory watch list, so nothing touches Firestore.
class FakeWatchlistRepository implements WatchlistRepository {
  FakeWatchlistRepository({List<Movie> saved = const [], this.error})
    : _saved = [...saved];

  final List<Movie> _saved;

  /// Broadcast, and seeded on listen, so a subscriber attaching after a write
  /// still sees the current list instead of waiting for the next change.
  final StreamController<List<Movie>> _changes =
      StreamController<List<Movie>>.broadcast();

  /// Pushes a list as if Firestore had. Lets a test prove the screen repaints
  /// on its own, with no refresh event anywhere.
  void emit(List<Movie> movies) {
    _saved
      ..clear()
      ..addAll(movies);
    _changes.add(List.unmodifiable(_saved));
  }

  /// When set, every write throws — the case where the bookmark has to roll
  /// back rather than lie about having saved something.
  final String? error;

  @override
  Stream<List<Movie>> watch() async* {
    yield List.unmodifiable(_saved);
    yield* _changes.stream;
  }

  @override
  Future<List<Movie>> load() async => List.unmodifiable(_saved);

  @override
  Future<void> add(Movie movie) async {
    if (error != null) throw error!;
    _saved.insert(0, movie);
    _changes.add(List.unmodifiable(_saved));
  }

  @override
  Future<void> remove(int movieId) async {
    if (error != null) throw error!;
    _saved.removeWhere((movie) => movie.id == movieId);
    _changes.add(List.unmodifiable(_saved));
  }

  @override
  Future<bool> contains(int movieId) async =>
      _saved.any((movie) => movie.id == movieId);
}
