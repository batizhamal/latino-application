import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latino_app/components/hidden_drawer.dart';
import 'package:latino_app/components/my_button.dart';
import 'package:latino_app/components/my_textfield.dart';
import 'package:http/http.dart' as http;
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/constants/image_strings.dart';
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
  bool _passwordVisible = false;
  String? _errorMessage = null;

  @override
  void initState() {
    _errorMessage = null;
  }

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
    } else {
      var errorstring = "";
      var data = json.decode(response.body);

      data["errors"].forEach((key, value) {
        errorstring = errorstring + '\n' + value.join('\n');
      });
      setState(() {
        _errorMessage = errorstring;
      });
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color(lightBlue),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // image
                Image.asset(
                  twoDancersImage,
                  height: size.height * 0.2,
                ),
                SizedBox(height: 25),

                // Hello again!
                Text(
                  'Welcome back!',
                  style: Theme.of(context).textTheme.headline1,
                ),
                SizedBox(height: 10),
                Text(
                  'Plan, register for event, keep track.',
                  style: Theme.of(context).textTheme.bodyText1,
                ),

                Form(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person_outline_outlined),
                            labelText: 'Username',
                            hintText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.password_rounded),
                            labelText: 'Username',
                            hintText: 'Username',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                              icon: Icon(Icons.remove_red_eye_sharp),
                            ),
                          ),
                        ),
                        // SizedBox(height: 10),
                        // TextButton(
                        //   onPressed: () {},
                        //   child: Align(
                        //     alignment: Alignment.centerRight,
                        //     child: Text(
                        //       'Forgot password?',
                        //       style: TextStyle(
                        //         color: Colors.blue,
                        //         fontSize: 14,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        Container(
                          child: _errorMessage == null
                              ? SizedBox(height: 10)
                              : Column(
                                  children: [
                                    Text(
                                      _errorMessage.toString(),
                                      style: TextStyle(color: Color(mainRed)),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: signIn,
                            child: Text('LOGIN'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.showRegisterPage,
                      child: Text(
                        ' Sign up',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
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
