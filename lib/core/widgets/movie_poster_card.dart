import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/movies/domain/entities/movie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'rating_badge.dart';

/// A movie poster with its score pill — the tile Home, Search, Browse and
/// Profile all reuse. Figma node 47:1543.
///
/// Takes a [Movie] rather than an asset path because Phase 2 supplies artwork
/// from the API at runtime. Until then [Movie.posterUrl] is null and the card
/// draws [PosterPlaceholder] instead, so no poster images ship in the repo.
class MoviePosterCard extends StatelessWidget {
  const MoviePosterCard({super.key, required this.movie, this.onTap});

  final Movie movie;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.cardRadius.r);

    return GestureDetector(
      onTap: onTap,
      // The poster repaints on its own during carousel scrolling; without this
      // every transform frame would repaint the whole card subtree.
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PosterImage(movie: movie),
              Positioned(
                top: 10.h,
                left: 10.w,
                child: RatingBadge(rating: movie.rating),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resolves a movie's artwork, wherever it comes from, and always renders
/// something — the card, the grid and the Home backdrop all go through here so
/// the asset-vs-URL branching exists in one place.
class PosterImage extends StatelessWidget {
  const PosterImage({
    super.key,
    required this.movie,
    this.source,
    this.showLabel = true,
  });

  final Movie movie;

  /// Defaults to [Movie.posterUrl]. The Home backdrop passes
  /// [Movie.backgroundUrl] instead.
  final String? source;

  /// Whether the fallback tile captions itself with the title and year.
  ///
  /// Right for a card, wrong for full-bleed artwork: the Home backdrop and the
  /// details hero both print the title themselves, so a captioned placeholder
  /// behind them shows it twice.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final source = this.source ?? movie.posterUrl;
    if (source == null || source.isEmpty) {
      return PosterPlaceholder(movie: movie, showLabel: showLabel);
    }

    // A bundled path rather than a URL. Only the local sample catalogue uses
    // this; once the API supplies artwork every source is an http URL and this
    // branch stops being taken.
    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: BoxFit.cover,
        // The sample images are git-ignored, so a fresh clone has none of
        // them. Falling back keeps that a plain tile instead of a red error.
        errorBuilder: (_, _, _) =>
            PosterPlaceholder(movie: movie, showLabel: showLabel),
      );
    }

    return Image.network(
      source,
      fit: BoxFit.cover,
      // A failed image must not leave a hole in the grid.
      errorBuilder: (_, _, _) =>
          PosterPlaceholder(movie: movie, showLabel: showLabel),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return PosterPlaceholder(movie: movie, showLabel: showLabel);
      },
    );
  }
}

/// Stands in for artwork that has not arrived — either because Phase 2 has not
/// landed or because the image failed to load.
///
/// The hue comes from [Movie.id], so a given movie always gets the same tile.
/// That matters on Home: the backdrop follows the centred card, and a colour
/// that changed on every rebuild would make it flicker.
class PosterPlaceholder extends StatelessWidget {
  const PosterPlaceholder({
    super.key,
    required this.movie,
    this.showLabel = true,
  });

  final Movie movie;

  /// See [PosterImage.showLabel] — off for full-bleed artwork, which prints
  /// the title itself.
  final bool showLabel;

  /// Spread ids around the wheel rather than along it, so neighbouring cards
  /// look clearly different instead of near-identical.
  Color get _tint =>
      HSLColor.fromAHSL(1, (movie.id * 47) % 360, 0.35, 0.28).toColor();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_tint, AppColors.surface],
        ),
      ),
      child: showLabel
          ? Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium,
                  ),
                  if (movie.year != null)
                    Text('${movie.year}', style: AppTextStyles.bodySmall),
                ],
              ),
            )
          : const SizedBox.expand(),
    );
  }
}
