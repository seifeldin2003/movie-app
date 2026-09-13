import 'package:flutter/foundation.dart';

/// Whether the last request reached the server.
///
/// ⚠️ Reactive on purpose, and deliberately not a connectivity package.
/// `MovieRepositoryImpl` already makes the argument: checking connectivity up
/// front is a race, and the OS only knows whether an interface is *up* — a
/// phone on wifi with no route, or an ISP blocking the mirror
/// (`ApiEndpoints.baseUrl`), reports itself online while every request fails.
/// The request outcome is the only thing that actually knows.
///
/// The cost of that honesty: this is `false` until something has been tried.
/// That is the right trade for an indicator whose whole job is to explain why
/// the screen is showing older data.
///
/// A [ValueNotifier] rather than a Bloc because it is infrastructure, not
/// screen state — the same shape the house style already prescribes for an
/// offline fallback — and because one icon should rebuild, not a tab.
class NetworkStatus extends ValueNotifier<bool> {
  NetworkStatus() : super(false);

  bool get isOffline => value;

  /// Called from `ApiClient` on every completed request, either way.
  void report({required bool isOffline}) => value = isOffline;
}
