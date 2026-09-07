import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';

/// "Screen Shots", "Similar", "Summary", "Cast", "Genres" — every section on
/// Movie Details opens with one of these. Figma node 55:107.
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
      child: Text(title, style: AppTextStyles.sectionHeading),
    );
  }
}
