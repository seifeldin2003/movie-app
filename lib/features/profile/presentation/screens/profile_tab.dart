import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/empty_view.dart';

/// Profile tab. Figma nodes 51:511 (empty) and 55:633 (populated).
///
/// Phase 1 delivers the navigation shell only — the watch list and history
/// arrive in Phase 3.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: EmptyView(message: AppStrings.comingSoon));
  }
}
