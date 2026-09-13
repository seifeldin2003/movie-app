import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:movie_app/core/bloc/request_status.dart';
import 'package:movie_app/core/constants/app_genres.dart';
import 'package:movie_app/core/constants/app_strings.dart';
import 'package:movie_app/core/di/injector.dart';
import 'package:movie_app/core/routes/app_route_names.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/empty_view.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/core/widgets/genre_chip.dart';
import 'package:movie_app/core/widgets/loading_view.dart';
import 'package:movie_app/core/widgets/movie_grid.dart';
import 'package:movie_app/core/movies/domain/entities/movie.dart';
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
  const BrowseTab({super.key, this.bloc});

  /// Supplied by [LayoutScreen] so "See More" on Home can change the genre
  /// from outside this tab.
  ///
  /// ⚠️ Optional, and it must stay optional. Without one this tab owns its own
  /// Bloc exactly as before, which is what lets a widget test pump a bare
  /// `BrowseTab()` with no shell around it.
  ///
  /// When it *is* supplied, the owner also starts it and closes it — this tab
  /// only reads it.
  final BrowseBloc? bloc;

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  /// Keeps the chip row from snapping back to the left when the grid under it
  /// reloads.
  final ScrollController _chipController = ScrollController();

  /// Only created when no Bloc was handed in. Ours to close in that case —
  /// `BlocProvider.value` never closes what it is given.
  BrowseBloc? _ownBloc;

  @override
  void dispose() {
    _ownBloc?.close();
    _chipController.dispose();
    super.dispose();
  }

  void _openMovie(Movie movie) {
    Navigator.pushNamed(context, AppRouteNames.movieDetails, arguments: movie);
  }

  @override
  Widget build(BuildContext context) {
    final bloc = widget.bloc;

    return BlocProvider<BrowseBloc>.value(
      // `.value` when the Bloc came from outside, because closing someone
      // else's Bloc is how a tab switch ends up emitting after close.
      value:
          bloc ??
          (_ownBloc ??= getIt<BrowseBloc>()..add(const BrowseStarted())),
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
      return const EmptyView(message: AppStrings.searchNoResults);
    }

    return MovieGrid(
      movies: state.movies,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
      onTapMovie: onTapMovie,
    );
  }
}
