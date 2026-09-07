/// The genre names YTS accepts on `list_movies.json?genre=`.
///
/// Hardcoded rather than folded out of the loaded catalogue with a `Set`,
/// which is what the brief originally suggested. That approach only sees the
/// genres present in the 20 movies on the current page, so the chip row would
/// change every time Browse reloaded — and it can never offer a genre that
/// happens to be missing from page one. YTS uses IMDb's fixed list, so this
/// is the complete, stable set.
class AppGenres {
  const AppGenres._();

  /// Every genre the API will filter on.
  static const List<String> all = [
    'Action',
    'Adventure',
    'Animation',
    'Biography',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Musical',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Sport',
    'Thriller',
    'War',
    'Western',
  ];

  /// The chip Browse opens on.
  static const String defaultGenre = 'Action';

  /// The rows under the Home carousel. Two, because the design shows two and
  /// each one costs a request.
  static const List<String> homeRows = ['Action', 'Adventure'];
}
