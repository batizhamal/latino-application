import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';
import 'package:latino_app/auth/auth_page.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/constants/image_strings.dart';
import 'package:latino_app/pages/register.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Color(lightBlue)),
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  twoDancersImage,
                  height: height * 0.5,
                ),
                Column(
                  children: [
                    Text(
                      'Привет, танцор!',
                      style: Theme.of(context).textTheme.headline1,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Мы поможем тебе планировать латино мероприятия',
                      style: Theme.of(context).textTheme.bodyText1,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  AuthPage(showLoginPage: false),
                            ),
                          );
                        },
                        child: Text('Регистрация'),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AuthPage(
                                showLoginPage: true,
                              ),
                            ),
                          );
                        },
                        child: Text('Вход'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
