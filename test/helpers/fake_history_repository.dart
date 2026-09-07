import 'dart:async';

import 'package:movie_app/features/history/domain/repositories/history_repository.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// Records what was viewed so a test can assert that opening a movie wrote an
/// entry, without depending on the real store.
class FakeHistoryRepository implements HistoryRepository {
  FakeHistoryRepository({List<Movie> viewed = const []})
    : _viewed = [...viewed];

  final List<Movie> _viewed;

  final StreamController<List<Movie>> _changes =
      StreamController<List<Movie>>.broadcast();

  /// When set, `record` throws — the case where writing history must not be
  /// allowed to take the Movie Details screen down with it.
  String? recordError;

  List<Movie> get viewed => List.unmodifiable(_viewed);

  @override
  Stream<List<Movie>> watch() async* {
    yield List.unmodifiable(_viewed);
    yield* _changes.stream;
  }

  @override
  Future<List<Movie>> load() async => List.unmodifiable(_viewed);

  @override
  Future<void> record(Movie movie) async {
    final error = recordError;
    if (error != null) throw error;

    _viewed.removeWhere((other) => other.id == movie.id);
    _viewed.insert(0, movie);
    _changes.add(List.unmodifiable(_viewed));
  }

  @override
  Future<void> clear() async {
    _viewed.clear();
    _changes.add(const []);
  }
}
