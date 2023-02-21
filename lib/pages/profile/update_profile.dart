import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latino_app/auth/auth_page.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/constants/image_strings.dart';
import 'package:latino_app/pages/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key, required this.data});
  final data;

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  var _nameController = TextEditingController();
  var _surnameController = TextEditingController();
  var _usernameController = TextEditingController();
  var _phoneNumberController = TextEditingController();

  String? _errorMessage;
  bool _loading = false;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.data["name"]);
    _surnameController = TextEditingController(text: widget.data["surname"]);
    _usernameController = TextEditingController(text: widget.data["email"]);
    _phoneNumberController =
        TextEditingController(text: widget.data["phone_number"]);
    _image = widget.data["img"];
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
      'type': widget.data["type"],
      'img': _image,
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
            builder: (BuildContext context) => const ProfilePage()),
        (Route<dynamic> route) => false,
      );
    }

    setState(() {
      _loading = false;
    });

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
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => const ProfilePage()),
      (Route<dynamic> route) => false,
    );
  }

  String? _image;
  final ImagePicker _imagePicker = ImagePicker();
  bool _imageChanged = false;
  bool _uploadingImage = false;

  getImageFromUser() async {
    setState(() {
      _uploadingImage = true;
    });
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    Uint8List imageByte = await image.readAsBytes();
    String base64Image = base64.encode(imageByte);

    setState(() {
      _image = base64Image;
      _imageChanged = true;
      _uploadingImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(lightBlue),
      appBar: AppBar(
        backgroundColor: const Color(lightBlue),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
          color: const Color(mainDark),
        ),
        title: Text(
          'Редактировать профиль',
          style: GoogleFonts.montserrat(
            color: const Color(mainDark),
            fontWeight: FontWeight.bold,
            fontSize: 18 * textScale,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: _imageChanged
                          ? Image.memory(
                              base64.decode(_image!),
                              fit: BoxFit.fitWidth,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  blankProfileImage,
                                  fit: BoxFit.fitWidth,
                                );
                              },
                            )
                          : Image.network(
                              _image!,
                              fit: BoxFit.fitWidth,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  blankProfileImage,
                                  fit: BoxFit.fitWidth,
                                );
                              },
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        getImageFromUser();
                      },
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Color(darkYellow),
                        ),
                        child: _uploadingImage
                            ? Container(
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(mainDark),
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.edit_outlined,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
                          labelText: 'Имя',
                          hintText: 'Имя',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _surnameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline_outlined),
                          labelText: 'Фамилия',
                          hintText: 'Фамилия',
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
                      Container(
                        child: _errorMessage == null
                            ? const SizedBox(height: 10)
                            : Column(
                                children: [
                                  Text(
                                    _errorMessage.toString(),
                                    style:
                                        const TextStyle(color: Color(mainRed)),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: updateProfile,
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Сохранить'),
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
