import 'package:equatable/equatable.dart';

sealed class BrowseEvent extends Equatable {
  const BrowseEvent();

  @override
  List<Object?> get props => const [];
}

/// Load the first genre.
class BrowseStarted extends BrowseEvent {
  const BrowseStarted();
}

/// A chip was tapped.
class BrowseGenreSelected extends BrowseEvent {
  const BrowseGenreSelected(this.genre);

  final String genre;

  @override
  List<Object?> get props => [genre];
}
