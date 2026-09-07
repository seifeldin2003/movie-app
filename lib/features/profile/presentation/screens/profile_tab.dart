import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/bloc/request_status.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/routes/app_route_names.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/movie_grid.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../movies/domain/entities/movie.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_tab_bar.dart';

/// Profile tab. Figma nodes 51:511 (empty) and 55:633 (populated).
///
/// The Watch List comes from Firestore and the History from on-device
/// storage — neither is YTS, which is why this screen has its own Bloc rather
/// than sharing the movies one.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  /// Which tab is showing is pure view state — it triggers no request, so it
  /// stays here rather than going through the Bloc.
  ProfileSection _section = ProfileSection.watchList;

  /// Held here rather than created inline in `build` so `dispose` can close
  /// it — the two live subscriptions it owns end with it.
  late final ProfileBloc _bloc = getIt<ProfileBloc>()
    ..add(const ProfileStarted());

  @override
  void dispose() {
    // Ours to close: it was resolved here, not by a `BlocProvider` that would
    // have closed it for us.
    _bloc.close();
    super.dispose();
  }

  /// Nothing happens on the way back on purpose: both lists are live, so a
  /// bookmark toggled on Details and the history entry that opening it wrote
  /// have already arrived here on their own.
  void _openMovie(Movie movie) => Navigator.pushNamed(
    context,
    AppRouteNames.movieDetails,
    arguments: movie,
  );

  Future<void> _onExit() async {
    await getIt<AuthRepository>().logout();
    if (!mounted) return;

    // Drop the whole stack — the tabs behind this one belong to a session
    // that no longer exists.
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouteNames.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = getIt<AuthRepository>().currentUser;

    return BlocProvider<ProfileBloc>.value(
      value: _bloc,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final bloc = context.read<ProfileBloc>();

              return Column(
                children: [
                  SizedBox(height: 16.h),
                  ProfileHeader(
                    name: user?.name ?? user?.email ?? '',
                    avatarId: state.profile?.avatarId,
                    photoBase64: state.profile?.photoBase64,
                    wishListCount: state.watchList.length,
                    historyCount: state.history.length,
                    // Re-read on the way back, so an avatar changed on the
                    // edit screen is reflected here rather than going stale.
                    onEditProfile: () async {
                      await Navigator.pushNamed(
                        context,
                        AppRouteNames.updateProfile,
                      );
                      if (!context.mounted) return;
                      bloc.add(const ProfileRefreshed());
                    },
                    onExit: _onExit,
                  ),
                  SizedBox(height: 16.h),
                  ProfileTabBar(
                    selected: _section,
                    onChanged: (section) => setState(() => _section = section),
                  ),
                  Expanded(
                    child: _ProfileMovies(
                      state: state,
                      section: _section,
                      onTapMovie: _openMovie,
                      // Re-subscribes rather than refreshing: a Firestore
                      // stream that errors is finished, so the listener has
                      // to be opened again, not prodded.
                      onRetry: () =>
                          bloc.add(const ProfileWatchlistSubscribed()),
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

/// The grid under the tab bar — whichever list the selected tab shows.
class _ProfileMovies extends StatelessWidget {
  const _ProfileMovies({
    required this.state,
    required this.section,
    required this.onTapMovie,
    required this.onRetry,
  });

  final ProfileState state;
  final ProfileSection section;
  final ValueChanged<Movie> onTapMovie;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isWatchList = section == ProfileSection.watchList;

    final status = isWatchList ? state.watchListStatus : state.historyStatus;
    final movies = isWatchList ? state.watchList : state.history;

    // Loading -> error -> empty -> data. History has no error branch of its
    // own because its store cannot fail yet; it falls through to the same
    // empty state.
    if (status.isLoading || status.isInitial) return const LoadingView();

    if (isWatchList && status.isError) {
      return ErrorView(
        message: state.watchListError ?? AppStrings.somethingWentWrong,
        onRetry: onRetry,
      );
    }

    if (movies.isEmpty) {
      return EmptyView(
        message: isWatchList
            ? AppStrings.watchListEmpty
            : AppStrings.historyEmpty,
        imagePath: AppAssets.emptyState,
      );
    }

    return MovieGrid(
      movies: movies,
      crossAxisCount: 3,
      onTapMovie: onTapMovie,
    );
  }
}
