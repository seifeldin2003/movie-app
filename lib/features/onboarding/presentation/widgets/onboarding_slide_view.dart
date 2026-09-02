import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../domain/entities/onboarding_slide_data.dart';
import 'poster_backdrop.dart';

/// Onboarding pages two through six. Figma nodes 38:75, 38:172, 38:149,
/// 38:188, 39:294 — one layout, different artwork and copy.
///
/// The copy sits in a rounded sheet pinned to the bottom of the screen
/// (Figma "Intro Bottom Sheet", node 38:161).
class OnboardingSlideView extends StatelessWidget {
  const OnboardingSlideView({
    super.key,
    required this.slide,
    required this.onNext,
    required this.onBack,
  });

  final OnboardingSlideData slide;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PosterBackdrop(image: slide.image),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(40.r)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      slide.title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge,
                    ),
                    if (slide.body != null) ...[
                      SizedBox(height: 16.h),
                      Text(
                        slide.body!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                    SizedBox(height: 24.h),
                    PrimaryButton(text: slide.actionLabel, onPressed: onNext),
                    if (slide.showBack) ...[
                      SizedBox(height: 16.h),
                      SecondaryButton(
                        text: AppStrings.back,
                        onPressed: onBack,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
