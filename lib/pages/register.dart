import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latino_app/components/my_button.dart';
import 'package:latino_app/components/my_textfield.dart';
import 'package:latino_app/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;

  const RegisterPage({super.key, required this.showLoginPage});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // sign up method
  Future signUp() async {
    if (passwordConfirmed()) {
      // TODO: create sign up method with API
      setState(() {
        _loading = true;
      });
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      Map body = {
        'email': _usernameController.text,
        'password': _passwordController.text,
        'name': _nameController.text,
        'surname': _surnameController.text,
        'phone_number': _phoneNumberController.text,
        'type': 'a',
      };

      var data = null;

      var response = await http.post(
        Uri.parse("http://latino-parties.com/api/auth/register"),
        body: body,
      );

      if (response.statusCode == 200) {
        data = json.decode(response.body);

        if (data != null) {
          setState(() {
            _loading = false;
          });
          sharedPreferences.setString("token", data['access_token']);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => HomePage()),
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
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      return true;
    }
    return false;
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
                Text(
                  'Register',
                  style: GoogleFonts.bebasNeue(
                    fontSize: 48,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Enter your details below to register',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 50),

                MyTextField(
                  controller: _nameController,
                  hintText: 'First name',
                  obscureText: false,
                ),
                SizedBox(height: 10),

                MyTextField(
                  controller: _surnameController,
                  hintText: 'Last name',
                  obscureText: false,
                ),
                SizedBox(height: 10),

                // username textfield
                MyTextField(
                  controller: _usernameController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                SizedBox(height: 10),

                MyTextField(
                  controller: _phoneNumberController,
                  hintText: 'Phone number',
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

                // confirm password textfield
                MyTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirm password',
                  obscureText: true,
                ),
                SizedBox(height: 10),

                // sign in button
                MyButton(
                  onTap: signUp,
                  label: 'Sign up',
                  color: Color(0xFFE0503D),
                  textColor: Colors.white,
                ),
                SizedBox(height: 25),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already a member?'),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Text(' Sign in',
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
