import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/movie_poster_card.dart';
import '../../../movies/domain/entities/movie.dart';

/// The full-bleed artwork behind the Home carousel, taken from whichever card
/// is currently centred. Figma node 47:1527.
///
/// Cross-fades between movies so the change reads as a transition rather than
/// a flash. Keyed on [Movie.id] — [AnimatedSwitcher] compares child keys, and
/// without one it would treat every movie as the same widget and never
/// animate.
///
/// Only rebuilt when the settled page changes, not while scrolling, so this
/// stays off the per-frame path.
class CarouselBackdrop extends StatelessWidget {
  const CarouselBackdrop({
    super.key,
    required this.movie,
    required this.height,
  });

  final Movie movie;
  final double height;

  static const Duration _fade = Duration(milliseconds: 450);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: _fade,
            child: PosterImage(
              key: ValueKey(movie.id),
              movie: movie,
              source: movie.backgroundUrl ?? movie.posterUrl,
            ),
          ),
          // Fades the artwork into the page background so the carousel in
          // front of it always stays legible.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.backdropScrim,
                stops: AppColors.backdropScrimStops,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

