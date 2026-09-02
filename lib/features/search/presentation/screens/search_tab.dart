import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/empty_view.dart';

/// Search tab. Figma nodes 50:60 (empty) and 55:421 (results).
///
/// Phase 1 delivers the navigation shell only — searching arrives in Phase 3.
class SearchTab extends StatelessWidget {
  const SearchTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: EmptyView(message: AppStrings.comingSoon));
  }
}
