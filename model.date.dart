import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
class PunchDate {
  String dateTimeString;
  TimeOfDay timeOfDayString;

  DateTime datetime;
  String longdate;
  String longmonth;
  String shortmonth;
  String longyear;
  String day;
  String weekday;
  String shortweekday;
  String simpleDate;
  String time;
  int hour;
  int minute;
  String dbdate;
  int millisdate;

  void doOtherFormats() {
    longdate = DateFormat.yMMMMd().format(datetime);
    shortmonth = DateFormat.MMM().format(datetime);
    longmonth = DateFormat.MMMM().format(datetime);
    longyear = DateFormat.y().format(datetime);
    weekday = DateFormat.EEEE().format(datetime);
    shortweekday = DateFormat.E().format(datetime);
    day = DateFormat.d().format(datetime);
    time = DateFormat.jm().format(datetime);
    hour = int.parse( DateFormat.H().format(datetime));
    minute = int.parse( DateFormat.m().format(datetime));
    millisdate = datetime.millisecondsSinceEpoch;
    dbdate = DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(datetime);
    simpleDate = "$longmonth $day, $longyear";
  }

  PunchDate.initDBTime(this.dateTimeString) {
    datetime = DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS").parse(dateTimeString);
    doOtherFormats();
  }

  PunchDate.init(this.datetime) {
    doOtherFormats();
  }

  PunchDate.combineDateTime(this.dateTimeString, this.timeOfDayString) {
    datetime = DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS").parse(dateTimeString);
    datetime = DateFormat("yyyy M d HH mm").parse(datetime.year.toString() + " " + datetime.month.toString() + " " + datetime.day.toString() + " " + timeOfDayString.hour.toString() + " " + timeOfDayString.minute.toString());
    doOtherFormats();
  }
}