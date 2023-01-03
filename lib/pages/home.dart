import 'package:flutter/material.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/pages/profile/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
