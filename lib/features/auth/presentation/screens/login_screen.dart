import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/or_divider.dart';
import '../widgets/password_text_field.dart';

/// Login screen. Figma node 44:444.
///
/// Phase 1 is UI only — the form validates, but submitting is wired to
/// `LoginBloc` in Phase 2. The TODOs below mark the two call sites.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (!_formKey.currentState!.validate()) return;

    // Phase 1 has no auth yet, so a valid form goes straight to the app shell
    // — without this the Home screen would be unreachable for review.
    // TODO(phase-2): replace with a LoginSubmitted event and navigate from
    // the Bloc's success state instead.
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouteNames.home,
      (route) => false,
    );
  }

  void _onGooglePressed() {
    // TODO(phase-2): dispatch LoginWithGooglePressed to LoginBloc.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(AppAssets.logo, width: 121.w),
                SizedBox(height: 40.h),
                AppTextField(
                  hintText: AppStrings.email,
                  controller: _emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: 16.h),
                PasswordTextField(
                  hintText: AppStrings.password,
                  controller: _passwordController,
                  validator: Validators.password,
                ),
                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRouteNames.forgotPassword,
                    ),
                    child: Text(
                      AppStrings.forgetPassword,
                      style: AppTextStyles.link,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                PrimaryButton(
                  text: AppStrings.login,
                  onPressed: _onLoginPressed,
                ),
                SizedBox(height: 24.h),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRouteNames.register),
                  child: Text(
                    AppStrings.createAccountPrompt,
                    style: AppTextStyles.link,
                  ),
                ),
                SizedBox(height: 16.h),
                const OrDivider(),
                SizedBox(height: 24.h),
                GoogleSignInButton(onPressed: _onGooglePressed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
