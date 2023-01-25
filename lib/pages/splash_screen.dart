import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/constants/image_strings.dart';
import 'package:latino_app/pages/home/home.dart';
import 'package:latino_app/pages/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool animate = false;

  @override
  void initState() {
    startAnimation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(lightBlue),
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1600),
              top: animate ? 120 : 90,
              left: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latino Parties',
                    style: GoogleFonts.montserrat(
                      color: const Color(mainDark),
                      fontSize: 24.0 * textScale,
                    ),
                  ),
                  Text(
                    'Планируйте\nмероприятия с нами.',
                    style: GoogleFonts.montserrat(
                      color: const Color(mainDark),
                      fontSize: 24.0 * textScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 1600),
              bottom: animate ? 0 : -50,
              right: 30,
              child: Image.asset(
                planning,
                width: 400,
                height: 400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      animate = true;
    });

    // after 5 seconds go to WelcomPage
    await Future.delayed(const Duration(milliseconds: 5000));

    bool isLoggedIn = false;

    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();

    if (sharedPreferences != null) {
      var expiryDate = sharedPreferences.getString('expiryDate');
      if (expiryDate != null) {
        isLoggedIn = DateTime.parse(expiryDate).isAfter(DateTime.now());
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return isLoggedIn ? const HomePage() : const WelcomePage();
        },
      ),
    );
  }
}
