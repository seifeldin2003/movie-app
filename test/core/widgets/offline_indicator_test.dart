import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/widgets/offline_indicator.dart';

void main() {
  Future<void> pumpIndicator(
    WidgetTester tester,
    ValueNotifier<bool> status,
  ) async {
    // ⚠️ ScreenUtilInit, or `.w`/`.h`/`.r` do not resolve in a test.
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(430, 932),
        child: MaterialApp(
          home: Scaffold(body: OfflineIndicator(status: status)),
        ),
      ),
    );
  }

  testWidgets('shows nothing while online', (tester) async {
    await pumpIndicator(tester, ValueNotifier(false));

    expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
  });

  testWidgets('appears when the app goes offline', (tester) async {
    final status = ValueNotifier(false);
    await pumpIndicator(tester, status);

    status.value = true;
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
  });

  testWidgets('disappears again when a request succeeds', (tester) async {
    final status = ValueNotifier(true);
    await pumpIndicator(tester, status);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);

    status.value = false;
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.cloud_off_rounded), findsNothing);
  });
}
