import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/bloc/request_status.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/movie_grid.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../movies/domain/entities/movie.dart';
import '../../../movies/domain/entities/movie_details.dart';
import '../bloc/movie_details/movie_details_bloc.dart';
import '../bloc/movie_details/movie_details_event.dart';
import '../bloc/movie_details/movie_details_state.dart';
import '../widgets/cast_row.dart';
import '../widgets/details_hero.dart';
import '../widgets/genre_tag.dart';
import '../widgets/movie_badge_row.dart';
import '../widgets/screenshot_strip.dart';
import '../widgets/section_heading.dart';

/// Movie Details. Figma node 52:641.
///
/// Section order follows the design, which puts Similar above Summary and
/// Cast rather than at the end.
///
/// The design draws the back and watchlist controls floating on the artwork
/// at a fixed y, but that frame has no status bar — on a real phone they land
/// under the notch, and they scroll away entirely. A pinned [SliverAppBar]
/// keeps them reachable and brings the title down into the bar once the
/// artwork has scrolled past.
///
/// **The artwork does not wait for the network.** [movie] arrives from the
/// list that was tapped, so the poster, title, year and rating are already in
/// hand — the hero paints on the first frame and only the sections below it
/// are driven by the Bloc. A full-screen spinner over a poster we already have
/// would be slower for no reason.
class MovieDetailsScreen extends StatefulWidget {
  const MovieDetailsScreen({super.key, required this.movie});

