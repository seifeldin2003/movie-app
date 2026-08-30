import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// TASK: Register — Figma node `44:670`. UI + logic.
///
/// Steps:
///  1. Wrap the body in `BlocProvider(create: (_) => getIt<RegisterBloc>())`.
///  2. Fields per the design: name, email, password, confirm password, phone
///     number — plus the avatar picker strip at the top (node `285:100`; a
///     static row of avatars is fine for Sprint 1).
///  3. Reuse `AppTextField` and `PrimaryButton`.
///  4. Validation lives in the `Form` validators, not the Bloc — required
///     fields, email format, password ≥ 6 chars, and confirm == password.
///  5. `BlocConsumer`: navigate on [RegisterSuccess], SnackBar on
///     [RegisterFailure], `isLoading` into the button.
///  6. "Already Have Account ? Login" pops back to Login.
///  7. Dispose every controller.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Text('Register — TODO')),
    );
  }
}
