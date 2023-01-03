import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
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
          MaterialPageRoute(builder: (BuildContext context) => HomePage()),
          (Route<dynamic> route) => false,
        );
      });
    }
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
          'Create event',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.title),
                          labelText: 'Title',
                          hintText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.description),
                          labelText: 'Description',
                          hintText: 'Description',
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
                          labelText: 'Price',
                          hintText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.location_on_outlined),
                          labelText: 'Address',
                          hintText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: createEvent,
                          child: _creating
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Text('Create'),
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
