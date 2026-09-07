import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/request_status.dart';
import '../../../../movies/domain/entities/movie.dart';
import '../../../../movies/domain/entities/movie_details.dart';

/// One state object with two statuses, not one class per phase.
///
/// The screen fires two requests at once — `movie_details` and
/// `movie_suggestions` — and they finish at different times. A class per phase
/// cannot express "details loaded, suggestions still loading", because an
/// object has exactly one type. Two enums on one object can.
///
/// The payoff is one line: `emit(state.copyWith(similarStatus: loading))` does
/// not mention `details`, so the poster, cast and summary stay on screen while
/// the Similar row reloads underneath them.
class MovieDetailsState extends Equatable {
  const MovieDetailsState({
    this.detailsStatus = RequestStatus.initial,
    this.details,
    this.detailsError,
    this.similarStatus = RequestStatus.initial,
    this.similar = const [],
    this.similarError,
    this.isInWatchList = false,
    this.watchListError,
  });

  final RequestStatus detailsStatus;
  final MovieDetails? details;
  final String? detailsError;

  final RequestStatus similarStatus;
  final List<Movie> similar;
  final String? similarError;

  /// Whether this movie is saved. Lives on the state rather than in the
  /// screen so the control reflects what Firestore actually holds, not what
  /// was last tapped.
  final bool isInWatchList;

  /// Set when a save or unsave failed. The screen shows it once and the
  /// next toggle clears it — without that, silently rolling the bookmark
  /// back looks like the control simply refusing to work.
  final String? watchListError;

  /// [clearErrors] is the escape hatch `??` cannot provide: passing
  /// `detailsError: null` means "leave it alone", so without this a stale
  /// message survives the retry that fixed it and the screen keeps showing an
  /// error next to freshly loaded content.
  MovieDetailsState copyWith({
    RequestStatus? detailsStatus,
    MovieDetails? details,
    String? detailsError,
    RequestStatus? similarStatus,
    List<Movie>? similar,
    String? similarError,
    bool? isInWatchList,
    String? watchListError,
    bool clearErrors = false,
  }) => MovieDetailsState(
    detailsStatus: detailsStatus ?? this.detailsStatus,
    details: details ?? this.details,
    detailsError: clearErrors ? null : (detailsError ?? this.detailsError),
    similarStatus: similarStatus ?? this.similarStatus,
    similar: similar ?? this.similar,
    similarError: clearErrors ? null : (similarError ?? this.similarError),
    isInWatchList: isInWatchList ?? this.isInWatchList,
    watchListError: clearErrors
        ? null
        : (watchListError ?? this.watchListError),
  );

  @override
  List<Object?> get props => [
    detailsStatus,
    details,
    detailsError,
    similarStatus,
    similar,
    similarError,
    isInWatchList,
    watchListError,
  ];
}
