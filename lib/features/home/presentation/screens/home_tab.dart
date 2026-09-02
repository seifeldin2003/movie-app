import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/empty_view.dart';

/// Home tab. Figma node 47:1248.
///
/// Phase 1 delivers the navigation shell only — the featured banner and the
/// genre rows arrive with the YTS integration in Phase 2.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: EmptyView(message: AppStrings.comingSoon));
  }
}
