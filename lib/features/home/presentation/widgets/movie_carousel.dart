import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/widgets/movie_poster_card.dart';
import '../../../movies/domain/entities/movie.dart';

/// The coverflow at the top of Home. Figma nodes 47:1543 / 47:1544 / 47:1550.
///
/// Cards scale down and tilt away as they leave the centre, so the middle one
/// reads as the focus. Two things keep it smooth:
///
///  * the transform is rebuilt every frame but the card underneath is not —
///    it is passed as `child` to [AnimatedBuilder], so scrolling re-runs a
///    matrix, not an image decode;
///  * [onCentered] fires only when the settled page changes, so the backdrop
///    behind it repaints on a page change rather than on every scroll frame.
class MovieCarousel extends StatefulWidget {
  const MovieCarousel({
    super.key,
    required this.movies,
    required this.onCentered,
    this.onTap,
  });

  final List<Movie> movies;

  /// Fires with the newly settled index — used to swap the Home backdrop.
  final ValueChanged<int> onCentered;

  final ValueChanged<Movie>? onTap;

  @override
  State<MovieCarousel> createState() => _MovieCarouselState();
}

class _MovieCarouselState extends State<MovieCarousel> {
  /// Leaves the neighbouring posters peeking in at either edge.
  static const double _viewportFraction = 0.62;

  /// How small a card gets at a full page away.
  static const double _minScale = 0.82;

  /// Radians of tilt at a full page away — about 4.5°, enough to read as
  /// depth without looking broken.
  static const double _maxTilt = 0.08;

  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: _viewportFraction);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// How far this item sits from the centre, in pages.
  ///
  /// `page` is unavailable until the viewport has been laid out, so the first
  /// build falls back to the initial page — reading it early throws.
  double _offsetFor(int index) {
    final hasDimensions =
        _controller.hasClients &&
        _controller.position.hasContentDimensions;
    final page = hasDimensions
        ? (_controller.page ?? _controller.initialPage.toDouble())
        : _controller.initialPage.toDouble();
    return page - index;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 351.h,
      child: PageView.builder(
        controller: _controller,
        itemCount: widget.movies.length,
        onPageChanged: widget.onCentered,
        itemBuilder: (context, index) {
          final movie = widget.movies[index];

          return AnimatedBuilder(
            animation: _controller,
            // Built once per item. The builder below only wraps it in a new
            // transform, so the poster is never rebuilt while scrolling.
            child: MoviePosterCard(
              movie: movie,
              onTap: widget.onTap == null
                  ? null
                  : () => widget.onTap!(movie),
            ),
            builder: (context, child) {
              final offset = _offsetFor(index);
              final distance = offset.abs().clamp(0.0, 1.0);

              return Center(
                child: Transform.rotate(
                  // Tilt follows the sign, so cards lean away from centre.
                  angle: _maxTilt * offset.clamp(-1.0, 1.0),
                  child: Transform.scale(
                    scale: lerpDouble(1, _minScale, distance)!,
                    child: SizedBox(
                      width: 234.w,
                      height: 351.h,
                      child: child,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
