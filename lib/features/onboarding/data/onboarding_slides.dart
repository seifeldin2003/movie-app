import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../domain/entities/onboarding_slide_data.dart';

/// The six onboarding pages, in the order the Figma frames are laid out.
class OnboardingSlides {
  const OnboardingSlides._();

  static const List<OnboardingSlideData> all = [
    // Figma 30:447 — poster collage, no Back button.
    OnboardingSlideData(
      image: AppAssets.onboardingIntro,
      title: AppStrings.onboardingIntroTitle,
      body: AppStrings.onboardingIntroBody,
      actionLabel: AppStrings.exploreNow,
      showBack: false,
    ),
    // Figma 38:75
    OnboardingSlideData(
      image: AppAssets.onboardingDiscover,
      title: AppStrings.onboardingDiscoverTitle,
      body: AppStrings.onboardingDiscoverBody,
      actionLabel: AppStrings.next,
    ),
    // Figma 38:172
    OnboardingSlideData(
      image: AppAssets.onboardingGenres,
      title: AppStrings.onboardingGenresTitle,
      body: AppStrings.onboardingGenresBody,
      actionLabel: AppStrings.next,
    ),
    // Figma 38:149
    OnboardingSlideData(
      image: AppAssets.onboardingWatchlist,
      title: AppStrings.onboardingWatchlistTitle,
      body: AppStrings.onboardingWatchlistBody,
      actionLabel: AppStrings.next,
    ),
    // Figma 38:188
    OnboardingSlideData(
      image: AppAssets.onboardingReview,
      title: AppStrings.onboardingReviewTitle,
      body: AppStrings.onboardingReviewBody,
      actionLabel: AppStrings.next,
    ),
    // Figma 39:294 — title only, and the action finishes onboarding.
    OnboardingSlideData(
      image: AppAssets.onboardingStart,
      title: AppStrings.onboardingStartTitle,
      actionLabel: AppStrings.finish,
    ),
  ];
}
