import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:movie_app/core/network/api_endpoints.dart';
import 'package:movie_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/core/movies/domain/repositories/movie_repository.dart';
import './splash_event.dart';
import './splash_state.dart';

/// Turns the splash screen from a fixed wait into a real one.
///
/// The screen used to hold for two seconds after its animation and then hand
/// over to a Home that had not started loading yet — so the user watched a
/// logo, then watched a spinner. This does the first request *during* the
/// animation instead, so Home opens with its carousel already drawn.
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc(this._movies, this._auth) : super(const SplashState()) {
    on<SplashStarted>((_, emit) => _start(emit));
  }

  final MovieRepository _movies;
  final AuthRepository _auth;

  /// ⚠️ Under Dio's 10s connect/receive budget, on purpose.
  ///
  /// This is the backstop for a connection that neither succeeds nor fails —
  /// a captive portal that accepts the socket and never answers. Without it
  /// the splash is exactly as long as the worst network in the room.
  static const Duration _maxWait = Duration(seconds: 8);

  Future<void> _start(Emitter<SplashState> emit) async {
    await _prewarm();

    if (isClosed) return;
    emit(state.copyWith(isReady: true, isSignedIn: _auth.currentUser != null));
  }

  /// Fetches what Home's carousel needs, so Home finds it already cached.
  ///
  /// ⚠️ These arguments must stay identical to `HomeBloc._loadFeatured`.
  /// `MovieRepositoryImpl` caches on a key built from them, so a mismatch
  /// would not break anything visibly — it would just silently make this
  /// request useless and put the spinner back. Both sides read the same
  /// `ApiEndpoints` constants so they cannot drift apart quietly.
  ///
  /// Only the carousel, not the genre rows: Home shows its loading view only
  /// while `featured` is empty, so the rows can keep filling in after the
  /// screen is up. Waiting for all of them here would make the splash slower,
  /// which is the thing being fixed.
  Future<void> _prewarm() async {
    try {
      await _movies
          .getMovies(
            sortBy: ApiEndpoints.sortByDownloads,
            minimumRating: ApiEndpoints.homeMinimumRating,
          )
          .timeout(_maxWait);
    } catch (_) {
      // Deliberately swallowed. This is a head start, not a gate — there is
      // nothing to report and nobody to report it to. Home runs the same
      // request again and owns showing the error if it really is broken.
    }
  }
}
