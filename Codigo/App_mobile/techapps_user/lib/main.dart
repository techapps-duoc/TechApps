import 'package:flutter/material.dart';
import 'package:techapps_user/config/router/app_router.dart';
import 'package:techapps_user/config/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      //theme: AppsTheme.blue,
    );
  }
}
