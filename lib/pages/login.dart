import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latino_app/components/hidden_drawer.dart';
import 'package:latino_app/components/my_button.dart';
import 'package:latino_app/components/my_textfield.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  // to give to the gesture detector
  final VoidCallback showRegisterPage;

  const LoginPage({super.key, required this.showRegisterPage});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  // signIn method
  Future signIn() async {
    setState(() {
      _loading = true;
    });

    // loading circle
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map body = {
      'email': _usernameController.text,
      'password': _passwordController.text,
    };

    var data = null;

    var response = await http.post(
      Uri.parse("http://latino-parties.com/api/auth/login"),
      body: body,
    );

    // pop the loading circle
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      data = json.decode(response.body);

      if (data != null) {
        setState(() {
          _loading = false;
        });
        sharedPreferences.setString("token", data['access_token']);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => HiddenDrawer()),
          (Route<dynamic> route) => false,
        );
      } else {
        setState(() {
          _loading = false;
        });
        print(data.body);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDEE4F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // image
                Image.asset(
                  'assets/images/two_dancers_cartoon.png',
                  width: 300,
                  height: 300,
                ),
                SizedBox(height: 25),

                // Hello again!
                Text(
                  'Hello, social dancer!',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 48,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome back, you\'ve been missed!',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 50),

                // username textfield
                MyTextField(
                  controller: _usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                SizedBox(height: 10),

                // sign in button
                MyButton(
                  onTap: signIn,
                  label: 'Sign in',
                  color: Color(0xFFE0503D),
                  textColor: Colors.white,
                ),
                SizedBox(height: 25),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Not a member?'),
                    GestureDetector(
                      onTap: widget.showRegisterPage,
                      child: Text(' Register now',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          )),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
