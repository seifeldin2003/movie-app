import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/destructive_button.dart';
import '../../../../core/widgets/primary_button.dart';

/// Update Profile screen. Figma node 55:827.
///
/// Phase 1 is UI only — the fields validate, but saving and deleting are
/// wired to the profile Bloc in Phase 2.
class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onUpdatePressed() {
    if (!_formKey.currentState!.validate()) return;
    // TODO(phase-2): dispatch the profile-update event.
  }

  void _onDeletePressed() {
    // TODO(phase-2): confirm, then dispatch the delete-account event.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.pickAvatar)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: Image.asset(AppAssets.avatar, width: 150.w)),
                SizedBox(height: 32.h),
                AppTextField(
                  hintText: AppStrings.name,
                  controller: _nameController,
                  validator: Validators.required,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.white,
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      // TODO(phase-2): send the password-reset email.
                    },
                    child: Text(
                      AppStrings.resetPassword,
                      style: AppTextStyles.link,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                DestructiveButton(
                  text: AppStrings.deleteAccount,
                  onPressed: _onDeletePressed,
                ),
                SizedBox(height: 16.h),
                PrimaryButton(
                  text: AppStrings.updateData,
                  onPressed: _onUpdatePressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
