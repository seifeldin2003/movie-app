import 'package:equatable/equatable.dart';

import '../../../../../core/bloc/request_status.dart';
import '../../../../movies/domain/entities/movie.dart';

/// One request here, not two, so a single status is enough.
///
/// [query] is kept on the state so the screen can tell "nothing typed yet"
/// (show the prompt) apart from "searched and found nothing" (show the
/// no-results message). Those read completely differently to a user, and
/// without the query both look like an empty list.
class SearchState extends Equatable {
  const SearchState({
    this.status = RequestStatus.initial,
    this.query = '',
    this.results = const [],
    this.error,
  });

  final RequestStatus status;
  final String query;
  final List<Movie> results;
  final String? error;

  SearchState copyWith({
    RequestStatus? status,
    String? query,
    List<Movie>? results,
    String? error,
    bool clearError = false,
  }) => SearchState(
    status: status ?? this.status,
    query: query ?? this.query,
    results: results ?? this.results,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [status, query, results, error];
}
