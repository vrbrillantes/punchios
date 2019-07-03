//import 'package:flutter/material.dart';
//import 'model.events.dart';
//import 'ui.eventWidgets.dart';
//
//class ListFeedback extends StatelessWidget {
//  ListFeedback({this.title = "List", this.onPressed, this.allEvents, this.showFeedback, this.onLongPress});
//
//  final Function(String) onPressed;
//  final String title;
//  final Map<String, Event> allEvents;
//  final List<String> showFeedback;
//  final Function(String) onLongPress;
//
//  @override
//  Widget build(BuildContext context) {
//    List<Event> sortedEvents = <Event>[];
//    showFeedback.forEach((String key) {
//      if (allEvents.containsKey(key)) {
//        sortedEvents.add(allEvents[key]);
//      }
//    });
//    sortedEvents.sort((a, b) => a.start.datetime.compareTo(b.start.datetime));
//    return SliverList(
//      delegate: SliverChildBuilderDelegate(
//            (BuildContext context, int index) {
//          if (index == 0) {
//            return Container(
//              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
//              child: Text(
//                title,
//                style: TextStyle(
//                  fontWeight: FontWeight.bold,
//                  fontSize: 17.0,
//                  color: Color.fromARGB(255, 54, 95, 223),
//                ),
//              ),
//            );
//          } else {
//            return EventBanner(
//              loadEvent: sortedEvents[index - 1],
//              onPressed: () => onPressed(sortedEvents[index - 1].eventKey),
//              onLongPress: () => onLongPress(sortedEvents[index - 1].eventKey),
//            );
//          }
//        },
//        childCount: sortedEvents.length + 1,
//      ),
//    );
//  }
//}
