import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/constants/image_strings.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({
    super.key,
    required this.data,
  });

  final data;

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
          'Персональные данные',
          style: Theme.of(context).textTheme.headline3,
        ),
        backgroundColor: Color(lightBlue),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(blankProfileImage),
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Имя',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10),
              Text(data["name"], style: Theme.of(context).textTheme.bodyText1),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Text(
                'Фамилия',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10),
              Text(data["surname"],
                  style: Theme.of(context).textTheme.bodyText1),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Text(
                'E-mail',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10),
              Text(data["email"], style: Theme.of(context).textTheme.bodyText1),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Text(
                'Номер телефона',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10),
              Text(data["phone_number"],
                  style: Theme.of(context).textTheme.bodyText1),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
              Text(
                'Роль',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 10),
              Text(data["role"], style: Theme.of(context).textTheme.bodyText1),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