  final Movie movie;

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  void _openMovie(Movie movie) {
    // Replace rather than push: walking Similar -> Similar -> Similar would
    // otherwise stack detail screens without bound.
    Navigator.pushReplacementNamed(
      context,
      ModalRoute.of(context)!.settings.name!,
      arguments: movie,
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    // Leaves the Watch button and badges visible without scrolling. The
    // design's 645 of 932 would push them off a shorter screen.
    final heroHeight = 460.h;

    return BlocProvider<MovieDetailsBloc>(
      // `create` runs once, not on every rebuild — this is what replaces
      // initState for kicking the first request off.
      create: (_) =>
          getIt<MovieDetailsBloc>()..add(MovieDetailsRequested(movie)),
      child: Scaffold(
        body: BlocConsumer<MovieDetailsBloc, MovieDetailsState>(
          // Only when a *new* failure arrives. Without the guard every
          // unrelated emit — the record landing, the suggestions landing —
          // would raise the same snack bar again.
          listenWhen: (previous, current) =>
              previous.watchListError != current.watchListError &&
              current.watchListError != null,
          listener: (context, state) => AppSnackBar.show(
            context,
            state.watchListError!,
            isError: true,
          ),
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: heroHeight,
                  backgroundColor: AppColors.background,
                  // The artwork provides its own contrast; a tint over it
                  // would muddy the poster.
                  surfaceTintColor: Colors.transparent,
                  leadingWidth: 64.w,
                  leading: HeroIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
                  actions: [
                    HeroIconButton(
                      // Driven by the state, not by a local flag: what the
                      // control shows has to be what Firestore holds, and a
                      // failed write has to be able to put it back.
                      icon: state.isInWatchList
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      onTap: () => context.read<MovieDetailsBloc>().add(
                        MovieDetailsWatchlistToggled(movie),
                      ),
                    ),
                    SizedBox(width: 16.w),
                  ],
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      final collapsedHeight =
                          kToolbarHeight + MediaQuery.paddingOf(context).top;

                      // How far collapsed, 0 (expanded) to 1 (pinned). Fading
                      // on this rather than flipping at a threshold matters:
                      // the artwork carries its own title, and a hard switch
                      // left a stretch mid-scroll where the artwork's title
                      // had gone but the bar's had not arrived, so the screen
                      // had no title at all.
                      final progress =
                          ((heroHeight - constraints.maxHeight) /
                                  (heroHeight - collapsedHeight))
                              .clamp(0.0, 1.0);

                      return FlexibleSpaceBar(
                        centerTitle: true,
                        titlePadding: EdgeInsets.symmetric(
                          horizontal: 56.w,
                          vertical: 14.h,
                        ),
                        title: Opacity(
                          opacity: progress,
                          child: Text(
                            movie.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.titleMedium,
                          ),
                        ),
                        background: DetailsHero(
                          // The loaded record carries the full-size backdrop;
                          // until it lands the list's own artwork stands in,
                          // so the hero is never empty.
                          movie: state.details?.movie ?? movie,
                          // Mirrors the bar: the artwork's own caption fades
                          // out as the bar's fades in, so exactly one is
                          // legible at a time.
                          captionOpacity: 1 - progress,
                          onPlay: () {
                            // TODO(phase-2): open the player once the Watch
                            // source is decided.
                          },
                        ),
                      );
                    },
                  ),
                ),
                _DetailsBody(
                  fallbackMovie: movie,
                  state: state,
                  onTapMovie: _openMovie,
                  onRetry: () => context.read<MovieDetailsBloc>().add(
                    MovieDetailsRetried(movie),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Everything under the artwork.
///
/// Split out because the app bar above it never changes with the request — it
/// draws from the movie that was tapped — so only this part needs rebuilding
/// when a state arrives.
class _DetailsBody extends StatelessWidget {
  const _DetailsBody({
    required this.fallbackMovie,
    required this.state,
    required this.onTapMovie,
    required this.onRetry,
  });

  /// The record from the list, used before the full one arrives.
  final Movie fallbackMovie;
  final MovieDetailsState state;
  final ValueChanged<Movie> onTapMovie;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final details = state.details;

    // Loading -> error -> empty -> data, in that order. Skipping any of the
    // first three is the most common bug on a screen like this.
    if (details == null) {
      if (state.detailsStatus.isError) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(
            message: state.detailsError ?? AppStrings.somethingWentWrong,
            onRetry: onRetry,
          ),
        );
      }

      // Covers `initial` and `loading` alike: both mean "nothing to draw yet".
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingView(),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          child: PrimaryButton(
            text: AppStrings.watch,
            onPressed: () {
              // TODO(phase-2): same destination as the play button.
            },
          ),
        ),
        MovieBadgeRow(details: details),

        if (details.screenshots.isNotEmpty) ...[
          const SectionHeading(AppStrings.screenShots),
          ScreenshotStrip(screenshots: details.screenshots),
        ],

        ..._similarSection(details),

        if (details.descriptionFull != null &&
            details.descriptionFull!.isNotEmpty) ...[
          const SectionHeading(AppStrings.summary),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              details.descriptionFull!,
              style: AppTextStyles.bodyReadable,
            ),
          ),
        ],

        if (details.cast.isNotEmpty) ...[
          const SectionHeading(AppStrings.cast),
          for (final member in details.cast) CastRow(member: member),
        ],

        ..._genresSection(details),

        SizedBox(height: 32.h),
      ]),
    );
  }

  /// Similar has its own status, so it can still be loading while everything
  /// above it is already on screen — and it drops out silently if suggestions
  /// fail, rather than taking a perfectly good page down with it.
  List<Widget> _similarSection(MovieDetails details) {
    if (state.similarStatus.isLoading) {
      return [
        const SectionHeading(AppStrings.similar),
        SizedBox(height: 160.h, child: const LoadingView()),
      ];
    }

    if (state.similar.isEmpty) return const [];

    return [
      const SectionHeading(AppStrings.similar),
      MovieGrid(
        movies: state.similar,
        // Inside a scroll view already, so the grid must not scroll on its
        // own.
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        onTapMovie: onTapMovie,
      ),
    ];
  }

  List<Widget> _genresSection(MovieDetails details) {
    // The details record is the fuller one, but it can come back with an
    // empty list where the list endpoint had genres, so fall back rather than
    // dropping the section.
    final genres = details.movie.genres.isNotEmpty
        ? details.movie.genres
        : fallbackMovie.genres;

    if (genres.isEmpty) return const [];

    return [
      const SectionHeading(AppStrings.genres),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: [for (final genre in genres) GenreTag(genre)],
        ),
      ),
    ];
  }
}
