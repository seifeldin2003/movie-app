import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/request_status.dart';
import '../../../../movies/domain/entities/movie.dart';
import '../../../domain/entities/user_profile.dart';

/// Three things load here and the screen shows one tab at a time, so each
/// needs to arrive on its own schedule.
///
/// [profile] has no status of its own on purpose: it only supplies the header
/// avatar, and if it fails the header falls back to the default illustration.
/// A status would imply the screen should react to that, and it should not.
class ProfileState extends Equatable {
  const ProfileState({
    this.profile,
    this.watchListStatus = RequestStatus.initial,
    this.watchList = const [],
    this.watchListError,
    this.historyStatus = RequestStatus.initial,
    this.history = const [],
  });

  final UserProfile? profile;

  final RequestStatus watchListStatus;
  final List<Movie> watchList;
  final String? watchListError;

  final RequestStatus historyStatus;
  final List<Movie> history;

  ProfileState copyWith({
    UserProfile? profile,
    RequestStatus? watchListStatus,
    List<Movie>? watchList,
    String? watchListError,
    RequestStatus? historyStatus,
    List<Movie>? history,
    bool clearErrors = false,
  }) => ProfileState(
    profile: profile ?? this.profile,
    watchListStatus: watchListStatus ?? this.watchListStatus,
    watchList: watchList ?? this.watchList,
    watchListError: clearErrors
        ? null
        : (watchListError ?? this.watchListError),
    historyStatus: historyStatus ?? this.historyStatus,
    history: history ?? this.history,
  );

  @override
  List<Object?> get props => [
    profile,
    watchListStatus,
    watchList,
    watchListError,
    historyStatus,
    history,
  ];
}
