import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../movies/domain/entities/movie_details.dart';

/// Likes, runtime and score, as three pills under the Watch button.
/// Figma nodes 53:77 / 53:82 / 53:86.
///
/// The icons are heart / clock / star, in that order. An earlier version had
/// a shield and the age rating in the first slot — reading `mpa_rating` off
/// the record and assuming the badge matched. The design's first pill is a
/// heart with the like count, and `like_count` comes back on the same
/// `movie_details` response, so nothing extra had to be fetched for it.
///
/// `mpa_rating` is deliberately not shown: the design has no slot for it.
///
/// YTS leaves any of these blank — `runtime` is often 0 and `like_count` is
/// absent on records that were never voted on — so each pill drops out rather
/// than showing an empty box, and the row disappears entirely when none
/// survive.
class MovieBadgeRow extends StatelessWidget {
  const MovieBadgeRow({super.key, required this.details});

  final MovieDetails details;

  @override
  Widget build(BuildContext context) {
    final likes = details.likeCount;
    final runtime = details.runtimeMinutes;
    final rating = details.movie.rating;

    final badges = <Widget>[
      if (likes != null && likes > 0)
        _Badge(icon: Icons.favorite, label: '$likes'),
      if (runtime != null && runtime > 0)
        _Badge(icon: Icons.access_time, label: '$runtime'),
      if (rating != null)
        _Badge(icon: Icons.star, label: rating.toStringAsFixed(1)),
    ];

    if (badges.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          for (final badge in badges) ...[
            Expanded(child: badge),
            if (badge != badges.last) SizedBox(width: 16.w),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.surfaceCardRadius.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 22.sp),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.badgeValue,
            ),
          ),
        ],
      ),
    );
  }
}
