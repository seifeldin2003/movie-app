import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/onboarding_slide_data.dart';
import 'poster_backdrop.dart';

/// The first onboarding page. Figma node 30:447.
///
/// Unlike the later slides the copy sits straight on the poster collage —
/// there is no bottom sheet and no Back button — so it gets its own widget
/// rather than a pile of conditionals inside [OnboardingSlideView].
class OnboardingIntroSlide extends StatelessWidget {
  const OnboardingIntroSlide({
    super.key,
    required this.slide,
    required this.onAction,
  });

  final OnboardingSlideData slide;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PosterBackdrop(image: slide.image),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayLarge,
                  ),
                  SizedBox(height: 16.h),
                  if (slide.body != null)
                    Text(
                      slide.body!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyLargeMuted,
                    ),
                  SizedBox(height: 24.h),
                  PrimaryButton(text: slide.actionLabel, onPressed: onAction),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
