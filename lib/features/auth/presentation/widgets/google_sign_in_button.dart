import 'package:flutter/material.dart';

/// TASK: Login — the dark "Login With Google" button. Figma node `44:622`.
///
/// Same height and radius as [PrimaryButton] but on `AppColors.surface`, with
/// the Google mark from `AppAssets.googleIcon` beside the label.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // TODO(login): build the Google button
  }
}
