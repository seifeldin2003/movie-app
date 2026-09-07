import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/bloc/request_status.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/routes/app_route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/movie_grid.dart';
import '../../../movies/domain/entities/movie.dart';
import '../bloc/search/search_bloc.dart';
import '../bloc/search/search_event.dart';
import '../bloc/search/search_state.dart';

/// Search tab. Figma nodes 50:60 (empty) and 55:421 (results).
///
/// Searches the API, not a list in memory. An earlier version filtered a
/// loaded catalogue and its comment called that deliberate — which was fair
/// against eleven placeholder movies and wrong against 77,000: only the 20 on
/// the current page would ever match.
///
/// The debounce lives here rather than in the Bloc. How fast someone types is
/// a property of this text field, and a `Timer` reads at a glance where a
/// stream transformer would not.
class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _queryController = TextEditingController();

  /// Long enough that a normal typing speed sends one request instead of one
  /// per letter, short enough not to feel laggy.
  static const Duration _debounce = Duration(milliseconds: 400);

  Timer? _debounceTimer;

  @override
  void dispose() {
    // Without this a pending timer fires after the screen is gone and adds an
    // event to a closed Bloc.
    _debounceTimer?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  void _onQueryChanged(SearchBloc bloc, String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () => bloc.add(SearchQueryChanged(value)));
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
    return BlocProvider<SearchBloc>(
      create: (_) => getIt<SearchBloc>(),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                    child: AppTextField(
                      hintText: AppStrings.searchHint,
                      controller: _queryController,
                      onChanged: (value) =>
                          _onQueryChanged(context.read<SearchBloc>(), value),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _SearchResults(
                      state: state,
                      onTapMovie: _openMovie,
                      onRetry: () => context.read<SearchBloc>().add(
                        SearchQueryChanged(state.query),
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

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.state,
    required this.onTapMovie,
    required this.onRetry,
  });

  final SearchState state;
  final ValueChanged<Movie> onTapMovie;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Nothing typed yet. Checked before the status so an idle screen shows the
    // prompt rather than the no-results message.
    if (state.query.isEmpty) {
      return const EmptyView(
        message: AppStrings.searchEmpty,
      );
    }

    if (state.status.isLoading) return const LoadingView();

    if (state.status.isError) {
      return ErrorView(
        message: state.error ?? AppStrings.somethingWentWrong,
        onRetry: onRetry,
      );
    }

    if (state.results.isEmpty) {
      return const EmptyView(
        message: AppStrings.searchNoResults,
      );
    }

    return MovieGrid(movies: state.results, onTapMovie: onTapMovie);
  }
}
