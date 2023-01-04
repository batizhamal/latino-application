import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:latino_app/auth/auth_page.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/constants/image_strings.dart';
import 'package:latino_app/pages/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UpdateProfilePage extends StatefulWidget {
  UpdateProfilePage({super.key, required this.data});
  final data;

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  var _nameController = TextEditingController();
  var _surnameController = TextEditingController();
  var _usernameController = TextEditingController();
  var _phoneNumberController = TextEditingController();

  String? _errorMessage = null;
  bool _loading = false;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.data["name"]);
    _surnameController = TextEditingController(text: widget.data["surname"]);
    _usernameController = TextEditingController(text: widget.data["email"]);
    _phoneNumberController =
        TextEditingController(text: widget.data["phone_number"]);
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future updateProfile() async {
    setState(() {
      _loading = true;
    });
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");

    Map body = {
      'email': _usernameController.text,
      'name': _nameController.text,
      'surname': _surnameController.text,
      'phone_number': _phoneNumberController.text,
      'type': 'b',
    };

    var response = await http.put(
      Uri.parse("http://latino-parties.com/api/auth/profile"),
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (BuildContext context) => AuthPage(showLoginPage: true)),
        (Route<dynamic> route) => false,
      );
    }

    setState(() {
      _loading = false;
    });

    var data = null;

    if (response.statusCode != 200) {
      var errorstring = "";
      var data = json.decode(response.body);

      data["errors"].forEach((key, value) {
        errorstring = errorstring + '\n' + value.join('\n');
      });
      setState(() {
        _errorMessage = errorstring;
      });
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(lightBlue),
      appBar: AppBar(
        backgroundColor: Color(lightBlue),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
          color: Color(mainDark),
        ),
        title: Text(
          'Редактировать профиль',
          style: Theme.of(context).textTheme.headline3,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30),
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
              SizedBox(height: 10),
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
                          labelText: 'Имя',
                          hintText: 'Имя',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _surnameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person_outline_outlined),
                          labelText: 'Фамилия',
                          hintText: 'Фамилия',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.mail),
                          labelText: 'E-mail',
                          hintText: 'E-mail',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone_outlined),
                          labelText: 'Номер телефона',
                          hintText: 'Номер телефона',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
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
                          onPressed: updateProfile,
                          child: _loading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Сохранить'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
