//import 'dart:async';
//import 'model.attendance.dart';
//import 'controller.calendar.dart';

class Calendar {
  final String userKey;

  Calendar(this.userKey);

  List<String> parseCalendar(Map data) {
    List<String> calendarEvents = <String>[];
    data.forEach((k, v) {
      if (v) calendarEvents.add(k);
    });
    return calendarEvents;
  }

  List<String> parseInterests(Map data) {
    List<String> interestedEvents = <String>[];
    data.forEach((k, v) {
      if (v) interestedEvents.add(k);
    });
    return interestedEvents;
  }
}
