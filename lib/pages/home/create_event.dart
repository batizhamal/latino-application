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
  final bool editing;
  final event;
  const CreateEventPage({super.key, this.editing = false, this.event});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  var _titleController = TextEditingController();

  var _descriptionController = TextEditingController();

  DateTime _dateController = DateTime.now();

  TimeOfDay _startTimeController = TimeOfDay.now();
  TimeOfDay _endTimeController = TimeOfDay.now();

  var _priceController = TextEditingController();

  var _addressController = TextEditingController();

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
      _uploadingImage = false;
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
    var response;

    if (widget.editing) {
      var eventId = widget.event["id"];
      print(body);
      response = await http.put(
        Uri.parse("http://latino-parties.com/api/events/$eventId"),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    } else {
      response = await http.post(
        Uri.parse("http://latino-parties.com/api/events"),
        body: body,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
    }

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
  void initState() {
    if (widget.editing) {
      var dateParts = widget.event["date"].split(".");

      setState(() {
        _titleController = TextEditingController(text: widget.event["title"]);
        _descriptionController =
            TextEditingController(text: widget.event["description"]);
        _addressController =
            TextEditingController(text: widget.event["address"]);
        _priceController = TextEditingController(text: widget.event["price"]);
        _dateController = DateTime(int.parse(dateParts[2]),
            int.parse(dateParts[1]), int.parse(dateParts[0]));
        _startTimeController = TimeOfDay(
            hour: int.parse(widget.event["start_time"].split(":")[0]),
            minute: int.parse(widget.event["start_time"].split(":")[1]));
        _endTimeController = TimeOfDay(
            hour: int.parse(widget.event["end_time"].split(":")[0]),
            minute: int.parse(widget.event["end_time"].split(":")[1]));
        ;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;
    final screenHeight = MediaQuery.of(context).size.height;

    bool _editing = widget.editing;
    final _event = widget.event;

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
                height: screenHeight * 0.18,
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
                          const SizedBox(height: 20),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(30),
                height: screenHeight * 0.82,
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 220.0,
                            child: OutlinedButton(
                              onPressed: getImageFromUser,
                              child: _uploadingImage
                                  ? Container(
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(mainDark),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(_image != null
                                            ? Icons.check_circle_outline
                                            : Icons.upload_file_outlined),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _image != null
                                                ? _image!
                                                : "Добавить афишу",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
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
                          SizedBox(height: 20),
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
                          SizedBox(height: 20),
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
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.money),
                              labelText: 'Вход',
                              hintText: 'Вход',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.location_on_outlined),
                              labelText: 'Место проведения',
                              hintText: 'Место проведения',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          // const SizedBox(height: 20),
                          // TextFormField(
                          //   decoration: InputDecoration(
                          //     prefixIcon: IconButton(
                          //       onPressed: () {
                          //         getImageFromUser();
                          //       },
                          //       icon: Icon(Icons.image_outlined),
                          //     ),
                          //     labelText: _image != null
                          //         ? "Имя файла"
                          //         : 'Добавить афишу',
                          //     border: OutlineInputBorder(),
                          //   ),
                          //   onTap: () {
                          //     getImageFromUser();
                          //   },
                          // ),
                          SizedBox(height: 60),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                createEvent();
                              },
                              child: _creating
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(_editing == true
                                      ? 'Редактировать'
                                      : 'Создать'),
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
