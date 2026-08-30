import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// TASK: Login — Figma node `44:444`. UI + logic.
///
/// Steps:
///  1. Wrap the body in `BlocProvider(create: (_) => getIt<LoginBloc>())`.
///  2. Layout top to bottom: logo, email field, password field (with the
///     eye-off toggle, node `44:642`), "Forget Password ?" link →
///     `AppRouteNames.forgotPassword`, gold Login button, "Don't Have Account ?
///     Create One" → `AppRouteNames.register`, OR divider, Google button.
///  3. Reuse `AppTextField` and `PrimaryButton` — do not restyle a raw
///     `TextFormField` or `ElevatedButton` here.
///  4. Wrap the fields in a `Form` with a `GlobalKey<FormState>`; validate
///     before dispatching `LoginSubmitted`.
///  5. Use `BlocConsumer`: `listener` navigates on [LoginSuccess] and shows a
///     SnackBar on [LoginFailure]; `builder` feeds `isLoading` into
///     `PrimaryButton`.
///  6. On success `pushNamedAndRemoveUntil` to home so Back can't return here.
///  7. Dispose both `TextEditingController`s.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Text('Login — TODO')),
    );
  }
}
