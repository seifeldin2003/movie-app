import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/app.dart';

void main() {
  testWidgets('app boots to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MovieApp());

    // The splash screen is the initial route.
    expect(find.text('Splash — TODO'), findsOneWidget);
  });
}
