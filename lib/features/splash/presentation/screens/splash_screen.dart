import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:movie_app/core/constants/app_assets.dart';
import 'package:movie_app/core/constants/app_strings.dart';
import 'package:movie_app/core/di/injector.dart';
import 'package:movie_app/core/routes/app_route_names.dart';
import 'package:movie_app/core/theme/app_text_styles.dart';
import '../bloc/splash/splash_bloc.dart';
import '../bloc/splash/splash_event.dart';
import '../bloc/splash/splash_state.dart';

/// First screen the app shows. Figma node 29:431.
///
/// Leaves when **two** things are true: the credit line has finished animating,
/// and the app has something to show. The second one used to be a flat
/// two-second timer that waited on nothing, so Home arrived without its data
/// and put a spinner up immediately — the wait was real, it just happened in
/// the wrong place. [SplashBloc] does that first request here instead.
///
/// Stateful on purpose: navigation has to be cancellable. Firing it from a
/// callback that outlives the widget throws on a dead context.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashBloc>(
      // `create` runs once, not per rebuild — this is what replaces initState
      // for kicking off the first load.
      create: (_) => getIt<SplashBloc>()..add(const SplashStarted()),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView> {
  bool _animationDone = false;
  bool _hasNavigated = false;

  /// Called from both gates. Whichever finishes second is the one that moves.
  void _goWhenReady(SplashState state) {
    // ⚠️ Both callers can fire after the first navigation — `onFinish` runs on
    // a frame callback and the Bloc can emit again. Without this guard the
    // second one pushes a duplicate route onto a dead context.
    if (_hasNavigated || !_animationDone || !state.isReady) return;
    if (!mounted) return;

    _hasNavigated = true;
    Navigator.pushReplacementNamed(
      context,
      state.isSignedIn ? AppRouteNames.home : AppRouteNames.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) => _goWhenReady(state),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Center(
                child: ZoomIn(
                  duration: const Duration(seconds: 1),
                  child: Image.asset(AppAssets.logo, width: 121.w),
                ),
              ),
              const Spacer(),
              ZoomIn(child: Image.asset(AppAssets.routeGold, width: 180.w)),
              SizedBox(height: 8.h),
              FadeInUpBig(
                duration: const Duration(seconds: 2),
                // Runs once the animation completes, not on every rebuild.
                // The request may well have landed before this does, which is
                // the point: the network gets the animation for free.
                onFinish: (_) {
                  _animationDone = true;
                  _goWhenReady(context.read<SplashBloc>().state);
                },
                child: Center(
                  child: Text(
                    AppStrings.supervisedBy,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
