import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_text_styles.dart';
import 'popcorn_empty_art.dart';

/// The `empty` branch of every Bloc-driven screen — a successful load that
/// returned nothing. Handle it separately from `error`; they read differently
/// to the user.
///
/// The popcorn illustration is drawn and animated rather than loaded from
/// `empty_state.png`. All four callers showed the same picture, so it lives
/// here rather than being passed in — see [PopcornEmptyArt] for why it is
/// drawn at all. Figma node 52:601.
///
/// Set [showArt] to false where the caption alone is enough — a small inline
/// slot, say, with no room for a 124pt illustration.
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message, this.showArt = true});

  final String message;
  final bool showArt;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: showArt
            ? PopcornEmptyArt(message: message)
            : Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
      ),
    );
  }
}
