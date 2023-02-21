import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/pages/home/create_event.dart';
import 'package:latino_app/pages/home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class EventPage extends StatefulWidget {
  final eventId;
  final bool canCreate;
  const EventPage({super.key, required this.eventId, required this.canCreate});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  var event;

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

  getEvent(int id) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");

    event = await http.get(
      Uri.parse("http://latino-parties.com/api/events/$id"),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  @override
  void initState() {
    getEvent(widget.eventId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final canCreate = widget.canCreate;
    print(event);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Color(darkYellow),
            expandedHeight: 250,
            title: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (BuildContext context) => const HomePage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  icon: const Icon(Icons.arrow_back),
                )
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background:
                  // Image.memory(base64.decode(event["img"]), fit: BoxFit.cover),
                  Image.network(
                'https://images.unsplash.com/photo-1485550409059-9afb054cada4?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=765&q=80',
                fit: BoxFit.cover,
                width: double.maxFinite,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(screenHeight * 0.15),
              child: Container(
                padding: EdgeInsets.only(top: 15, bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                ),
                width: double.maxFinite,
              ),
            ),
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(30, 15, 30, 30),
              color: Colors.white,
              height: screenHeight * 0.7,
              width: screenWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Событие",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.normal,
                              fontSize: 16,
                            ),
                          ),
                          if (canCreate)
                            IconButton(
                              icon: Icon(Icons.edit_outlined),
                              iconSize: 20.0,
                              color: Colors.grey,
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          CreateEventPage(
                                            editing: true,
                                            event: event,
                                          )),
                                  (Route<dynamic> route) => false,
                                );
                              },
                            )
                          else
                            Container(),
                        ],
                      ),
                      SizedBox(height: 15),
                      Text(
                        event["title"],
                        style: GoogleFonts.montserrat(
                          color: const Color(mainDark),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Организует ' + event["organizer"],
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.clip,
                      ),
                      SizedBox(height: 25),
                      Divider(),
                      SizedBox(height: 25),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.description_outlined),
                          SizedBox(width: 30),
                          Expanded(
                            child: Text(
                              event["description"],
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_month_outlined),
                          SizedBox(width: 30),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event["date"],
                                overflow: TextOverflow.clip,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                event["start_time"] + " - " + event["end_time"],
                                overflow: TextOverflow.clip,
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_outlined),
                          SizedBox(width: 30),
                          Expanded(
                            child: Text(
                              event["address"],
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.attach_money_outlined),
                          SizedBox(width: 30),
                          Expanded(
                            child: Text(
                              event["price"],
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      event?["status"] == 'Зарегистрирован'
                          ? Text(
                              "Вы идете на это событие",
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                            )
                          : Container(),
                      SizedBox(height: 10),
                      canCreate
                          ? Container()
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (event?["status"] ==
                                      'Не зарегистрирован') {
                                    registerForEvent(event["id"]);
                                  } else {
                                    unRegisterFromEvent(event["id"]);
                                  }
                                },
                                child: Text(
                                  event["status"] == 'Не зарегистрирован'
                                      ? 'Хочу пойти!'
                                      : "Не смогу пойти",
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(mainRed),
                                  elevation: 0,
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
