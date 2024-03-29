import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latino_app/auth/auth_page.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/constants/image_strings.dart';
import 'package:latino_app/pages/home/home.dart';
import 'package:latino_app/pages/profile/information.dart';
import 'package:latino_app/pages/profile/profile_menu_item.dart';
import 'package:latino_app/pages/profile/settings.dart';
import 'package:latino_app/pages/profile/update_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late SharedPreferences sharedPreferences;
  var data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    checkLoginStatus();
    getProfileData();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();

    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) =>
                  const AuthPage(showLoginPage: true)),
          (Route<dynamic> route) => false);
    }
  }

  getProfileData() async {
    sharedPreferences = await SharedPreferences.getInstance();

    var token = sharedPreferences.getString("token");

    var response = await http
        .get(Uri.parse("http://latino-parties.com/api/auth/profile"), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) =>
                const AuthPage(showLoginPage: true)),
        (Route<dynamic> route) => false,
      );
    }

    setState(() {
      _isLoading = false;
    });

    setState(() {
      data = json.decode(response.body)["data"];
    });
  }

  logOut() async {
    sharedPreferences = await SharedPreferences.getInstance();

    var token = sharedPreferences.getString("token");

    await http.post(
      Uri.parse("http://latino-parties.com/api/auth/logout"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    sharedPreferences.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (BuildContext context) =>
              const AuthPage(showLoginPage: true)),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(lightBlue),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (BuildContext context) => const HomePage()),
              (Route<dynamic> route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back),
          color: const Color(mainDark),
        ),
        title: Text(
          'Профиль',
          style: GoogleFonts.montserrat(
            color: const Color(mainDark),
            fontWeight: FontWeight.bold,
            fontSize: 18 * textScale * 0.99,
          ),
        ),
        backgroundColor: const Color(lightBlue),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(mainDark),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(blankProfileImage),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      data["name"] + " " + data["surname"],
                      style: GoogleFonts.montserrat(
                        color: const Color(mainDark),
                        fontWeight: FontWeight.bold,
                        fontSize: 18 * textScale * 0.99,
                      ),
                    ),
                    Text(
                      data["email"],
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  UpdateProfilePage(data: data),
                            ),
                          );
                        },
                        child: const Text('Редактировать'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(darkYellow),
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    const SizedBox(height: 10),
                    ProfileMenuWidget(
                      title: 'Информация',
                      icon: Icons.info_outline,
                      onPress: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                InformationPage(data: data),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ProfileMenuWidget(
                      title: 'Настройки',
                      icon: Icons.settings_outlined,
                      onPress: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const SettingsPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ProfileMenuWidget(
                      title: 'Выйти',
                      icon: Icons.logout,
                      onPress: logOut,
                      textColor: Colors.red,
                      endIcon: false,
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
