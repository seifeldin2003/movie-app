import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';

/// Forgot Password screen. Figma node 47:936.
///
/// Phase 1 is UI only — the form validates, but sending the reset email is
/// wired to `ForgotPasswordBloc` in Phase 2.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onVerifyPressed() {
    if (!_formKey.currentState!.validate()) return;
    // TODO(phase-2): dispatch ForgotPasswordSubmitted to ForgotPasswordBloc.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.forgetPassword)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(AppAssets.forgotPasswordArt, width: 430.w),
                SizedBox(height: 24.h),
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
                SizedBox(height: 24.h),
                PrimaryButton(
                  text: AppStrings.verifyEmail,
                  onPressed: _onVerifyPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
