import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/movie_details_model.dart';
import '../models/movie_model.dart';

/// The failure path: real YTS responses captured with `curl` and bundled into
/// the app, so a device with no connection still shows a catalogue instead of
/// an error screen.
///
/// ⚠️ DEMO SCAFFOLDING. These files are a snapshot, not a cache — they never
/// change and they ship with the build. They exist so the app degrades to
/// something watchable rather than to a blank page. A production app would
/// use a real on-disk cache of what the user actually browsed.
///
/// Re-capture with:
///     curl -s "`<base>`/list_movies.json?sort_by=download_count&minimum_rating=7&limit=20"
class MovieLocalDataSource {
  const MovieLocalDataSource();

  static const String _listPath = 'assets/data/list_movies.json';
  static const String _detailsPath = 'assets/data/movie_details.json';
  static const String _suggestionsPath = 'assets/data/movie_suggestions.json';

  Future<List<MovieModel>> listMovies() async =>
      MovieModel.listFrom(await _read(_listPath));

  Future<MovieDetailsModel?> movieDetails() async =>
      MovieDetailsModel.from(await _read(_detailsPath));

  Future<List<MovieModel>> movieSuggestions() async =>
      MovieModel.listFrom(await _read(_suggestionsPath));

  /// Unwraps `data` the same way [ApiClient.get] does, so both data sources
  /// hand the models an identically-shaped map.
  ///
  /// Returns an empty map rather than throwing if an asset is missing: this
  /// is already the fallback, and a fallback that throws leaves the user with
  /// nothing at all.
  Future<Map<String, dynamic>> _read(String path) async {
    try {
      final body = jsonDecode(await rootBundle.loadString(path));
      if (body is! Map<String, dynamic>) return const {};

      final data = body['data'];
      return data is Map<String, dynamic> ? data : const {};
    } catch (_) {
      return const {};
    }
  }
}
