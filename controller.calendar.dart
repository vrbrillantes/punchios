import 'package:flutter/material.dart';
import 'util.dialog.dart';
import 'util.qr.dart';
import 'model.events.dart';
import 'util.preferences.dart';
import 'model.calendar.dart';
import 'controller.attendance.dart';
import 'model.profile.dart';
import 'ui.eventWidgets.dart';
import 'util.firebase.dart';
import 'dart:async';

AppPreferences prefs = AppPreferences.newInstance();
class CalendarPresenter {
  static void getMyEventAttendance(String userKey, String eventID, void attendanceRetrieved(Map data), void returnSS(StreamSubscription ss)) {
    FirebaseMethods.getAttendanceByUserKey(userKey, eventID, attendanceRetrieved).then(returnSS);
  }

  static void getMyOfflineAttendance(String eventID, void done(Map data), void empty()) {
    prefs.initInstance(() {
      prefs.getStringDecode('$eventID myEventAttendance', done, empty);
    });
  }

  static void setMyOfflineAttendance(String eventID, Map data, void done(bool s)) {
    prefs.initInstance(() {
      prefs.setStringEncode('$eventID myEventAttendance', data, done);
    });
  }

  static void setInterestedEvent(String userID, String eventID, bool set, void interestedEventsRetrieved(Map data)) {
    if (userID != null)
      FirebaseMethods.setInterestedEventsByEventID(userID, eventID, set, (Map data) {
        interestedEventsRetrieved(data);
        prefs.initInstance(() => prefs.setStringEncode('myInterests', data, (bool s) {}));
      });
  }

  static void getInterestedEvents(String userID, void interestedEventsRetrieved(Map data)) {
    FirebaseMethods.getInterestedEventsByUserKey(userID, (Map data) {
      interestedEventsRetrieved(data);
      prefs.initInstance(() {
        prefs.setStringEncode('myInterests', data, (bool s) {});
      });
    });
  }

  static void getOfflineInterests(void calendarRetrieved(Map data)) {
    prefs.initInstance(() {
      prefs.getStringDecode('myInterests', calendarRetrieved, () {});
    });
  }
}

class CalendarHolder {
  GenericDialogGenerator dialog;
  Calendar calendar;
  List<String> interestedEvents = <String>[];
  String userKey;
  final BuildContext context;
  Profile profile;

  List<String> calendarEvents;

  bool isOnline;

  CalendarHolder.newCal(this.context) {
    dialog = GenericDialogGenerator.init(context);
  }

  void addProfile(Profile pp) {
    profile = pp;
    userKey = profile.profileLogin.userKey;
    calendar = Calendar(userKey);
  }

  void setStatus(bool s) {
    isOnline = s;
  }

  void setInterestedEvent(Event ee, void done(List<String> ls)) {
    void setInterests(List<String> ie) {
      interestedEvents = ie;
      done(ie);
    }

    interestedEvents.contains(ee.eventID)
        ? dialog.choiceDialog(dialog.removeInterestString(ee.eventDetails.name), onYes: () => setInterestedEventAction(isOnline, ee.eventID, setInterests, set: false))
        : setInterestedEventAction(isOnline, ee.eventID, setInterests);
  }

  void setInterestedEventAction(bool isOnline, String eventID, void calendarRetrieved(List<String> aa), {bool set = true}) {
    if (isOnline) {
      CalendarPresenter.setInterestedEvent(userKey, eventID, set, (Map data) {
        calendarRetrieved(calendar.parseInterests(data));
      });
    }
  }

  void checkIn(Event ee) {
    UIElements.modalBS(context, 'IN', () {
      Navigator.pop(context);
      QRActions.scanCheckInSelf(
        eventID: ee.eventID,
        returnCode: (String s) => AttendancePresenter.setAttendance(true, ee.eventID, userKey, (Map data) {
              dialog.confirmDialog(dialog.checkedInString(ee.eventDetails.name));
            }),
        wrongQR: () => dialog.confirmDialog(dialog.wrongQRString),
      );
    }, userKey, eventID: ee.eventID);
  }

  void getCal(void done(List<String> ls)) {
    void readCal(Map data) {
      calendarEvents = calendar.parseCalendar(data);
      done(calendarEvents);
    }

    isOnline ? AttendancePresenter.getCalendar(userKey, readCal) : AttendancePresenter.getOfflineCalendar(readCal);
  }

  void getInterests(void done(List<String> ls)) {
    void read(Map data) {
      done(calendar.parseInterests(data));
    }

    isOnline ? CalendarPresenter.getInterestedEvents(userKey, read) : CalendarPresenter.getOfflineInterests(read);
//    calendar.getInterestedEvents(isOnline, (List<String> ie) {
//      interestedEvents = ie;
//      done(ie);
//    });
  }
}
