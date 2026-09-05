import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/forgot_password/forgot_password_bloc.dart';
import '../bloc/forgot_password/forgot_password_event.dart';
import '../bloc/forgot_password/forgot_password_state.dart';

/// Forgot Password screen. Figma node 47:936.
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

  void _onVerifyPressed(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<ForgotPasswordBloc>().add(
      ForgotPasswordSubmitted(email: _emailController.text),
    );
  }

  void _onStateChanged(BuildContext context, ForgotPasswordState state) {
    if (state is ForgotPasswordFailure) {
      AppSnackBar.show(context, state.message, isError: true);
      return;
    }

    if (state is ForgotPasswordSuccess) {
      // Confirm before leaving — the user still has to go read their inbox,
      // so popping silently would look like nothing happened.
      AppSnackBar.show(context, AppStrings.resetPasswordSent);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordBloc>(
      create: (_) => getIt<ForgotPasswordBloc>(),
      child: Scaffold(
        appBar: AppBar(title: Text(AppStrings.forgetPassword)),
        body: SafeArea(
          child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
            listener: _onStateChanged,
            builder: (context, state) {
              final isLoading = state is ForgotPasswordLoading;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
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
                        isLoading: isLoading,
                        onPressed: () => _onVerifyPressed(context),
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
