import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/request_status.dart';
import '../../../../movies/domain/entities/movie.dart';
import '../../../../movies/domain/entities/movie_section.dart';

/// Two statuses again, for the same reason as Movie Details: the carousel and
/// the genre rows are separate requests that finish at different times.
///
/// Here it matters even more, because the carousel drives the screen's
/// backdrop. Tying the rows to the same status would blank the artwork every
/// time a row reloaded.
class HomeState extends Equatable {
  const HomeState({
    this.featuredStatus = RequestStatus.initial,
    this.featured = const [],
    this.featuredError,
    this.sectionsStatus = RequestStatus.initial,
    this.sections = const [],
    this.sectionsError,
  });

  final RequestStatus featuredStatus;
  final List<Movie> featured;
  final String? featuredError;

  final RequestStatus sectionsStatus;
  final List<MovieSection> sections;
  final String? sectionsError;

  HomeState copyWith({
    RequestStatus? featuredStatus,
    List<Movie>? featured,
    String? featuredError,
    RequestStatus? sectionsStatus,
    List<MovieSection>? sections,
    String? sectionsError,
    bool clearErrors = false,
  }) => HomeState(
    featuredStatus: featuredStatus ?? this.featuredStatus,
    featured: featured ?? this.featured,
    featuredError: clearErrors ? null : (featuredError ?? this.featuredError),
    sectionsStatus: sectionsStatus ?? this.sectionsStatus,
    sections: sections ?? this.sections,
    sectionsError: clearErrors ? null : (sectionsError ?? this.sectionsError),
  );

  @override
  List<Object?> get props => [
    featuredStatus,
    featured,
    featuredError,
    sectionsStatus,
    sections,
    sectionsError,
  ];
}
