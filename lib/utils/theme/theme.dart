import 'package:flutter/material.dart';
import 'package:latino_app/constants/color_swatches.dart';
import 'package:latino_app/utils/theme/buttons/elevated_button_theme.dart';
import 'package:latino_app/utils/theme/buttons/outlined_button_theme.dart';
import 'package:latino_app/utils/theme/text/text_theme.dart';

class MyAppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: mainDarkSwatch,
    textTheme: MyTextTheme.lightTextTheme,
    outlinedButtonTheme: MyOutlinedButtonTheme.lightOutlinedButtonTheme,
    elevatedButtonTheme: MyElevatedButtonTheme.lightElevatedButtonTheme,
  );
  static ThemeData darkTheme = ThemeData(
    textTheme: MyTextTheme.darkTextTheme,
    outlinedButtonTheme: MyOutlinedButtonTheme.darkOutlinedButtonTheme,
    elevatedButtonTheme: MyElevatedButtonTheme.darkElevatedButtonTheme,
  );
}
