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
            // AnimatedSwitcher's default layout puts its children in a *loose*
            // Stack, and an Image under loose constraints sizes to its own
            // pixel dimensions — `BoxFit.cover` only decides how the bitmap
            // sits inside the box it is handed, it never widens that box. So
            // artwork smaller than the backdrop floated in the middle at its
            // natural size, and artwork larger than the screen only looked
            // right because it overflowed and got clipped. Expanding here
            // makes every image fill the backdrop and actually honour `cover`.
            layoutBuilder: (currentChild, previousChildren) => Stack(
              fit: StackFit.expand,
              children: [...previousChildren, ?currentChild],
            ),
            child: PosterImage(
              key: ValueKey(movie.id),
              movie: movie,
              // The POSTER, not `background_image`. The API's background is a
              // 896x375 letterbox banner and this box is 430x645 — `cover`
              // would blow it up about four times and show a narrow strip of
              // the middle. The large poster is 500x750, the same 0.67 ratio
              // as this box, so it fills it with no crop at all.
              source: movie.largePosterUrl ?? movie.posterUrl,
              // Pure backdrop — the card in front already names the movie.
              showLabel: false,
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

