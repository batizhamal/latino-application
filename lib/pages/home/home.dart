import 'dart:convert';

import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:intl/intl.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/pages/home/create_event.dart';
import 'package:latino_app/pages/home/edit_event.dart';
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
  }

  checkLoginStatus() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    print(sharedPreferences.getString("token"));

    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => WelcomePage()),
          (Route<dynamic> route) => false);
    }
  }

  getAllEvents() async {
    var response = await http.get(
      Uri.parse("http://latino-parties.com/api/events"),
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

  List<Container> getEventWidgets() {
    List<Container> res = [];
    for (int i = 0; i < _dateEvents.length; i++) {
      var event = _dateEvents[i];

      var newItem = Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Color(darkYellow),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    event["title"],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                _canCreate
                    ? IconButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (BuildContext context) => EditEventPage(
                                id: event["id"],
                                title: event["title"],
                                description: event["description"],
                                date: event["date"],
                                price: event["price"],
                                address: event["address"],
                              ),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        icon: Icon(
                          Icons.edit,
                          size: 14,
                        ),
                        color: Colors.white,
                      )
                    : Container()
              ],
            ),
            Divider(
              color: Colors.white,
            ),
            Row(
              children: [
                Text(
                  "Организатор: ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(lightYellow),
                  ),
                ),
                Text(
                  event["organizer"],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Адрес: ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(lightYellow),
                  ),
                ),
                Text(
                  event["address"],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Вход: ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(lightYellow),
                  ),
                ),
                Text(
                  event["price"],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Text(
              "Информация: ",
              style: TextStyle(
                fontSize: 14,
                color: Color(lightYellow),
              ),
            ),
            Text(
              event["description"],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );

      res.add(newItem);
    }

    return res;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(lightBlue),
      appBar: AppBar(
        backgroundColor: Color(lightBlue),
        elevation: 0,
        title: Text('Events', style: Theme.of(context).textTheme.headline3),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
            icon: Icon(Icons.person),
            color: Color(mainDark),
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(mainDark),
              ),
            )
          : SingleChildScrollView(
              child: SafeArea(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat.yMMMMd().format(DateTime.now()),
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Today',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ],
                          ),
                          _canCreate
                              ? SizedBox(
                                  width: 100,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              CreateEventPage(),
                                        ),
                                        (Route<dynamic> route) => false,
                                      );
                                    },
                                    child: Text('+ Create'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(darkYellow),
                                    ),
                                  ),
                                )
                              : SizedBox(width: 100, height: 40),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: DatePicker(
                          DateTime.now(),
                          height: 100,
                          width: 80,
                          initialSelectedDate: DateTime.now(),
                          selectionColor: Color(mainBlue),
                          selectedTextColor: Colors.white,
                          onDateChange: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                            filterEvents();
                          },
                        ),
                      ),

                      Divider(),

                      // displaying events here
                      Column(
                        children: getEventWidgets(),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
