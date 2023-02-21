import 'dart:convert';

// import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latino_app/components/date_picker_timeline/date_picker_timeline.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/pages/home/create_event.dart';
import 'package:latino_app/pages/home/edit_event.dart';
import 'package:latino_app/pages/home/event_card.dart';
import 'package:latino_app/pages/profile/profile.dart';
import 'package:latino_app/pages/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _dateEvents = [];
  var _allEvents = [];

  DateTime _selectedDate = DateTime.now();
  bool _loading = false;
  bool _canCreate = false;

  @override
  void initState() {
    setState(() {
      _loading = true;
      _selectedDate =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    });
    checkLoginStatus();
    getAllEvents();
    super.initState();
  }

  checkLoginStatus() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (BuildContext context) => const WelcomePage()),
          (Route<dynamic> route) => false);
    }
  }

  getAllEvents() async {
    final sharedPrederences = await SharedPreferences.getInstance();
    var token = sharedPrederences.getString("token");

    var response = await http.get(
      Uri.parse("http://latino-parties.com/api/events"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    var sharedPreferences = await SharedPreferences.getInstance();

    var role = sharedPreferences.getString("role");

    if (role == 'Организатор') {
      setState(() {
        _canCreate = true;
      });
    }

    if (response.statusCode == 200) {
      var allEvents = json.decode(response.body)!["data"];

      setState(() {
        _allEvents = allEvents;
        _loading = false;
      });

      filterEvents();
    }
  }

  filterEvents() {
    var filtered = [];
    filtered.addAll(_allEvents);

    filtered.retainWhere((el) {
      return DateFormat('dd.MM.yyyy').parse(el["date"]).toString() ==
          _selectedDate.toString();
    });
    setState(() {
      _dateEvents = filtered;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: const Color(lightBlue),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              icon: const Icon(Icons.person),
              color: const Color(mainDark),
            ),
          ),
        ],
      ),
      body: _loading
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(mainDark),
                ),
              ),
            )
          : SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          )),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${DateFormat.yMMM('ru').format(_selectedDate)[0].toUpperCase()}${DateFormat.yMMM('ru').format(_selectedDate).substring(1).toLowerCase()}",
                                    style: GoogleFonts.montserrat(
                                      color: const Color(mainDark),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24 * textScale,
                                    ),
                                  ),
                                ],
                              ),
                              _canCreate
                                  ? SizedBox(
                                      width: 120,
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  const CreateEventPage(),
                                            ),
                                            (Route<dynamic> route) => false,
                                          );
                                        },
                                        child: const Text('Создать'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(darkYellow),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(width: 100, height: 50),
                            ],
                          ),
                          const SizedBox(height: 40),
                          DatePicker(
                            DateTime.now(),
                            height: 100,
                            width: 70,
                            locale: 'ru',
                            initialSelectedDate: DateTime.now(),
                            selectionColor: const Color(mainBlue),
                            selectedTextColor: Colors.white,
                            onDateChange: (date) {
                              setState(() {
                                _selectedDate = date;
                              });
                              filterEvents();
                            },
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        children: [
                          // displaying events here
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'События',
                                style: GoogleFonts.montserrat(
                                  color: const Color(mainDark),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ...getEventWidgets(_dateEvents, context, _canCreate),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  registerForEvent(int id) async {
    final sharedPrederences = await SharedPreferences.getInstance();
    var token = sharedPrederences.getString("token");

    await http.post(
      Uri.parse("http://latino-parties.com/api/events/$id/register"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  unRegisterFromEvent(int id) async {
    final sharedPrederences = await SharedPreferences.getInstance();
    var token = sharedPrederences.getString("token");

    await http.delete(
      Uri.parse("http://latino-parties.com/api/events/$id/cancel-registration"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}
