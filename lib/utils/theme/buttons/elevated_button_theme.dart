import 'package:flutter/material.dart';
import 'package:latino_app/constants/color_codes.dart';

class MyElevatedButtonTheme {
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(mainRed),
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData();
}
