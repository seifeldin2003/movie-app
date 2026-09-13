import 'package:equatable/equatable.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => const [];
}

/// Load the header and open both live subscriptions.
class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

/// Re-read the header only.
///
/// The two lists are live, so nothing else needs refreshing — this exists for
/// coming back from Update Profile, where the avatar may have changed.
class ProfileRefreshed extends ProfileEvent {
  const ProfileRefreshed();
}

/// Starts listening to the watch list. Its handler stays open for the life of
/// the Bloc, which is what keeps the subscription alive.
class ProfileWatchlistSubscribed extends ProfileEvent {
  const ProfileWatchlistSubscribed();
}

/// Starts listening to the history.
class ProfileHistorySubscribed extends ProfileEvent {
  const ProfileHistorySubscribed();
}
