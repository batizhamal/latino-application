import 'package:flutter/material.dart';
import 'package:latino_app/constants/color_codes.dart';

class MyElevatedButtonTheme {
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(mainRed),
      elevation: 0,
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData();
}
