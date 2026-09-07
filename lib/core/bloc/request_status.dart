/// The phase of one async request.
///
/// Shared because every data-driven screen needs it, and because a screen that
/// runs two requests at once needs *two* of them. A state class can only have
/// one type, so it can never be both `DetailsLoaded` and `SimilarLoading` —
/// two enum fields on one state object can.
///
/// Pair it with `copyWith`: emitting a change to one status leaves the other
/// untouched, which is what keeps already-loaded content on screen while
/// something else reloads underneath it.
enum RequestStatus { initial, loading, success, error }

extension RequestStatusX on RequestStatus {
  bool get isInitial => this == RequestStatus.initial;
  bool get isLoading => this == RequestStatus.loading;
  bool get isSuccess => this == RequestStatus.success;
  bool get isError => this == RequestStatus.error;
}
