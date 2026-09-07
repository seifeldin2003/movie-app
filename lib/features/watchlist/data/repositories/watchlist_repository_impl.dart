import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/firestore_watchlist_datasource.dart';

/// Wires the [WatchlistRepository] contract to Firestore.
///
/// Reads the uid from [AuthRepository] rather than taking it as a parameter,
/// so no screen has to remember to pass it — and no screen can pass someone
/// else's.
class WatchlistRepositoryImpl implements WatchlistRepository {
  WatchlistRepositoryImpl(this._dataSource, this._auth);

  final FirestoreWatchlistDataSource _dataSource;
  final AuthRepository _auth;

  /// Signed out means an empty list, not an error — the bookmark control
  /// still has to render.
  String? get _uid => _auth.currentUser?.uid;

  @override
  Stream<List<Movie>> watch() {
    final uid = _uid;
    // Signed out is an empty list, not an error — and a stream that never
    // emits would leave Profile on its spinner forever.
    if (uid == null) return Stream.value(const []);
    return _dataSource.watch(uid);
  }

  @override
  Future<List<Movie>> load() async {
    final uid = _uid;
    if (uid == null) return const [];
    return _dataSource.load(uid);
  }

  @override
  Future<void> add(Movie movie) async {
    final uid = _uid;
    if (uid == null) return;
    await _dataSource.add(uid, movie);
  }

  @override
  Future<void> remove(int movieId) async {
    final uid = _uid;
    if (uid == null) return;
    await _dataSource.remove(uid, movieId);
  }

  @override
  Future<bool> contains(int movieId) async {
    final uid = _uid;
    if (uid == null) return false;
    return _dataSource.contains(uid, movieId);
  }
}
