import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';

/// Password input with the show/hide eye toggle. Figma node 44:642.
///
/// Whether the text is hidden is this widget's own business, so it keeps that
/// bit of state instead of pushing it up into the screen or a Bloc.
class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.validator,
  });

  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      hintText: widget.hintText,
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _isObscured,
      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.white),
      suffixIcon: IconButton(
        onPressed: () => setState(() => _isObscured = !_isObscured),
        icon: Icon(
          _isObscured ? Icons.visibility_off : Icons.visibility,
          color: AppColors.white,
        ),
      ),
    );
  }
}
