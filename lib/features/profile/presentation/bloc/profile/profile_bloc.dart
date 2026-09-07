import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/bloc/request_status.dart';
import '../../../../auth/domain/repositories/auth_repository.dart';
import '../../../../history/domain/repositories/history_repository.dart';
import '../../../../movies/domain/entities/movie.dart';
import '../../../../watchlist/domain/repositories/watchlist_repository.dart';
import '../../../domain/repositories/user_profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// Drives the Profile tab.
///
/// The two lists are **live**, not fetched on each visit. Save a movie on
/// Details and it appears here immediately, even with Profile already built
/// behind it — which is what removed the `isActive` refresh flag this screen
/// used to need. A stale list is no longer a state the screen can reach.
///
/// Each subscription lives in its own event handler. `emit.forEach` keeps a
/// handler open for as long as the stream runs and cancels it when the Bloc
/// closes, so there is no `StreamSubscription` here to forget to dispose.
/// They are separate events because two `emit.forEach` calls cannot share one
/// handler — the first never returns.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._auth, this._profiles, this._watchlist, this._history)
    : super(const ProfileState()) {
    on<ProfileStarted>(_onStarted);
    on<ProfileRefreshed>((_, emit) => _loadProfile(emit));
    on<ProfileWatchlistSubscribed>(_onWatchlistSubscribed);
    on<ProfileHistorySubscribed>(_onHistorySubscribed);
  }

  final AuthRepository _auth;
  final UserProfileRepository _profiles;
  final WatchlistRepository _watchlist;
  final HistoryRepository _history;

  Future<void> _onStarted(
    ProfileStarted event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        watchListStatus: RequestStatus.loading,
        historyStatus: RequestStatus.loading,
        clearErrors: true,
      ),
    );

    add(const ProfileWatchlistSubscribed());
    add(const ProfileHistorySubscribed());

    await _loadProfile(emit);
  }

  Future<void> _onWatchlistSubscribed(
    ProfileWatchlistSubscribed event,
    Emitter<ProfileState> emit,
  ) {
    return emit.forEach<List<Movie>>(
      _watchlist.watch(),
      onData: (movies) => state.copyWith(
        watchListStatus: RequestStatus.success,
        watchList: movies,
        clearErrors: true,
      ),
      onError: (error, _) => state.copyWith(
        watchListStatus: RequestStatus.error,
        watchListError: error.toString(),
      ),
    );
  }

  Future<void> _onHistorySubscribed(
    ProfileHistorySubscribed event,
    Emitter<ProfileState> emit,
  ) {
    return emit.forEach<List<Movie>>(
      _history.watch(),
      onData: (movies) => state.copyWith(
        historyStatus: RequestStatus.success,
        history: movies,
      ),
      // History failing must not look like the watch list failing — it drops
      // to its empty state and the rest of the screen carries on.
      onError: (_, _) => state.copyWith(
        historyStatus: RequestStatus.success,
        history: const [],
      ),
    );
  }

  Future<void> _loadProfile(Emitter<ProfileState> emit) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final profile = await _profiles.load(uid);
      if (isClosed || profile == null) return;
      emit(state.copyWith(profile: profile));
    } catch (_) {
      // Deliberately swallowed: this only supplies the header avatar, and the
      // header has a default. Interrupting the screen over it would be worse
      // than the fallback illustration.
    }
  }
}
