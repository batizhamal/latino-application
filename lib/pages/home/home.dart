import 'dart:convert';

import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
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
    super.initState();
  }

  checkLoginStatus() async {
    final sharedPreferences = await SharedPreferences.getInstance();

    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => const WelcomePage()),
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

  List<Container> getEventWidgets() {
    List<Container> res = [];
    for (int i = 0; i < _dateEvents.length; i++) {
      var event = _dateEvents[i];

      var newItem = Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(darkYellow),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    event["title"],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  children: [
                    _canCreate
                        ? IconButton(
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      EditEventPage(
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
                            icon: const Icon(
                              Icons.edit,
                              size: 14,
                            ),
                            color: Colors.white,
                          )
                        : Container(),
                    event["status"] == 'Не зарегистрирован'
                        ? IconButton(
                            onPressed: () {
                              registerForEvent(event["id"]);
                              getAllEvents();
                            },
                            icon: const Icon(
                              Icons.add,
                              size: 14,
                            ),
                            color: Colors.white,
                          )
                        : event["status"] == 'Зарегистрирован'
                            ? IconButton(
                                onPressed: () {
                                  unRegisterFromEvent(event["id"]);
                                  getAllEvents();
                                },
                                icon: const Icon(
                                  Icons.done,
                                  size: 14,
                                ),
                                color: Colors.white,
                              )
                            : Container(),
                  ],
                ),
              ],
            ),
            const Divider(
              color: Colors.white,
            ),
            Row(
              children: [
                const Text(
                  "Организатор: ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(lightYellow),
                  ),
                ),
                Text(
                  event["organizer"],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Адрес: ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(lightYellow),
                  ),
                ),
                Text(
                  event["address"],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  "Вход: ",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(lightYellow),
                  ),
                ),
                Text(
                  event["price"],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Text(
              "Описание: ",
              style: TextStyle(
                fontSize: 14,
                color: Color(lightYellow),
              ),
            ),
            Text(
              event["description"],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Divider(color: Color(mainDark)),
            Text(
              event["status"],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(mainDark),
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
      backgroundColor: const Color(lightBlue),
      appBar: AppBar(
        backgroundColor: const Color(lightBlue),
        elevation: 0,
        title:
            Text('Мероприятия', style: Theme.of(context).textTheme.headline3),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person),
            color: const Color(mainDark),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(mainDark),
              ),
            )
          : SingleChildScrollView(
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat.yMMMMd('ru').format(DateTime.now()),
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              const  SizedBox(height: 10),
                              Text(
                                'Сегодня',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ],
                          ),
                          _canCreate
                              ? SizedBox(
                                  width: 120,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              const CreateEventPage(),
                                        ),
                                        (Route<dynamic> route) => false,
                                      );
                                    },
                                    child: const Text('+  Создать'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(darkYellow),
                                    ),
                                  ),
                                )
                              : const SizedBox(width: 100, height: 40),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DatePicker(
                          DateTime.now(),
                          height: 100,
                          width: 80,
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

                      const Divider(),

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
