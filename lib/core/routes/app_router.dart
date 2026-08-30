import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'app_route_names.dart';

/// Single `switch` that maps a route name to its screen.
///
/// ⚠️ SHARED FILE — this is the one file every Sprint 1 task touches.
/// Add ONLY your own `case` and keep the list alphabetical-by-constant so two
/// people adding a route at the same time edit different lines.
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

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
