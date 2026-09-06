import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/genre_chip.dart';
import '../../../../core/widgets/movie_grid.dart';
import '../../../movies/data/sample_movies.dart';
import '../../../movies/domain/entities/movie.dart';

/// Browse tab. Figma node 50:462.
///
/// A scrolling row of genre chips over the matching posters.
///
/// ⚠️ Reads [SampleMovies] — swap for the Browse Bloc when the YTS layer
/// lands. The brief has that Bloc fold every movie's genres into a Set to
/// build this row, rather than hardcoding the list.
class BrowseTab extends StatefulWidget {
  const BrowseTab({super.key});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  late String _selectedGenre = SampleMovies.genres.first;

  List<Movie> get _moviesInGenre {
    final matching = SampleMovies.all
        .where((movie) => movie.genres.contains(_selectedGenre))
        .toList();

    // The placeholder catalogue only tags a few movies, so an unmatched genre
    // would look broken. The real catalogue makes this branch unnecessary.
    return matching.isEmpty ? SampleMovies.all : matching;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: AppTheme.chipHeight.h + 32.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
                itemCount: SampleMovies.genres.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final genre = SampleMovies.genres[index];
                  return GenreChip(
                    label: genre,
                    isSelected: genre == _selectedGenre,
                    onTap: () => setState(() => _selectedGenre = genre),
                  );
                },
              ),
            ),
            Expanded(
              child: MovieGrid(
                movies: _moviesInGenre,
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
