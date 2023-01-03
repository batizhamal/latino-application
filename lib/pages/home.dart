import 'package:flutter/material.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/pages/profile/profile.dart';
import 'package:latino_app/pages/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    checkLoginStatus();
  }

  checkLoginStatus() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    print(sharedPreferences.getString("token"));

    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => WelcomePage()),
          (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(lightBlue),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            icon: Icon(Icons.person),
            color: Color(darkYellow),
          )
        ],
      ),
      body: Container(
        child: Center(
          child: Text('Home page'),
        ),
        decoration: BoxDecoration(
          color: Color(0xFFDEE4F6),
        ),
      ),
    );
  }
}
