import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../widgets/avatar_picker.dart';
import '../widgets/password_text_field.dart';

/// Register screen. Figma node 44:670.
///
/// Phase 1 is UI only — the form validates, but submitting is wired to
/// `RegisterBloc` in Phase 2.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (!_formKey.currentState!.validate()) return;
    // TODO(phase-2): dispatch RegisterSubmitted to RegisterBloc.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.register)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const AvatarPicker(),
                SizedBox(height: 24.h),
                AppTextField(
                  hintText: AppStrings.name,
                  controller: _nameController,
                  validator: Validators.required,
                  prefixIcon: const Icon(
                    Icons.badge_outlined,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: 16.h),
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
                SizedBox(height: 16.h),
                PasswordTextField(
                  hintText: AppStrings.confirmPassword,
                  controller: _confirmPasswordController,
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                ),
                SizedBox(height: 16.h),
                AppTextField(
                  hintText: AppStrings.phoneNumber,
                  controller: _phoneController,
                  validator: Validators.required,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: 24.h),
                PrimaryButton(
                  text: AppStrings.register,
                  onPressed: _onRegisterPressed,
                ),
                SizedBox(height: 16.h),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppStrings.haveAccountPrompt,
                    style: AppTextStyles.link,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
