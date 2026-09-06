import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/routes/app_route_names.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/movie_grid.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../movies/data/sample_movies.dart';
import '../../../movies/domain/entities/movie.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_tab_bar.dart';

/// Profile tab. Figma nodes 51:511 (empty) and 55:633 (populated).
///
/// ⚠️ The two lists read [SampleMovies] — the watch list comes from Firestore
/// and the history from local storage once those land. The signed-in name is
/// already real.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  ProfileSection _section = ProfileSection.watchList;

  List<Movie> get _watchList => SampleMovies.featured;

  List<Movie> get _history => SampleMovies.more;

  List<Movie> get _visibleMovies =>
      _section == ProfileSection.watchList ? _watchList : _history;

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
    final movies = _visibleMovies;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: 16.h),
            ProfileHeader(
              name: user?.name ?? user?.email ?? '',
              wishListCount: _watchList.length,
              historyCount: _history.length,
              onEditProfile: () => Navigator.pushNamed(
                context,
                AppRouteNames.updateProfile,
              ),
              onExit: _onExit,
            ),
            SizedBox(height: 16.h),
            ProfileTabBar(
              selected: _section,
              onChanged: (section) => setState(() => _section = section),
            ),
            Expanded(
              child: movies.isEmpty
                  ? EmptyView(
                      message: _section == ProfileSection.watchList
                          ? AppStrings.watchListEmpty
                          : AppStrings.historyEmpty,
                      imagePath: AppAssets.emptyState,
                    )
                  : MovieGrid(movies: movies, crossAxisCount: 3),
            ),
          ],
        ),
      ),
    );
  }
}
