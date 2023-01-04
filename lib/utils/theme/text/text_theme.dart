import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latino_app/constants/color_codes.dart';

class MyTextTheme {
  static final lightTextTheme = TextTheme(
    headline1: GoogleFonts.montserrat(
      color: const Color(mainDark),
      fontSize: 32,
      fontWeight: FontWeight.bold,
    ),
    headline2: GoogleFonts.montserrat(
      color:const Color(mainDark),
      fontSize: 32,
    ),
    headline3: GoogleFonts.montserrat(
      color: const Color(mainDark),
      fontWeight: FontWeight.bold,
      fontSize: 18,
    ),
    headline4: GoogleFonts.montserrat(
      color: const Color(mainDark),
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ),
    headline5: GoogleFonts.montserrat(
      color: Colors.grey[500],
      fontSize: 18,
    ),
    bodyText1: GoogleFonts.montserrat(
      fontSize: 16,
    ),
  );

  static final darkTextTheme = TextTheme();
}
