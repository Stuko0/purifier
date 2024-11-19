import 'package:flutter/material.dart';
import 'package:purifier/src/sample_feature/screen_splash.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme:  ThemeData.from(colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromRGBO(32, 63, 129, 1.0))),
      home: const ScreenSplash(),
    );
  }
}
