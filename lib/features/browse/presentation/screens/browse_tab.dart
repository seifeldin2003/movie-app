import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/empty_view.dart';

/// Browse tab. Figma node 50:462.
///
/// Phase 1 delivers the navigation shell only — the genre tabs arrive in
/// Phase 3.
class BrowseTab extends StatelessWidget {
  const BrowseTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: EmptyView(message: AppStrings.comingSoon));
  }
}
