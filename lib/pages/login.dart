import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latino_app/components/my_button.dart';
import 'package:latino_app/components/my_textfield.dart';

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

  // signIn method
  Future signIn() async {
    // TODO: create sign in method with API
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
