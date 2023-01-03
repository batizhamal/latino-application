import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latino_app/components/hidden_drawer.dart';
import 'package:latino_app/components/my_button.dart';
import 'package:latino_app/components/my_textfield.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/pages/home/home.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
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
  final _phoneNumberController = TextEditingController();

  bool _loading = false;

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  String? _errorMessage = null;

  var roles = [
    DropdownMenuItem(child: Text("Танцор"), value: "b"),
    DropdownMenuItem(child: Text("Организатор"), value: "a"),
  ];

  var _role;

  @override
  void initState() {
    _errorMessage = null;
    _role = roles[0].value;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // sign up method
  Future signUp() async {
    if (passwordConfirmed()) {
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

      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      var name = _nameController.text.split(' ')[0];
      var surname = _nameController.text.split(' ').sublist(1).join(' ');

      Map body = {
        'email': _usernameController.text,
        'password': _passwordController.text,
        'name': name,
        'surname': surname.isNotEmpty ? surname : " ",
        'phone_number': _phoneNumberController.text,
        'type': _role,
      };

      var data = null;

      var response = await http.post(
        Uri.parse("http://latino-parties.com/api/auth/register"),
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
            MaterialPageRoute(builder: (BuildContext context) => HomePage()),
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
            child: Container(
              padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Register',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Enter your details below to register',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),

                  Form(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person_outline_outlined),
                              labelText: 'Fullname',
                              hintText: 'Fullname',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.mail),
                              labelText: 'Email',
                              hintText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _phoneNumberController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.phone_outlined),
                              labelText: 'Phone number',
                              hintText: 'Phone number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          DropdownButtonFormField(
                            value: _role,
                            items: roles,
                            onChanged: (value) {
                              setState(() {
                                _role = value;
                              });
                            },
                            icon: Icon(LineAwesomeIcons.angle_down),
                            decoration: InputDecoration(
                              labelText: 'Role',
                              prefixIcon: Icon(Icons.accessibility_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.fingerprint),
                              labelText: 'Password',
                              hintText: 'Password',
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                                icon: Icon(Icons.remove_red_eye),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_confirmPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.password),
                              labelText: 'Password',
                              hintText: 'Password',
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _confirmPasswordVisible =
                                        !_confirmPasswordVisible;
                                  });
                                },
                                icon: Icon(Icons.remove_red_eye),
                              ),
                            ),
                          ),
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
                              onPressed: signUp,
                              child: Text('SIGNUP'),
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
      ),
    );
  }
}
