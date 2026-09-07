import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/bloc/request_status.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_genres.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/routes/app_route_names.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/genre_chip.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/movie_grid.dart';
import '../../../movies/domain/entities/movie.dart';
import '../bloc/browse/browse_bloc.dart';
import '../bloc/browse/browse_event.dart';
import '../bloc/browse/browse_state.dart';

/// Browse tab. Figma node 50:462.
///
/// A scrolling row of genre chips over the matching posters. Each chip is a
/// `list_movies.json?genre=` request, so the grid shows the real catalogue for
/// that genre rather than whatever happens to be loaded.
///
/// The chip list is a fixed constant, not folded out of the loaded movies with
/// a `Set` as the brief first suggested — see [AppGenres] for why.
class BrowseTab extends StatefulWidget {
  const BrowseTab({super.key});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  /// Keeps the chip row from snapping back to the left when the grid under it
  /// reloads.
  final ScrollController _chipController = ScrollController();

  @override
  void dispose() {
    _chipController.dispose();
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
    return BlocProvider<BrowseBloc>(
      create: (_) => getIt<BrowseBloc>()..add(const BrowseStarted()),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<BrowseBloc, BrowseState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: AppTheme.chipHeight.h + 32.h,
                    child: ListView.separated(
                      controller: _chipController,
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      itemCount: AppGenres.all.length,
                      separatorBuilder: (_, _) => SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final genre = AppGenres.all[index];
                        return GenreChip(
                          label: genre,
                          isSelected: genre == state.selectedGenre,
                          onTap: () => context.read<BrowseBloc>().add(
                            BrowseGenreSelected(genre),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _BrowseResults(
                      state: state,
                      onTapMovie: _openMovie,
                      onRetry: () => context.read<BrowseBloc>().add(
                        BrowseGenreSelected(state.selectedGenre),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrowseResults extends StatelessWidget {
  const _BrowseResults({
    required this.state,
    required this.onTapMovie,
    required this.onRetry,
  });

  final BrowseState state;
  final ValueChanged<Movie> onTapMovie;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Loading -> error -> empty -> data, in that order.
    if (state.status.isLoading || state.status.isInitial) {
      return const LoadingView();
    }

    if (state.status.isError) {
      return ErrorView(
        message: state.error ?? AppStrings.somethingWentWrong,
        onRetry: onRetry,
      );
    }

    if (state.movies.isEmpty) {
      // Rare on the real catalogue — every genre has thousands — but a
      // successful request that returned nothing must not look like a
      // failure.
      return const EmptyView(
        message: AppStrings.searchNoResults,
        imagePath: AppAssets.emptyState,
      );
    }

    return MovieGrid(
      movies: state.movies,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
      onTapMovie: onTapMovie,
    );
  }
}
