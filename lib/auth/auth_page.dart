import 'package:flutter/material.dart';
import 'package:latino_app/pages/login.dart';
import 'package:latino_app/pages/register.dart';

class AuthPage extends StatefulWidget {
  final bool showLoginPage;
  const AuthPage({super.key, required this.showLoginPage});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // initially, show the login page
  bool showLoginPage = true;

  @override
  void initState() {
    showLoginPage = widget.showLoginPage;
    super.initState();
  }

  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(showRegisterPage: toggleScreens);
    } else {
      return RegisterPage(showLoginPage: toggleScreens);
    }
  }
}
