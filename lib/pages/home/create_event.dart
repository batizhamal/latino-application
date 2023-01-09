import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/pages/home/home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _titleController = TextEditingController();

  final _descriptionController = TextEditingController();

  DateTime _dateController = DateTime.now();

  final _priceController = TextEditingController();

  final _addressController = TextEditingController();

  bool _creating = false;

  getDateFromUser() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2222),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController = pickedDate;
      });
    }
  }

  createEvent() async {
    setState(() {
      _creating = true;
    });

    var body = {
      "title": _titleController.text,
      "description": _descriptionController.text,
      "date": DateFormat.yMd().format(_dateController),
      "price": _priceController.text,
      "address": _addressController.text,
    };

    final sharedPreferences = await SharedPreferences.getInstance();

    var token = sharedPreferences.getString("token");

    var response = await http.post(
      Uri.parse("http://latino-parties.com/api/events"),
      body: body,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _creating = false;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      });
    }
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
          'Создать мероприятие',
          style: GoogleFonts.montserrat(
            color: const Color(mainDark),
            fontWeight: FontWeight.bold,
            fontSize: 18 * textScale * 0.99,
          ),
        ),
        backgroundColor: const Color(lightBlue),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.title),
                          labelText: 'Название',
                          hintText: 'Название',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.description),
                          labelText: 'Описание',
                          hintText: 'Описание',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      // DatePicker
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: IconButton(
                            onPressed: () {
                              getDateFromUser();
                            },
                            icon: const Icon(Icons.date_range_outlined),
                          ),
                          hintText: DateFormat.yMd().format(_dateController),
                          border: const OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.money),
                          labelText: 'Вход',
                          hintText: 'Вход',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_on_outlined),
                          labelText: 'Место проведения',
                          hintText: 'Место проведения',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: createEvent,
                          child: _creating
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Создать'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(mainRed),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
