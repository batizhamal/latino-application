import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/pages/home/home.dart';
import 'package:latino_app/pages/profile/data_formatter.dart';
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

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String? _errorMessage;
  String? _emailErrorMessage;
  var _role;

  var roles = [
    const DropdownMenuItem(child: Text("Танцор"), value: "b"),
    const DropdownMenuItem(child: Text("Организатор"), value: "a"),
  ];

  @override
  void initState() {
    _errorMessage = null;
    _emailErrorMessage = null;
    _role = roles[0].value;
    super.initState();
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
    if (passwordConfirmed() && _emailErrorMessage == null) {
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

      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();

      var name = _nameController.text.split(' ')[0];
      var surname = _nameController.text.split(' ').sublist(1).join(' ');

      Map body = {
        'email': _usernameController.text,
        'password': _passwordController.text,
        'name': name,
        'surname': surname.isNotEmpty ? surname : " ",
        'phone_number':
            _phoneNumberController.text.replaceAll(RegExp(r'[^\d]'), ""),
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
          sharedPreferences.setString("token", data['access_token']);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) => const HomePage()),
            (Route<dynamic> route) => false,
          );

          Map<String, dynamic> payload = Jwt.parseJwt(data['access_token']);
          var role = payload["role_id"] == '3' ? 'Танцор' : 'Организатор';
          sharedPreferences.setString("role", role);

          DateTime? expiryDate = Jwt.getExpiryDate(data['access_token']);
          sharedPreferences.setString('expiryDate', expiryDate.toString());
        }
      } else {
        var errorstring = "";
        var data = json.decode(response.body);

        data["errors"].forEach((key, value) {
          errorstring = value.join('\n');
        });
        if (mounted) {
          setState(() {
            _errorMessage = errorstring;
          });
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
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(0xFFDEE4F6),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Регистрация',
                    style: GoogleFonts.montserrat(
                      color: const Color(mainDark),
                      fontSize: 24.0 * textScale * 0.99,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Введите свои данные ниже для регистрации',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),

                  Form(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline_outlined),
                              labelText: 'ФИ',
                              hintText: 'ФИ',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.mail),
                              labelText: 'E-mail',
                              hintText: 'E-mail',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              if (EmailValidator.validate(value.toString()) ||
                                  value.isEmpty) {
                                setState(() {
                                  _emailErrorMessage = null;
                                });
                              } else {
                                setState(() {
                                  _emailErrorMessage =
                                      'Введите валидный e-mail';
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          _emailErrorMessage != null
                              ? Column(
                                  children: [
                                    Text(
                                      _emailErrorMessage.toString(),
                                      style: const TextStyle(
                                          color: Color(mainRed)),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                )
                              : Column(),
                          TextFormField(
                            controller: _phoneNumberController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.phone_outlined),
                              labelText: 'Номер телефона',
                              hintText: '+7 ### ### ## ##',
                              border: OutlineInputBorder(),
                            ),
                            inputFormatters: [phoneNumberFormatter],
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField(
                            value: _role,
                            items: roles,
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  _role = value;
                                });
                              }
                            },
                            icon: const Icon(LineAwesomeIcons.angle_down),
                            decoration: const InputDecoration(
                              labelText: 'Роль',
                              prefixIcon: Icon(Icons.accessibility_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.fingerprint),
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
                                icon: const Icon(Icons.remove_red_eye),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: !_confirmPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.password),
                              labelText: 'Подтвердить пароль',
                              hintText: 'Подтвердить пароль',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  if (mounted) {
                                    setState(() {
                                      _confirmPasswordVisible =
                                          !_confirmPasswordVisible;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.remove_red_eye),
                              ),
                            ),
                            onChanged: (value) {
                              if (!passwordConfirmed() && value.isNotEmpty) {
                                setState(() {
                                  _errorMessage = 'Пароли не совпадают';
                                });
                              } else {
                                setState(() {
                                  _errorMessage = null;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          _errorMessage != null
                              ? Column(
                                  children: [
                                    Text(
                                      _errorMessage.toString(),
                                      style: const TextStyle(
                                          color: Color(mainRed)),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                )
                              : Column(),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: signUp,
                              child: const Text('Зарегистрироваться'),
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
                      const Text('Уже есть аккаунт?'),
                      GestureDetector(
                        onTap: widget.showLoginPage,
                        child: const Text(' Войти',
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
