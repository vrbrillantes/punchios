import 'package:intl/intl.dart';

class ItemDate {
  final String key;
  DateTime datetime;
  String longdate;
  String shortmonth;
  String day;
  String weekday;
  String time;

  ItemDate.initDate(this.key) {
    datetime = new DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS").parse(key);
    longdate = new DateFormat.yMMMMd().format(datetime);
    shortmonth = new DateFormat.MMM().format(datetime);
    weekday = new DateFormat.EEEE().format(datetime);
    day = new DateFormat.d().format(datetime);
    time = new DateFormat.jm().format(datetime);
  }
}