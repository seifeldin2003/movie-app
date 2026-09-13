/// What the trailer route needs to open.
///
/// A typed argument rather than a bare `String` so the router's type check
/// means something — `arguments is! String` would pass for any string in the
/// app, including a route name.
class MovieTrailerArgs {
  const MovieTrailerArgs({required this.imdbId, required this.title});

  /// `Movie.imdbCode` for the selected movie, e.g. `tt0798817`. Never
  /// hardcoded.
  final String imdbId;

  /// Shown in the app bar, so the screen names the film it is playing.
  final String title;
}
