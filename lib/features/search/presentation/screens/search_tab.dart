import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/movie_grid.dart';
import '../../../movies/data/sample_movies.dart';
import '../../../movies/domain/entities/movie.dart';

/// Search tab. Figma nodes 50:60 (empty) and 55:421 (results).
///
/// Filtering runs against the loaded catalogue rather than a request per
/// keystroke — the brief calls for searching the movie list by title, and it
/// keeps typing responsive.
///
/// ⚠️ Reads [SampleMovies] — swap for the Search Bloc when the YTS layer lands.
class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _queryController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<Movie> get _results {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return const [];

    return SampleMovies.all
        .where((movie) => movie.title.toLowerCase().contains(query))
        .toList();
  }

  Widget _buildBody() {
    if (_query.trim().isEmpty) {
      return const EmptyView(
        message: AppStrings.searchEmpty,
        imagePath: AppAssets.emptyState,
      );
    }

    final results = _results;
    if (results.isEmpty) {
      return const EmptyView(
        message: AppStrings.searchNoResults,
        imagePath: AppAssets.emptyState,
      );
    }

    return MovieGrid(movies: results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
              child: AppTextField(
                hintText: AppStrings.searchHint,
                controller: _queryController,
                onChanged: (value) => setState(() => _query = value),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.white,
                ),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }
}
