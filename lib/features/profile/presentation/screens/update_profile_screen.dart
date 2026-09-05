import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/routes/app_route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/destructive_button.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/update_profile/update_profile_bloc.dart';
import '../bloc/update_profile/update_profile_event.dart';
import '../bloc/update_profile/update_profile_state.dart';

/// Update Profile screen. Figma node 55:827.
///
/// The phone field is display-only for now — Firebase Auth stores a phone
/// number only through a verified SMS flow, so saving it needs a Firestore
/// user document (see AuthRepositoryImpl.register).
class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  /// The form is pre-filled once, when the user first arrives. Re-filling on
  /// every emit would overwrite whatever they were typing.
  bool _prefilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onUpdatePressed(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<UpdateProfileBloc>().add(
      UpdateProfileSubmitted(name: _nameController.text),
    );
  }

  Future<void> _onDeletePressed(BuildContext context) async {
    final bloc = context.read<UpdateProfileBloc>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          AppStrings.deleteAccountTitle,
          style: AppTextStyles.titleMedium,
        ),
        content: Text(
          AppStrings.deleteAccountBody,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(AppStrings.cancel, style: AppTextStyles.link),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              AppStrings.delete,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      bloc.add(const UpdateProfileDeleteRequested());
    }
  }

  void _onStateChanged(BuildContext context, UpdateProfileState state) {
    switch (state.status) {
      case UpdateProfileStatus.failure:
        AppSnackBar.show(context, state.message ?? '', isError: true);
      case UpdateProfileStatus.saved:
        AppSnackBar.show(context, AppStrings.profileUpdated);
      case UpdateProfileStatus.passwordResetSent:
        AppSnackBar.show(context, AppStrings.resetPasswordSent);
      case UpdateProfileStatus.deleted:
        // The account is gone, so the whole stack has to go with it.
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouteNames.login,
          (route) => false,
        );
      case UpdateProfileStatus.initial:
      case UpdateProfileStatus.loading:
        break;
    }

    if (!_prefilled && state.user != null) {
      _nameController.text = state.user!.name ?? '';
      _phoneController.text = state.user!.phoneNumber ?? '';
      _prefilled = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UpdateProfileBloc>(
      create: (_) =>
          getIt<UpdateProfileBloc>()..add(const UpdateProfileStarted()),
      child: Scaffold(
        appBar: AppBar(title: Text(AppStrings.pickAvatar)),
        body: SafeArea(
          child: BlocConsumer<UpdateProfileBloc, UpdateProfileState>(
            listener: _onStateChanged,
            builder: (context, state) {
              final isLoading = state.isLoading;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(AppAssets.avatar, width: 150.w),
                      ),
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
                          onPressed: isLoading
                              ? null
                              : () => context.read<UpdateProfileBloc>().add(
                                  const UpdateProfilePasswordResetRequested(),
                                ),
                          child: Text(
                            AppStrings.resetPassword,
                            style: AppTextStyles.link,
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      DestructiveButton(
                        text: AppStrings.deleteAccount,
                        onPressed: isLoading
                            ? null
                            : () => _onDeletePressed(context),
                      ),
                      SizedBox(height: 16.h),
                      PrimaryButton(
                        text: AppStrings.updateData,
                        isLoading: isLoading,
                        onPressed: () => _onUpdatePressed(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
