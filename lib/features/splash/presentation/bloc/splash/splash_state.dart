import 'package:equatable/equatable.dart';

/// What the splash screen is waiting on.
///
/// Only two things matter to the screen: may it leave yet, and where to.
class SplashState extends Equatable {
  const SplashState({this.isReady = false, this.isSignedIn = false});

  /// True once the first catalogue request has settled — succeeded, failed, or
  /// run past its cap. The screen still will not navigate until the animation
  /// has also finished.
  final bool isReady;

  /// Read from the restored Firebase session, so someone already signed in
  /// lands in the app rather than back at onboarding.
  final bool isSignedIn;

  SplashState copyWith({bool? isReady, bool? isSignedIn}) => SplashState(
    isReady: isReady ?? this.isReady,
    isSignedIn: isSignedIn ?? this.isSignedIn,
  );

  @override
  List<Object?> get props => [isReady, isSignedIn];
}
