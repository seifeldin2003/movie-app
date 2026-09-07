import 'dart:async';

import '../../../movies/domain/entities/movie.dart';
import '../../domain/repositories/history_repository.dart';

/// History for the current session only.
///
/// ⚠️ NOT THE APP'S STORE ANY MORE — `FirestoreHistoryRepository` is. This is
/// kept because it is exactly the right test double: same contract, no
/// network, no Firebase to stand up.
///
/// It is also the reference for what the contract has to do, which is why it
/// is not deleted.
class InMemoryHistoryRepository implements HistoryRepository {
  final List<Movie> _viewed = [];

  /// Broadcast so more than one listener can attach, and seeded on listen so
  /// a late subscriber still gets the current list rather than waiting for
  /// the next change.
  final StreamController<List<Movie>> _changes =
      StreamController<List<Movie>>.broadcast();

  /// Enough to fill the Profile grid several times over. Unbounded, a long
  /// session would keep every movie ever opened alive in memory.
  static const int maxEntries = 50;

  @override
  Stream<List<Movie>> watch() async* {
    yield List.unmodifiable(_viewed);
    yield* _changes.stream;
  }

  @override
  Future<List<Movie>> load() async => List.unmodifiable(_viewed);

  @override
  Future<void> record(Movie movie) async {
    // Remove first, then insert at the front: re-watching something should
    // move it up the list, not add a duplicate row.
    _viewed.removeWhere((other) => other.id == movie.id);
    _viewed.insert(0, movie);

    if (_viewed.length > maxEntries) {
      _viewed.removeRange(maxEntries, _viewed.length);
    }
    _changes.add(List.unmodifiable(_viewed));
  }

  @override
  Future<void> clear() async {
    _viewed.clear();
    _changes.add(const []);
  }
}
