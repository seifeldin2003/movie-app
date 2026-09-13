import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/network/network_status.dart';

void main() {
  test('starts optimistic', () {
    // Nothing has failed yet, so claiming offline before a single request
    // would put a badge on a perfectly healthy app.
    expect(NetworkStatus().isOffline, isFalse);
  });

  test('notifies only when the answer actually changes', () {
    final status = NetworkStatus();
    var notifications = 0;
    status.addListener(() => notifications++);

    status.report(isOffline: true);
    status.report(isOffline: true);
    status.report(isOffline: true);

    // ValueNotifier suppresses same-value writes, which matters here: every
    // request reports in, and a rebuild per request would be wasteful.
    expect(notifications, 1);
    expect(status.isOffline, isTrue);

    status.report(isOffline: false);
    expect(notifications, 2);
    expect(status.isOffline, isFalse);
  });

  test('is a ValueListenable, so a widget can watch it directly', () {
    expect(NetworkStatus(), isA<ValueListenable<bool>>());
  });
}
