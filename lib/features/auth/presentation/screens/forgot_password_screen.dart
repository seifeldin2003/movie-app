import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// TASK: Reset Password — Figma node `47:936`. UI + logic.
///
/// Steps:
///  1. Wrap the body in
///     `BlocProvider(create: (_) => getIt<ForgotPasswordBloc>())`.
///  2. AppBar with a back arrow + "Forget Password" title (node `44:732`).
///  3. The illustration, then one email field, then the "Verify Email" button.
///  4. Reuse `AppTextField` and `PrimaryButton`.
///  5. `BlocConsumer`: on [ForgotPasswordSuccess] show
///     `AppStrings.resetPasswordSent` and pop back to Login; on failure show a
///     SnackBar. Do NOT navigate away before the user sees the confirmation.
///  6. Dispose the controller.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Text('Forgot Password — TODO')),
    );
  }
}
