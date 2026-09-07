import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// The stacked stills under "Screen Shots". Figma node 55:203 — three
/// full-width images at roughly 398x166.
///
/// Stacked rather than in a horizontal strip because that is what the design
/// does; each still is wide, so scrolling them sideways would show slivers.
class ScreenshotStrip extends StatelessWidget {
  const ScreenshotStrip({super.key, required this.screenshots});

  final List<String> screenshots;

  @override
  Widget build(BuildContext context) {
    // Nothing at all when there are no stills. An earlier version drew three
    // empty grey boxes to "hold the space", which just meant ~450pt of
    // nothing — far worse than the section not being there. The screen hides
    // the heading to match.
    if (screenshots.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (final url in screenshots)
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: _Screenshot(url: url),
          ),
      ],
    );
  }
}

class _Screenshot extends StatelessWidget {
  const _Screenshot({required this.url});

  final String url;

  /// A still that will not load leaves a neutral tile rather than a gap.
  static Widget _fallback(BuildContext context, Object _, StackTrace? _) {
    return Center(
      child: Icon(
        Icons.image_outlined,
        color: AppColors.whiteMuted,
        size: 32.sp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.cardRadius.r);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        height: 166.h,
        width: double.infinity,
        child: ColoredBox(
          color: AppColors.surface,
          // A bundled path rather than a URL — only the local sample
          // catalogue uses this. Once the API supplies stills every source is
          // an http URL and this branch stops being taken.
          child: url.startsWith('assets/')
              ? Image.asset(url, fit: BoxFit.cover, errorBuilder: _fallback)
              : Image.network(url, fit: BoxFit.cover, errorBuilder: _fallback),
        ),
      ),
    );
  }
}
