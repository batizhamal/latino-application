import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latino_app/auth/auth_page.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _saving = false;
  bool _deleting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  changePassword() async {
    if (!_saving) {
      setState(() {
        _saving = true;
      });

      final sharedPreferences = await SharedPreferences.getInstance();
      var token = sharedPreferences.getString("token");

      var body = {
        "new_password": _passwordController.text,
        "confirmed_new_password": _confirmPasswordController.text,
      };

      var response = await http.put(
        Uri.parse("http://latino-parties.com/api/auth/profile/change-password"),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => AuthPage(showLoginPage: true)),
          (Route<dynamic> route) => false,
        );
      }

      setState(() {
        _saving = false;
      });
    }
  }

  deleteProfile() async {
    if (!_deleting) {
      setState(() {
        _deleting = true;
      });

      final sharedPreferences = await SharedPreferences.getInstance();
      var token = sharedPreferences.getString("token");

      var response = await http.delete(
        Uri.parse("http://latino-parties.com/api/auth/profile"),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      setState(() {
        _deleting = false;
      });

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => AuthPage(showLoginPage: true)),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(lightBlue),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
          color: Color(mainDark),
        ),
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headline3,
        ),
        backgroundColor: Color(lightBlue),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 30, 20, 30),
            child: Column(
              children: [
                Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 300,
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(mainBlue), width: 1),
                        borderRadius: BorderRadius.circular(5),
                        shape: BoxShape.rectangle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_passwordVisible,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.fingerprint),
                              labelText: 'New password',
                              hintText: 'New password',
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
                              labelText: 'Condirm password',
                              hintText: 'Confirm password',
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
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(darkYellow)),
                              onPressed: changePassword,
                              child: _saving
                                  ? CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 20,
                      top: 2,
                      child: Container(
                        padding:
                            EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        color: Color(lightBlue),
                        child: Text(
                          'Change password',
                          style: GoogleFonts.montserrat(
                            color: Color(mainDark),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 40),

                // second block
                Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 200,
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(mainRed), width: 1),
                        borderRadius: BorderRadius.circular(5),
                        shape: BoxShape.rectangle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'After this action is done, you will not be able to login with the same authorization data.',
                            style: GoogleFonts.montserrat(
                              color: Color(mainRed),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: deleteProfile,
                                child: _deleting
                                    ? CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text('Delete anyway'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(mainRed),
                                )),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 20,
                      top: 2,
                      child: Container(
                        padding:
                            EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        color: Color(lightBlue),
                        child: Text(
                          'Delete profile',
                          style: GoogleFonts.montserrat(
                            color: Color(darkRed),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
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
