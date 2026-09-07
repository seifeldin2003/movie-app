import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/firestore_history_datasource.dart';

/// Wires [HistoryRepository] to the capped Firestore document.
///
/// Reads the uid from [AuthRepository] rather than taking it as a parameter,
/// so no screen has to remember to pass it — and none can pass someone else's.
class FirestoreHistoryRepository implements HistoryRepository {
  FirestoreHistoryRepository(this._dataSource, this._auth);

  final FirestoreHistoryDataSource _dataSource;
  final AuthRepository _auth;

  /// Signed out means an empty history, not an error.
  String? get _uid => _auth.currentUser?.uid;

  @override
  Stream<List<Movie>> watch() {
    final uid = _uid;
    // A stream that never emits would leave Profile on its spinner forever.
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
  Future<void> record(Movie movie) async {
    final uid = _uid;
    if (uid == null) return;
    await _dataSource.record(uid, movie);
  }

  @override
  Future<void> clear() async {
    final uid = _uid;
    if (uid == null) return;
    await _dataSource.clear(uid);
  }
}
