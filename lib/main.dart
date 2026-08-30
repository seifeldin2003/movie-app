import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injector.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO(lead): once `flutterfire configure` has been run it generates
  // `lib/firebase_options.dart` — then uncomment these two lines. Until the
  // Firebase project exists the app still builds and runs; only the auth
  // calls fail.
  //
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  await setupInjector();

  runApp(const MovieApp());
}
