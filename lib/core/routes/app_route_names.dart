/// Route names. Never type a route string at a call site — use these.
class AppRouteNames {
  const AppRouteNames._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Sprint 2 — kept here so nobody invents a different spelling later.
  static const String home = '/home';
  static const String movieDetails = '/movie-details';
  static const String updateProfile = '/update-profile';
}
