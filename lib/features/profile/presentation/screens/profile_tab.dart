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
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
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

  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Fetches the avatar choice so the header matches what was picked on
  /// Update Profile. A failure here is not worth interrupting the screen for —
  /// the header just falls back to the default illustration.
  Future<void> _loadProfile() async {
    final uid = getIt<AuthRepository>().currentUser?.uid;
    if (uid == null) return;

    try {
      final profile = await getIt<UserProfileRepository>().load(uid);
      if (!mounted) return;
      setState(() => _profile = profile);
    } catch (_) {
      // Deliberately ignored — see above.
    }
  }

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
              avatarId: _profile?.avatarId,
              photoBase64: _profile?.photoBase64,
              wishListCount: _watchList.length,
              historyCount: _history.length,
              // Re-read on the way back, so an avatar changed on the edit
              // screen is reflected here rather than going stale.
              onEditProfile: () async {
                await Navigator.pushNamed(
                  context,
                  AppRouteNames.updateProfile,
                );
                await _loadProfile();
              },
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
