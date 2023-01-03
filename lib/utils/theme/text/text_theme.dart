import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latino_app/constants/color_codes.dart';

class MyTextTheme {
  static final lightTextTheme = TextTheme(
    headline1: GoogleFonts.montserrat(
      color: Color(mainDark),
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headline2: GoogleFonts.montserrat(
      color: Color(mainDark),
      fontSize: 32,
    ),
    bodyText1: GoogleFonts.montserrat(
      fontSize: 16,
    ),
  );

  static final darkTextTheme = TextTheme();
}
