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
    DateTime? _pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2222),
    );

    if (_pickedDate != null) {
      setState(() {
        _dateController = _pickedDate;
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
          MaterialPageRoute(builder: (BuildContext context) => HomePage()),
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

    var response = await http.delete(
      Uri.parse("http://latino-parties.com/api/events/$eventId"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    setState(() {
      _deleting = false;
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (BuildContext context) => HomePage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(lightBlue),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) => HomePage()),
              (Route<dynamic> route) => false,
            );
          },
          icon: Icon(Icons.arrow_back),
          color: Color(mainDark),
        ),
        title: Text(
          'Редактировать мероприятие',
          style: Theme.of(context).textTheme.headline3,
        ),
        backgroundColor: Color(lightBlue),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.title),
                          labelText: 'Название',
                          hintText: 'Название',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.description),
                          labelText: 'Описание',
                          hintText: 'Описание',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      // DatePicker
                      SizedBox(height: 10),
                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: IconButton(
                            onPressed: () {
                              getDateFromUser();
                            },
                            icon: Icon(Icons.date_range_outlined),
                          ),
                          hintText: DateFormat.yMd().format(_dateController),
                          border: OutlineInputBorder(),
                        ),
                      ),

                      SizedBox(height: 10),
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.money),
                          labelText: 'Вход',
                          hintText: 'Вход',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.location_on_outlined),
                          labelText: 'Место проведения',
                          hintText: 'Место проведение',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: createEvent,
                          child: _editing
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Text('Сохранить'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(darkYellow),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      _deleting
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Colors.red,
                              ),
                            )
                          : TextButton(
                              onPressed: deleteEvent,
                              child: Text(
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
