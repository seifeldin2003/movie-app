import 'package:flutter/material.dart';

import '../../../../core/routes/app_route_names.dart';
import '../../data/onboarding_slides.dart';
import '../widgets/onboarding_intro_slide.dart';
import '../widgets/onboarding_slide_view.dart';

/// The six-page onboarding flow. Figma nodes 30:447 → 39:294.
///
/// Paging is local UI state, so it stays in this widget — a Bloc would add
/// ceremony without adding anything.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Duration _pageDuration = Duration(milliseconds: 300);

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    final isLastPage = _currentPage == OnboardingSlides.all.length - 1;
    if (isLastPage) {
      Navigator.pushReplacementNamed(context, AppRouteNames.login);
      return;
    }
    _pageController.nextPage(duration: _pageDuration, curve: Curves.easeInOut);
  }

  void _goToPreviousPage() {
    _pageController.previousPage(
      duration: _pageDuration,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: OnboardingSlides.all.length,
        onPageChanged: (page) => setState(() => _currentPage = page),
        itemBuilder: (context, index) {
          final slide = OnboardingSlides.all[index];
          if (!slide.showBack) {
            return OnboardingIntroSlide(slide: slide, onAction: _goToNextPage);
          }
          return OnboardingSlideView(
            slide: slide,
            onNext: _goToNextPage,
            onBack: _goToPreviousPage,
          );
        },
      ),
    );
  }
}
