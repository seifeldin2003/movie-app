import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/bloc/request_status.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/routes/app_route_names.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../movies/domain/entities/movie.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_event.dart';
import '../bloc/home/home_state.dart';
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
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ValueNotifier<int> _centeredIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _centeredIndex.dispose();
    super.dispose();
  }

  void _openMovie(Movie movie) {
    Navigator.pushNamed(
      context,
      AppRouteNames.movieDetails,
      arguments: movie,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      // `create` runs once, not per rebuild — this is what replaces initState
      // for kicking off the first load.
      create: (_) => getIt<HomeBloc>()..add(const HomeStarted()),
      child: Scaffold(
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            // Loading -> error -> data. The carousel drives the backdrop, so
            // there is nothing to draw at all until it has something.
            if (state.featured.isEmpty) {
              if (state.featuredStatus.isError) {
                return ErrorView(
                  message: state.featuredError ?? AppStrings.somethingWentWrong,
                  onRetry: () =>
                      context.read<HomeBloc>().add(const HomeRetried()),
                );
              }
              return const LoadingView();
            }

            return _HomeContent(
              state: state,
              centeredIndex: _centeredIndex,
              onTapMovie: _openMovie,
            );
          },
        ),
      ),
    );
  }
}

/// The loaded screen: backdrop, carousel and the genre rows.
class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.state,
    required this.centeredIndex,
    required this.onTapMovie,
  });

  final HomeState state;
  final ValueNotifier<int> centeredIndex;
  final ValueChanged<Movie> onTapMovie;

  @override
  Widget build(BuildContext context) {
    // Tall enough to sit behind the wordmark and the whole carousel.
    final backdropHeight = 645.h;
    final featured = state.featured;

    return Stack(
      children: [
        ValueListenableBuilder<int>(
          valueListenable: centeredIndex,
          builder: (context, index, _) => CarouselBackdrop(
            // Clamped rather than indexed directly: a retry can come back with
            // a shorter list while the notifier still holds the old position,
            // and that would throw instead of just showing the last card.
            movie: featured[index.clamp(0, featured.length - 1)],
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
                  child: Image.asset(AppAssets.availableNow, width: 267.w),
                ),
                SizedBox(height: 8.h),
                MovieCarousel(
                  movies: featured,
                  onCentered: (index) => centeredIndex.value = index,
                  onTap: onTapMovie,
                ),
                SizedBox(height: 16.h),
                Center(child: Image.asset(AppAssets.watchNow, width: 354.w)),
                SizedBox(height: 24.h),

                // The rows have their own status, so they can still be
                // arriving while the carousel above them is already usable —
                // and if they fail outright they simply do not appear rather
                // than taking a working screen down.
                if (state.sectionsStatus.isLoading)
                  SizedBox(height: 200.h, child: const LoadingView()),
                for (final section in state.sections) ...[
                  GenreSection(
                    title: section.title,
                    movies: section.movies,
                    onTapMovie: onTapMovie,
                  ),
                  SizedBox(height: 24.h),
                ],

                // Clears the floating bottom bar so the last row is not
                // trapped underneath it.
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
