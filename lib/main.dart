import 'package:flutter/material.dart';
import 'package:latino_app/auth/auth_page.dart';
import 'package:latino_app/pages/home.dart';
import 'package:latino_app/pages/splash_screen.dart';
import 'package:latino_app/utils/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
      theme: MyAppTheme.lightTheme,
      darkTheme: MyAppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
