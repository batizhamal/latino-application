import 'package:flutter/material.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/constants/image_strings.dart';
import 'package:latino_app/pages/home/home.dart';
import 'package:latino_app/pages/welcome_screen.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(lightBlue),
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: 1600),
              top: animate ? 120 : 90,
              left: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latino Parties',
                    style: Theme.of(context).textTheme.headline2,
                  ),
                  Text(
                    'Plan events. \nCompletely free',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 1600),
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
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      animate = true;
    });

    // after 5 seconds go to WelcomPage
    await Future.delayed(Duration(milliseconds: 5000));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => WelcomePage(),
      ),
    );
  }
}
