import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class ItemDate {
  String dateTimeString;
  TimeOfDay timeOfDayString;

  DateTime datetime;
  String longdate;
  String shortmonth;
  String day;
  String weekday;
  String time;
  int hour;
  int minute;
  String dbtime;
  int millis;

  ItemDate.initDate(this.dateTimeString) {
    datetime = new DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS").parse(dateTimeString);
    longdate = new DateFormat.yMMMMd().format(datetime);
    shortmonth = new DateFormat.MMM().format(datetime);
    weekday = new DateFormat.EEEE().format(datetime);
    day = new DateFormat.d().format(datetime);
    time = new DateFormat.jm().format(datetime);
    hour = int.parse( new DateFormat.H().format(datetime));
    minute = int.parse( new DateFormat.m().format(datetime));
    millis = datetime.millisecondsSinceEpoch;
  }
  ItemDate.initDT(this.datetime) {
    longdate = new DateFormat.yMMMMd().format(datetime);
    shortmonth = new DateFormat.MMM().format(datetime);
    weekday = new DateFormat.EEEE().format(datetime);
    day = new DateFormat.d().format(datetime);
    time = new DateFormat.jm().format(datetime);
    hour = int.parse( new DateFormat.H().format(datetime));
    minute = int.parse( new DateFormat.m().format(datetime));
    millis = datetime.millisecondsSinceEpoch;
  }

  ItemDate.initDateTime(this.dateTimeString, this.timeOfDayString) {
    datetime = new DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS").parse(dateTimeString);
    datetime = new DateFormat("yyyy M d HH mm").parse(datetime.year.toString() + " " + datetime.month.toString() + " " + datetime.day.toString() + " " + timeOfDayString.hour.toString() + " " + timeOfDayString.minute.toString());
    longdate = new DateFormat.yMMMMd().format(datetime);
    shortmonth = new DateFormat.MMM().format(datetime);
    weekday = new DateFormat.EEEE().format(datetime);
    day = new DateFormat.d().format(datetime);
    time = new DateFormat.jm().format(datetime);
    hour = int.parse( new DateFormat.H().format(datetime));
    minute = int.parse( new DateFormat.m().format(datetime));
    millis = datetime.millisecondsSinceEpoch;
    dbtime = new DateFormat("yyyy-MM-dd HH:mm:ss.SSS").format(datetime);
  }
}