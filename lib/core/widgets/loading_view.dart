import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The `loading` branch of every Bloc-driven screen.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
