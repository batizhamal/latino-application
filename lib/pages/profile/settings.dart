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
              builder: (BuildContext context) => const AuthPage(showLoginPage: true)),
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

      await http.delete(
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
            builder: (BuildContext context) => const AuthPage(showLoginPage: true)),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(lightBlue),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const  Icon(Icons.arrow_back),
          color: const Color(mainDark),
        ),
        title: Text(
          'Настройки',
          style: Theme.of(context).textTheme.headline3,
        ),
        backgroundColor: const Color(lightBlue),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
            child: Column(
              children: [
                Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 300,
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(mainBlue), width: 1),
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
                              prefixIcon: const Icon(Icons.fingerprint),
                              labelText: 'Новый пароль',
                              hintText: 'Новый пароль',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
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
                                  setState(() {
                                    _confirmPasswordVisible =
                                        !_confirmPasswordVisible;
                                  });
                                },
                                icon: const Icon(Icons.remove_red_eye),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(darkYellow)),
                              onPressed: changePassword,
                              child: _saving
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text('Сохранить'),
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
                            const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        color: const Color(lightBlue),
                        child: Text(
                          'Сменить пароль',
                          style: GoogleFonts.montserrat(
                            color: const Color(mainDark),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // second block
                Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 200,
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(mainRed), width: 1),
                        borderRadius: BorderRadius.circular(5),
                        shape: BoxShape.rectangle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'После этого, вы не сможете зайти в учетную запись под такими же данными.',
                            style: GoogleFonts.montserrat(
                              color: const Color(mainRed),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                                onPressed: deleteProfile,
                                child: _deleting
                                    ?  const CircularProgressIndicator(
                                        color: Colors.white)
                                    :  const Text('Все равно удалить'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(mainRed),
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
                            const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        color: const Color(lightBlue),
                        child: Text(
                          'Удалить учетную запись',
                          style: GoogleFonts.montserrat(
                            color: const Color(darkRed),
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
