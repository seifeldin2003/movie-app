import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/routes/app_route_names.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

/// Root widget. `ScreenUtilInit` wraps `MaterialApp` so `.w` / `.h` / `.sp`
/// work everywhere below it.
class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: AppTheme.designSize,
      minTextAdapt: true,
      child: MaterialApp(
        title: 'Movie App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: AppRouteNames.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
