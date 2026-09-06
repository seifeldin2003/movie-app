import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/register/register_bloc.dart';
import '../bloc/register/register_event.dart';
import '../bloc/register/register_state.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _phoneController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _selectedAvatarIndex = 1; // Default to center avatar
  bool _isArabic = false;

  final List<String> _avatars = const [
    AppAssets.avatar2,
    AppAssets.avatar1,
    AppAssets.avatar3,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onRegisterPressed(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<RegisterBloc>().add(
            RegisterSubmitted(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              phoneNumber: _phoneController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RegisterBloc>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.primary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            AppStrings.register,
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        body: BlocConsumer<RegisterBloc, RegisterState>(
          listener: (context, state) {
            if (state is RegisterSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.registerSuccess),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.of(context).pop();
            } else if (state is RegisterFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is RegisterLoading;

            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildAvatarPicker(),
                      SizedBox(height: 8.h),
                      Text(
                        AppStrings.avatar,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      AppTextField(
                        controller: _nameController,
                        hintText: AppStrings.name,
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                          color: AppColors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        controller: _emailController,
                        hintText: AppStrings.email,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          if (!emailRegex.hasMatch(value.trim())) {
                            return AppStrings.invalidEmail;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        controller: _passwordController,
                        hintText: AppStrings.password,
                        obscureText: _obscurePassword,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.white,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          if (value.length < 6) {
                            return AppStrings.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        controller: _confirmPasswordController,
                        hintText: AppStrings.confirmPassword,
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: AppColors.white,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          if (value != _passwordController.text) {
                            return AppStrings.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        controller: _phoneController,
                        hintText: AppStrings.phoneNumber,
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: AppColors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24.h),
                      PrimaryButton(
                        text: AppStrings.createAccount,
                        isLoading: isLoading,
                        onPressed: () => _onRegisterPressed(context),
                      ),
                      SizedBox(height: 16.h),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text.rich(
                          TextSpan(
                            text: AppStrings.alreadyHaveAccount,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                            ),
                            children: [
                              TextSpan(
                                text: AppStrings.login,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _buildLanguageSwitch(),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    return SizedBox(
      height: 160.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_avatars.length, (index) {
          final isSelected = _selectedAvatarIndex == index;
          final double size = isSelected ? 140.w : 84.w;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedAvatarIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: AppColors.primary, width: 3.w)
                    : null,
              ),
              child: ClipOval(
                child: Image.asset(
                  _avatars[index],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => CircleAvatar(
                    backgroundColor: AppColors.surface,
                    child: Icon(
                      Icons.person,
                      size: isSelected ? 60.r : 36.r,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLanguageSwitch() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isArabic = !_isArabic;
        });
      },
      child: Container(
        width: 92.w,
        height: 38.h,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.primary, width: 2.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFlagItem(
              assetPath: AppAssets.enFlag,
              isSelected: !_isArabic,
            ),
            _buildFlagItem(
              assetPath: AppAssets.egFlag,
              isSelected: _isArabic,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagItem({
    required String assetPath,
    required bool isSelected,
  }) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 2.w)
            : null,
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Icon(
            Icons.flag,
            size: 16.r,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

