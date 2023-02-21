import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latino_app/constants/color_codes.dart';
import 'package:latino_app/pages/home/event_page.dart';

List<Container> getEventWidgets(dateEvents, context, canCreate) {
  List<Container> res = [];
  for (int i = 0; i < dateEvents.length; i++) {
    var event = dateEvents[i];

    var newItem = Container(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    EventPage(event: event, canCreate: canCreate)),
            (Route<dynamic> route) => false,
          );
        },
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(darkYellow),
                  borderRadius: BorderRadius.circular(10),
                ),
                width: 40,
                height: 40,
                child: Center(
                  child: Icon(Icons.list_alt_outlined, color: Colors.white),
                ),
              ),
              SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event["title"],
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    event["start_time"] + ' - ' + event["end_time"],
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    res.add(newItem);
  }

  return res;
}

// List<Container> getEventWidgets() {
//   List<Container> res = [];
//   for (int i = 0; i < _dateEvents.length; i++) {
//     var event = _dateEvents[i];

//     var newItem = Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Flexible(
//                 child: Text(
//                   event["title"],
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               Row(
//                 children: [
//                   _canCreate
//                       ? IconButton(
//                           onPressed: () {
//                             Navigator.of(context).pushAndRemoveUntil(
//                               MaterialPageRoute(
//                                 builder: (BuildContext context) =>
//                                     EditEventPage(
//                                   id: event["id"],
//                                   title: event["title"],
//                                   description: event["description"],
//                                   date: event["date"],
//                                   price: event["price"],
//                                   address: event["address"],
//                                 ),
//                               ),
//                               (Route<dynamic> route) => false,
//                             );
//                           },
//                           icon: const Icon(
//                             Icons.edit,
//                             size: 14,
//                           ),
//                           color: Colors.white,
//                         )
//                       : Container(),
//                   event["status"] == 'Не зарегистрирован'
//                       ? IconButton(
//                           onPressed: () {
//                             registerForEvent(event["id"]);
//                             getAllEvents();
//                           },
//                           icon: const Icon(
//                             Icons.add,
//                             size: 14,
//                           ),
//                           color: Colors.white,
//                         )
//                       : event["status"] == 'Зарегистрирован'
//                           ? IconButton(
//                               onPressed: () {
//                                 unRegisterFromEvent(event["id"]);
//                                 getAllEvents();
//                               },
//                               icon: const Icon(
//                                 Icons.done,
//                                 size: 14,
//                               ),
//                               color: Colors.white,
//                             )
//                           : Container(),
//                 ],
//               ),
//             ],
//           ),
//           const Divider(
//             color: Colors.white,
//           ),
//           Row(
//             children: [
//               const Text(
//                 "Организатор: ",
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Color(lightYellow),
//                 ),
//               ),
//               Text(
//                 event["organizer"],
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               const Text(
//                 "Адрес: ",
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Color(lightYellow),
//                 ),
//               ),
//               Text(
//                 event["address"],
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               const Text(
//                 "Вход: ",
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Color(lightYellow),
//                 ),
//               ),
//               Text(
//                 event["price"],
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           const Text(
//             "Описание: ",
//             style: TextStyle(
//               fontSize: 14,
//               color: Color(lightYellow),
//             ),
//           ),
//           Text(
//             event["description"],
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           const Divider(color: Color(mainDark)),
//           Text(
//             event["status"],
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Color(mainDark),
//             ),
//           ),
//         ],
//       ),
//     );

//     res.add(newItem);
//   }

//   return res;
// }
