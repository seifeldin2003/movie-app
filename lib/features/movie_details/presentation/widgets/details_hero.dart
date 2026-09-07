import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/movie_poster_card.dart';
import '../../../movies/domain/entities/movie.dart';

/// The artwork behind the collapsing app bar on Movie Details.
/// Figma node 55:208.
///
/// Artwork and caption only — the back and watchlist controls belong to the
/// `SliverAppBar` above it, so they stay reachable once this has scrolled
/// away.
class DetailsHero extends StatelessWidget {
  const DetailsHero({
    super.key,
    required this.movie,
    this.onPlay,
    this.captionOpacity = 1,
  });

  final Movie movie;
  final VoidCallback? onPlay;

  /// Fades the title and year as the app bar collapses, so its own title can
  /// take over without both being legible at once.
  final double captionOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PosterImage(
          movie: movie,
          // The poster, for the same reason as the Home backdrop: YTS's
          // `background_image` is a wide banner that `cover` has to zoom
          // into unrecognisably in a tall box.
          source: movie.largePosterUrl ?? movie.posterUrl,
          // The caption below prints the title; a labelled fallback would
          // show it twice.
          showLabel: false,
        ),
        // Lets the caption read against whatever the artwork happens to be.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.heroScrim,
              stops: AppColors.heroScrimStops,
            ),
          ),
        ),
        if (onPlay != null)
          // Sits above centre rather than dead centre, so it does not fight
          // the title for attention. Figma puts it at roughly a third down.
          Align(
            alignment: const Alignment(0, -0.25),
            child: _PlayButton(onTap: onPlay!),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Opacity(
              opacity: captionOpacity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sectionHeading,
                  ),
                  if (movie.year != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      '${movie.year}',
                      style: AppTextStyles.bodyReadable.copyWith(
                        color: AppColors.whiteMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Outlined rather than a solid white disc, which read as a screenshot
/// artefact sitting on top of the poster.
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64.w,
        height: 64.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.ratingBadge,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 2.w),
        ),
        child: Padding(
          // The glyph is optically left-heavy; nudging it right centres it.
          padding: EdgeInsets.only(left: 3.w),
          child: Icon(
            Icons.play_arrow_rounded,
            color: AppColors.white,
            size: 34.sp,
          ),
        ),
      ),
    );
  }
}

/// A control over the artwork, darkened so it stays visible on a light poster.
class HeroIconButton extends StatelessWidget {
  const HeroIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40.w,
          height: 40.w,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.ratingBadge,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.white, size: 20.sp),
        ),
      ),
    );
  }
}
