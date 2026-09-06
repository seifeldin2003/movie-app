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
import '../../../../core/widgets/primary_button.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/or_divider.dart';
import '../widgets/password_text_field.dart';

/// Login screen. Figma node 44:444.
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

  void _onLoginPressed(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<LoginBloc>().add(
      LoginSubmitted(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  void _onGooglePressed(BuildContext context) {
    // No form validation — Google collects the credentials itself.
    context.read<LoginBloc>().add(const LoginWithGooglePressed());
  }

  void _onStateChanged(BuildContext context, LoginState state) {
    if (state is LoginFailure) {
      AppSnackBar.show(context, state.message, isError: true);
      return;
    }

    if (state is LoginSuccess) {
      final greeting = state.user.name ?? state.user.email ?? '';
      AppSnackBar.show(context, AppStrings.welcome(greeting));
      // Clear the stack so Back cannot return to the login form.
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouteNames.home,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (_) => getIt<LoginBloc>(),
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: _onStateChanged,
            builder: (context, state) {
              final isLoading = state is LoginLoading;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 24.h,
                ),
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
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pushNamed(
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
                        isLoading: isLoading,
                        onPressed: () => _onLoginPressed(context),
                      ),
                      SizedBox(height: 24.h),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => Navigator.pushNamed(
                                context,
                                AppRouteNames.register,
                              ),
                        child: Text(
                          AppStrings.createAccountPrompt,
                          style: AppTextStyles.link,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      const OrDivider(),
                      SizedBox(height: 24.h),
                      GoogleSignInButton(
                        onPressed: isLoading
                            ? null
                            : () => _onGooglePressed(context),
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
