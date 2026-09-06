import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../movies/data/sample_movies.dart';
import '../../../movies/domain/entities/movie.dart';
import '../widgets/carousel_backdrop.dart';
import '../widgets/genre_section.dart';
import '../widgets/movie_carousel.dart';

/// Home tab. Figma node 47:1248.
///
/// The backdrop is the centred card's artwork, so the whole screen shifts
/// colour as the carousel moves. The centred index lives in a [ValueNotifier]
/// rather than widget state on purpose: `setState` here would rebuild the
/// carousel and both genre strips on every page change, when only the backdrop
/// actually needs to repaint.
///
/// ⚠️ Reads [SampleMovies] — swap for the Home Bloc when the YTS layer lands.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ValueNotifier<int> _centeredIndex = ValueNotifier<int>(0);

  List<Movie> get _featured => SampleMovies.featured;

  @override
  void dispose() {
    _centeredIndex.dispose();
    super.dispose();
  }

  void _openMovie(Movie movie) {
    // TODO(phase-2): push Movie Details once that screen exists.
  }

  @override
  Widget build(BuildContext context) {
    // Tall enough to sit behind the wordmark and the whole carousel.
    final backdropHeight = 645.h;

    return Scaffold(
      body: Stack(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: _centeredIndex,
            builder: (context, index, _) => CarouselBackdrop(
              movie: _featured[index],
              height: backdropHeight,
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      AppAssets.availableNow,
                      width: 267.w,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  MovieCarousel(
                    movies: _featured,
                    onCentered: (index) => _centeredIndex.value = index,
                    onTap: _openMovie,
                  ),
                  SizedBox(height: 16.h),
                  Center(
                    child: Image.asset(AppAssets.watchNow, width: 354.w),
                  ),
                  SizedBox(height: 24.h),
                  GenreSection(
                    title: 'Action',
                    movies: SampleMovies.more,
                    onTapMovie: _openMovie,
                  ),
                  SizedBox(height: 24.h),
                  GenreSection(
                    title: 'Adventure',
                    movies: SampleMovies.more.reversed.toList(),
                    onTapMovie: _openMovie,
                  ),
                  // Clears the floating bottom bar so the last row is not
                  // trapped underneath it.
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
