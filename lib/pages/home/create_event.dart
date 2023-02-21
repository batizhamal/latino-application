import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/pages/home/home.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latino_app/extensions/timeofday.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _titleController = TextEditingController();

  final _descriptionController = TextEditingController();

  DateTime _dateController = DateTime.now();

  TimeOfDay _startTimeController = TimeOfDay.now();
  TimeOfDay _endTimeController = TimeOfDay.now();

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

  getStartTimeFromUser() async {
    TimeOfDay? selectedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    if (selectedTime != null) {
      setState(() {
        _startTimeController = selectedTime;
      });
    }
  }

  getEndTimeFromUser() async {
    TimeOfDay? selectedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    if (selectedTime != null) {
      setState(() {
        _endTimeController = selectedTime;
      });
    }
  }

  String? _image;
  final ImagePicker _imagePicker = ImagePicker();

  getImageFromUser() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    Uint8List imageByte = await image!.readAsBytes();
    String _base64 = base64.encode(imageByte);

    print(_base64);
    setState(() {
      _image = _base64;
    });
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
      "start_time": _startTimeController.to24hours(),
      "end_time": _endTimeController.to24hours(),
      "img": _image,
    };

    print(body);

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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(darkYellow),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => const HomePage()),
                (Route<dynamic> route) => false,
              );
            },
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
          ),
        ),
        title: Text(
          'Создать событие',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18 * textScale,
          ),
        ),
        backgroundColor: const Color(darkYellow),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                height: screenHeight * 0.15,
                child: Column(
                  children: [
                    Form(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.title),
                              labelText: 'Название',
                              hintText: 'Название',
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            decoration: InputDecoration(
                              prefixIcon: IconButton(
                                onPressed: () {
                                  getDateFromUser();
                                },
                                icon: const Icon(Icons.date_range_outlined),
                              ),
                              hintText:
                                  DateFormat.yMd().format(_dateController),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(30),
                height: screenHeight * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                child: Column(
                  children: [
                    Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              prefixIcon: IconButton(
                                onPressed: () {
                                  getStartTimeFromUser();
                                },
                                icon: const Icon(Icons.timer_outlined),
                              ),
                              hintText: _startTimeController.to24hours(),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            decoration: InputDecoration(
                              prefixIcon: IconButton(
                                onPressed: () {
                                  getEndTimeFromUser();
                                },
                                icon: const Icon(Icons.timer_outlined),
                              ),
                              hintText: _endTimeController.to24hours(),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
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
                          TextFormField(
                            decoration: InputDecoration(
                              prefixIcon: IconButton(
                                onPressed: () {
                                  getImageFromUser();
                                },
                                icon: Icon(Icons.image_outlined),
                              ),
                              labelText: 'Добавить афишу',
                              border: OutlineInputBorder(),
                            ),
                            onTap: () {
                              getImageFromUser();
                            },
                          ),
                          SizedBox(height: 10),
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
            ],
          ),
        ),
      ),
    );
  }
}
