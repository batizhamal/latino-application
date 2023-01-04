import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/pages/home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EditEventPage extends StatefulWidget {
  const EditEventPage({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.price,
    required this.address,
    required this.id,
  });

  final String title;
  final String description;
  final String date;
  final String price;
  final String address;
  final int id;

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  var _titleController = TextEditingController();
  var _descriptionController = TextEditingController();
  DateTime _dateController = DateTime.now();
  var _priceController = TextEditingController();
  var _addressController = TextEditingController();

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
    _priceController = TextEditingController(text: widget.price);
    _addressController = TextEditingController(text: widget.address);
    _dateController = DateFormat('dd.MM.yyyy').parse(widget.date);
    super.initState();
  }

  bool _editing = false;
  bool _deleting = false;

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
      _editing = true;
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

    var eventId = widget.id;

    var response = await http.put(
      Uri.parse("http://latino-parties.com/api/events/$eventId"),
      body: body,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _editing = false;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      });
    }
  }

  deleteEvent() async {
    setState(() {
      _deleting = true;
    });

    var eventId = widget.id;

    final sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");

    await http.delete(
      Uri.parse("http://latino-parties.com/api/events/$eventId"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    setState(() {
      _deleting = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => const  HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(lightBlue),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) => const HomePage()),
              (Route<dynamic> route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back),
          color: const Color(mainDark),
        ),
        title: Text(
          'Редактировать мероприятие',
          style: Theme.of(context).textTheme.headline3,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                          hintText: 'Место проведение',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: createEvent,
                          child: _editing
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Сохранить'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(darkYellow),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(),
                      _deleting
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.red,
                              ),
                            )
                          : TextButton(
                              onPressed: deleteEvent,
                              child: const Text(
                                'Удалить мероприятие',
                                style: TextStyle(
                                  color: Color(mainRed),
                                ),
                              ),
                            )
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
