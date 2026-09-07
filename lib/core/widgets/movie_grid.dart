import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/movies/domain/entities/movie.dart';
import 'movie_poster_card.dart';

/// The poster grid behind Search, Browse and Profile.
///
/// Built lazily by `GridView.builder`, so a long catalogue only ever builds
/// the rows on screen.
class MovieGrid extends StatelessWidget {
  const MovieGrid({
    super.key,
    required this.movies,
    this.crossAxisCount = 2,
    this.onTapMovie,
    this.padding,
    this.shrinkWrap = false,
  });

  final List<Movie> movies;

  /// Two on Search and Browse, three on Profile. Figma 50:462 / 55:633.
  final int crossAxisCount;

  final ValueChanged<Movie>? onTapMovie;
  final EdgeInsetsGeometry? padding;

  /// Set when the grid sits inside another scroll view — as on Movie Details,
  /// where it sizes to its content and lets the page do the scrolling. Two
  /// nested scrollables would fight each other.
  final bool shrinkWrap;

  /// Posters are 2:3, matching every card in the design.
  static const double _posterAspectRatio = 2 / 3;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding:
          padding ??
          EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: _posterAspectRatio,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MoviePosterCard(
          movie: movie,
          onTap: onTapMovie == null ? null : () => onTapMovie!(movie),
        );
      },
    );
  }
}
