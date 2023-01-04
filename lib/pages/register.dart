import 'dart:convert';

import 'package:flutter/material.dart';
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

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  String? _errorMessage;

  var roles = [
    const DropdownMenuItem(child: Text("Танцор"), value: "b"),
    const DropdownMenuItem(child: Text("Организатор"), value: "a"),
  ];

  var _role;

  @override
  void initState() {
    _errorMessage = null;
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
    if (passwordConfirmed()) {

      // loading circle
      showDialog(
          context: context,
          builder: (context) {
            return const  Center(
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
          sharedPreferences.setString("token", data['access_token']);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => const HomePage()),
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
                    style: Theme.of(context).textTheme.headline1,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Введите свои данные ниже для регистрации',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),

                  Form(
                    child: Container(
                      padding:const EdgeInsets.symmetric(vertical: 30),
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
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _phoneNumberController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.phone_outlined),
                              labelText: 'Номер телефона',
                              hintText: 'Номер телефона',
                              border: OutlineInputBorder(),
                            ),
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
                          ),
                          Container(
                            child: _errorMessage == null
                                ? const SizedBox(height: 10)
                                : Column(
                                    children: [
                                      Text(
                                        _errorMessage.toString(),
                                        style: const TextStyle(color: Color(mainRed)),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: signUp,
                              child: const Text('Зарегистрироваться'),
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
