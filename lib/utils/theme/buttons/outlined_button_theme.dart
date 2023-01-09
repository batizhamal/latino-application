import 'package:flutter/material.dart';
import 'package:latino_app/constants/color_codes.dart';

class MyOutlinedButtonTheme {
  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(mainDark),
      side: const BorderSide(
        color: Color(mainBlue),
      ),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData();
}
