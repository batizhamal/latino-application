import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/constants/image_strings.dart';
import 'package:latino_app/pages/home/home.dart';
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
  bool _passwordVisible = false;
  String? _errorMessage;

  @override
  void initState() {
    _errorMessage = null;
    super.initState();
  }

  // signIn method
  Future signIn() async {
    // loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
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

    var data;

    var response = await http.post(
      Uri.parse("http://latino-parties.com/api/auth/login"),
      body: body,
    );

    // pop the loading circle
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      data = json.decode(response.body);

      if (data != null) {
        sharedPreferences.setString("token", data['access_token']);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => const HomePage()),
          (Route<dynamic> route) => false,
        );

        var token = data['access_token'];

        var responseProfile = await http.get(
            Uri.parse("http://latino-parties.com/api/auth/profile"),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            });
        var role = json.decode(responseProfile.body)!["data"]["role"];

        sharedPreferences.setString("role", role);
      }
    } else {
      var errorstring = "";
      var data = json.decode(response.body);

      data["errors"].forEach((key, value) {
        errorstring = errorstring + '\n' + value.join('\n');
      });
      if (mounted) {
        setState(() {
          _errorMessage = errorstring;
        });
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
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(lightBlue),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // image
                  Image.asset(
                    twoDancersImage,
                    height: 200,
                  ),
                  const SizedBox(height: 25),

                  // Hello again!
                  Text(
                    'С возвращением!',
                    style: GoogleFonts.montserrat(
                      color: const Color(mainDark),
                      fontSize: 24.0 * textScale * 0.99,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Планируйте и регистрируйтесь на мероприятия',
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.center,
                  ),

                  Form(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline_outlined),
                              labelText: 'Логин',
                              hintText: 'Логин',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.password_rounded),
                              labelText: 'Пароль',
                              hintText: 'Пароль',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  if (mounted) {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.remove_red_eye_sharp),
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
                                ? const SizedBox(height: 10)
                                : Column(
                                    children: [
                                      Text(
                                        _errorMessage.toString(),
                                        style: const TextStyle(
                                            color: Color(mainRed)),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: signIn,
                              child: const Text('Войти'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(mainRed),
                                elevation: 0,
                              ),
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
                      const Text(
                        'Нет аккаунта?',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.showRegisterPage,
                        child: const Text(
                          ' Зарегистрироваться',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
