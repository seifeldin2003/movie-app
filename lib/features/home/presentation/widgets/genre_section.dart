import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/movie_poster_card.dart';
import '../../../movies/domain/entities/movie.dart';

/// A genre heading with a horizontal strip of posters underneath.
/// Figma nodes 47:1556 / 47:1588 / 47:1564.
class GenreSection extends StatelessWidget {
  const GenreSection({
    super.key,
    required this.title,
    required this.movies,
    this.onSeeMore,
    this.onTapMovie,
  });

  final String title;
  final List<Movie> movies;
  final VoidCallback? onSeeMore;
  final ValueChanged<Movie>? onTapMovie;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.titleMedium),
              GestureDetector(
                onTap: onSeeMore,
                child: Row(
                  children: [
                    Text(AppStrings.seeMore, style: AppTextStyles.link),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.primary,
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 220.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: movies.length,
            separatorBuilder: (_, _) => SizedBox(width: 16.w),
            itemBuilder: (context, index) {
              final movie = movies[index];
              return SizedBox(
                width: 146.w,
                child: MoviePosterCard(
                  movie: movie,
                  onTap: onTapMovie == null ? null : () => onTapMovie!(movie),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
