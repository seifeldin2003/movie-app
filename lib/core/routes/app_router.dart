import 'package:flutter/material.dart';

import 'package:movie_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:movie_app/features/auth/presentation/screens/login_screen.dart';
import 'package:movie_app/features/auth/presentation/screens/register_screen.dart';
import 'package:movie_app/features/layout/presentation/screens/layout_screen.dart';
import 'package:movie_app/features/movie_details/presentation/screens/movie_details_screen.dart';
import '../movies/domain/entities/movie.dart';
import 'package:movie_app/features/movie_details/trailer/domain/movie_trailer_args.dart';
import 'package:movie_app/features/movie_details/trailer/presentation/screens/movie_trailer_screen.dart';
import 'package:movie_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:movie_app/features/layout/profile/presentation/screens/update_profile_screen.dart';
import 'package:movie_app/features/splash/presentation/screens/splash_screen.dart';
import './app_route_names.dart';

/// Single `switch` that maps a route name to its screen.
///
/// ⚠️ SHARED FILE — this is the one file most tasks touch. Add ONLY your own
/// `case` and keep the order matching [AppRouteNames] so two people adding a
/// route at the same time edit different lines.
class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRouteNames.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case AppRouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRouteNames.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRouteNames.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case AppRouteNames.home:
        return MaterialPageRoute(builder: (_) => const LayoutScreen());

      case AppRouteNames.updateProfile:
        return MaterialPageRoute(builder: (_) => const UpdateProfileScreen());

      case AppRouteNames.movieDetails:
        // The tapped movie travels as the route argument. Checking the type
        // rather than casting means a caller that passes the wrong thing gets
        // the unknown-route screen instead of a crash.
        final movie = settings.arguments;
        if (movie is! Movie) return _unknownRoute(settings);
        return MaterialPageRoute(
          // Kept so the screen can re-push itself by name when the user taps
          // through the Similar grid.
          settings: settings,
          builder: (_) => MovieDetailsScreen(movie: movie),
        );

      case AppRouteNames.movieTrailer:
        // Same guard as movieDetails: a typed argument, checked rather than
        // cast, so a wrong caller lands on the unknown-route screen.
        final args = settings.arguments;
        if (args is! MovieTrailerArgs) return _unknownRoute(settings);
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MovieTrailerScreen(args: args),
        );

      default:
        return _unknownRoute(settings);
    }
  }

  static Route<dynamic> _unknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    );
  }
}
