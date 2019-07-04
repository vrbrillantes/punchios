import 'package:flutter/material.dart';
import 'util.dialog.dart';
import 'util.qr.dart';
import 'model.events.dart';
import 'model.attendance.dart';
import 'model.session.dart';
import 'model.profile.dart';
import 'screen.textDialog.dart';
import 'ui.eventWidgets.dart';
import 'dart:async';
import 'controller.calendar.dart';
import 'util.firebase.dart';

import 'util.preferences.dart';

class AttendeeHolder {
  final String eventID;

  AttendeeHolder.init(this.eventID) {
    AttendancePresenter.getScannedAttendees(eventID, (Map<dynamic, dynamic> atd) {
      attendees.readScanned(atd);
    });
  }

  Attendees attendees = Attendees();

  void checkIn(String userKey, bool isOnline, void checkInResult(bool r)) {
    isOnline
        ? AttendancePresenter.setAttendance(true, eventID, userKey, (Map data) => checkInResult(data['Status']))
        : AttendancePresenter.setScannedAttendees(eventID, attendees.addScannedAttendee(userKey, "IN"));
  }

  void checkInSession(String slotID, String userKey, String direction, bool isOnline, void checkInResult(bool r)) {
    isOnline ? AttendancePresenter.selfSetSessionAttendance(eventID, userKey, slotID, direction, () {}) : print("DO THIS"); //TODO WSS
  }

  void checkOut(String userKey, bool isOnline, void checkInResult(bool r)) {
    isOnline
        ? AttendancePresenter.checkout(eventID, userKey, (Map data) => checkInResult(data['Checkout']))
        : AttendancePresenter.setScannedAttendees(eventID, attendees.addScannedAttendee(userKey, "OUT"));
  }

  void getFirebase(bool isOnline, void attendeesRetrieved()) {
    if (isOnline) {
      AttendancePresenter.getAttendanceStats(eventID, (Map data) {
        if (data != null) attendees.parseAttendanceStats(data);
        attendeesRetrieved();
      });
    }
  }
}

class AttendanceHolder {
  final BuildContext context;
  final Profile profile;
  final Event event;

  GenericDialogGenerator dialog;
  String userKey;
  Map<String, SlotAttendance> sessionAttendance = {};
  bool isOnline;
  StreamSubscription _subscriptionEventAttendance;
  StreamSubscription _subscriptionSessionAttendance;

  String waitForAttendanceSessionID;

  SessionAttendance sessions;
  Attendance attendance;

  AttendanceHolder.newCalendarHolder(this.context, this.profile, this.event) {
    dialog = GenericDialogGenerator.init(context);
    userKey = profile.profileLogin.userKey;
  }

  void setStatus(bool s) {
    isOnline = s;
  }

  void setTime(Event e) {
    attendance.setTime(e.start, e.end);
  }

  void setFeedback(void done()) {
    AttendancePresenter.setFeedback(event.eventID, userKey, (Map data) {
      attendance.readAttendance(data);
      done();
    });
  }

  void setFeedbackSession(String slotID, void done()) {
    AttendancePresenter.setFeedbackSession(event.eventID, slotID, userKey, (Map data) {
      sessions.parseAttendance(data);
//      hasFeedback = true;
      done();
    });
//    sessions.setFeedback(slotID, done);
  }

  void getAttendance(void done(bool s)) {
    void readAttendance(Map data) {
      attendance.readAttendance(data);
      done(attendance.registered);
    }

    attendance = Attendance.newAttendance(event.eventID, profile);

    isOnline
        ? CalendarPresenter.getMyEventAttendance(userKey, event.eventID, readAttendance, (StreamSubscription ss) {
            _subscriptionEventAttendance = ss;
          })
        : CalendarPresenter.getMyOfflineAttendance(event.eventID, readAttendance, () {});
  }

  void disposeSubscriptions() {
    if (_subscriptionEventAttendance != null) _subscriptionEventAttendance.cancel();
    if (_subscriptionSessionAttendance != null) _subscriptionSessionAttendance.cancel();
  }

  void getSessionsAttendance(void done(SessionAttendance sa)) {
    sessions = SessionAttendance(event.eventID, userKey);

    if (_subscriptionSessionAttendance != null) _subscriptionSessionAttendance.cancel();

    AttendancePresenter.getSessionAttendance2(event.eventID, userKey, (Map data) {
      sessionAttendance = sessions.parseAttendance(data);
      if (waitForAttendanceSessionID != null && sessions.attendance[waitForAttendanceSessionID].checkedIn) {
        waitForAttendanceSessionID = null;
        Navigator.pop(context);
        dialog.confirmDialog(dialog.checkedInString("session"));
      }
      done(sessions);
    }, (StreamSubscription ss) => _subscriptionSessionAttendance = ss);
  }

  void checkIn() {
    UIElements.modalBS(context, 'IN', () {
      Navigator.pop(context);
      QRActions.scanCheckInSelf(
        eventID: event.eventID,
        returnCode: (String s) => register(checkedIn: true),
        wrongQR: () => dialog.confirmDialog(dialog.wrongQRString),
      );
    }, userKey, eventID: event.eventID);
  }

  void cancel(void done()) {
    ScreenTextInit.doThis(
        context,
        dialog.cancelString(event.eventDetails.name),
        (String s) => AttendancePresenter.setAttendanceCancel(event.eventID, s, userKey, (Map data) {
              attendance.readAttendance(data);
              dialog.confirmDialog(dialog.attendanceCancelConfirmString);
            }));
  }

  void cancelSession(String slotID, void done()) {
    ScreenTextInit.doThis(
        context,
        dialog.cancelString(event.eventDetails.name),
        (String s) => AttendancePresenter.setAttendanceCancelSession(event.eventID, slotID, s, userKey, (Map data) {
              attendance.readAttendance(data);
              dialog.confirmDialog(dialog.attendanceCancelConfirmString);
            }));
  }

  void register({bool checkedIn = false}) {
    AttendancePresenter.setAttendance(checkedIn, event.eventID, userKey, (Map data) {
      attendance.readAttendance(data);
      dialog.confirmDialog(checkedIn ? dialog.checkedInString(event.eventDetails.name) : dialog.registeredString(event.eventDetails.name));
    });
  }

  void registerSession(Session ss, void done()) {
    AttendancePresenter.setSessionAttendance(ss.eventID, userKey, ss.slotID, ss.ID, (Map data) {
      sessions.parseAttendance(data);
      done();
    });
//    sessions.registerSession(ss.slotID, ss.ID, done);
  }

  void tryAttendWorkshop(Workshop ww, String status, void slotsLeft(int i), void done()) {

  }
  void tryAttend(Session session, String status, void slotsLeft(int i), void done()) {
    String currentSession = sessions.mySlots[session.slotID];
    SessionAttendanceStatus slotStatus = sessions.attendance[currentSession];
    if (slotStatus != null) {
      if (currentSession == session.ID) {
        switch (status) {
          case "Check-in":
            checkAttendanceCheckIn(session, slotsLeft);
            break;
          case "Ready to checkout":
            checkInSession(session, "OUT", 0);
            break;
        }
      } else if (!slotStatus.checkedIn)
        dialog.choiceDialog(dialog.transferAttendanceString,
            onYes: () => registerSession(session, () {
                  done();
                  checkAttendance(session);
                }));
      else
        dialog.confirmDialog(dialog.sessionNotAllowed);
    } else {
      dialog.choiceDialog(dialog.transferAttendanceString,
          onYes: () => registerSession(session, () {
                done();
                checkAttendance(session);
              }));
    }
  }

  void checkAttendance(Session ss) {
    AttendancePresenter.getSessionAttendees(event.eventID, ss.ID, ss.slotID, (Map data) {
      Map<String, int> sortedAttendees = sessions.sortedAttendees(ss.slotID, data);
      ss.maxAttendees < sortedAttendees[userKey]
          ? dialog.confirmDialog(dialog.sessionWaitingListString(sortedAttendees[userKey], ss.maxAttendees))
          : dialog.confirmDialog(dialog.sessionSuccessRegistration(ss.name));
    });
  }

  void checkAttendanceCheckIn(Session ss, void attendeesLeft(int i)) {
    AttendancePresenter.getSessionAttendees(event.eventID, ss.ID, ss.slotID, (Map data) {
      Map<String, int> sortedAttendees = sessions.sortedAttendees(ss.slotID, data);
//      attendeesLeft(sortedAttendees[userKey] - ss.maxAttendees);
      checkInSession(ss, "IN", sortedAttendees[userKey] - ss.maxAttendees); //TODO return check in
    });
  }

  void setAttendanceSessionSelf(String slotID, String direction, void attendanceSet()) {
    AttendancePresenter.selfSetSessionAttendance(event.eventID, userKey, slotID, direction, attendanceSet);
  }

  void checkInSession(Session ss, String direction, int sequence) {
    waitForAttendanceSessionID = ss.ID;
    UIElements.modalBS(context, direction, () {
      Navigator.pop(context);
      waitForAttendanceSessionID = null;
      QRActions.scanCheckInSessionSelf(
          direction: direction,
          sessionID: ss.ID,
          returnCode: (String s) => setAttendanceSessionSelf(ss.slotID, direction, () => dialog.confirmDialog(dialog.checkedInString(ss.name))),
          wrongQR: () => dialog.confirmDialog(dialog.wrongQRString));
    }, profile.profileLogin.userKey, eventID: ss.eventID, sessionID: ss.ID, waitlisted: sequence > 0);
  }

  void checkOut() {
    UIElements.modalBS(context, 'IN', () {
      Navigator.pop(context);
      QRActions.scanCheckOutSelf(
        eventID: event.eventID,
        returnCode: (String s) => AttendancePresenter.checkout(event.eventID, userKey, (Map data) {
              attendance.readAttendance(data);
              dialog.confirmDialog(dialog.checkedInString(event.eventDetails.name));
            }),
        wrongQR: () => dialog.confirmDialog(dialog.wrongQRString),
      );
    }, userKey, eventID: event.eventID);
  }
}

AppPreferences prefs = AppPreferences.newInstance();

class AttendancePresenter {
  static void getCalendar(String userID, void calendarRetrieved(Map data)) {
    FirebaseMethods.getCalendarByUserKey(userID, (Map data) {
      calendarRetrieved(data);
      prefs.initInstance(() => prefs.setStringEncode('myCalendar', data, (bool s) {}));
    });
  }

  static void getAttendanceStats(String eventID, void attendanceRetrieved(Map data)) {
    FirebaseMethods.getAttendanceStats(eventID, attendanceRetrieved);
  }

  static void getOfflineCalendar(void calendarRetrieved(Map data)) {
    prefs.initInstance(() {
      prefs.getStringDecode('myCalendar', calendarRetrieved, () {});
    });
  }

  static void getScannedAttendees(String eventID, void calendarRetrieved(Map<dynamic, dynamic> data)) {
    prefs.initInstance(() {
      prefs.getStringDecode('$eventID scannedAttendees', calendarRetrieved, () {
        calendarRetrieved({});
      });
    });
  }

  static void setScannedAttendees(String eventID, Map<dynamic, dynamic> data) {
    prefs.initInstance(() {
      prefs.setStringEncode('$eventID scannedAttendees', data, (bool s) {});
    });
  }

  static void setAttendance(bool checkedIn, String eventID, String userKey, void attendanceSet(Map data)) {
    if (userKey != null) FirebaseMethods.setAttendanceByAttendee(eventID, userKey, {'Status': checkedIn, 'Time': DateTime.now().toString()}, attendanceSet);
  }

  static void checkout(String eventID, String userKey, void attendanceSet(Map data)) {
    if (userKey != null) FirebaseMethods.setAttendanceCheckoutByAttendee(eventID, userKey, attendanceSet);
  }

  static void setAttendanceCancel(String eventID, String reason, String userKey, void attendanceCancelled(Map data)) {
    if (userKey != null) FirebaseMethods.setAttendanceByAttendee(eventID, userKey, {'Reason': reason}, attendanceCancelled);
  }

  static void setAttendanceCancelSession(String eventID, String slotID, String reason, String userKey, void attendanceCancelled(Map data)) {
    if (userKey != null) FirebaseMethods.setSessionAttendanceByAttendee(eventID, userKey, slotID, {'Reason': reason}, attendanceCancelled);
  }

  static void setFeedback(String eventID, String userKey, void attendanceSet(Map data)) {
    if (userKey != null) FirebaseMethods.setAttendanceFeedbackSent(eventID, userKey, attendanceSet);
  }

  static void setFeedbackSession(String eventID, String slotID, String userKey, void attendanceSet(Map data)) {
    if (userKey != null) FirebaseMethods.setSessionAttendanceFeedbackSent(eventID, slotID, userKey, attendanceSet);
  }

  static void getSessionAttendance2(String eventID, String userID, void onData(Map data), void returnSS(StreamSubscription ss)) {
    FirebaseMethods.getSessionAttendanceByEventID2(eventID, userID, onData).then(returnSS);
  }

  static void getSessionAttendees(String eventID, String sessionID, String slotID, void done(Map data)) {
    FirebaseMethods.getSessionsSlotsBySessionID(eventID, sessionID, slotID, done);
  }

  static void setSessionAttendance(String eventID, String userID, String slotID, String sessionID, void onData(Map data)) {
    if (userID != null) FirebaseMethods.setUserSessionAttendanceBySessionID(eventID, userID, slotID, {'SessionID': sessionID, 'Registered': DateTime.now().toString()}, onData);
  }

  static void selfSetSessionAttendance(String eventID, String userID, String slotID, String direction, void onData()) {
    if (userID != null) FirebaseMethods.setSessionAttendanceByUserKey(eventID, userID, slotID, direction == "IN" ? "CheckedIn" : "CheckedOut", DateTime.now().toString(), onData);
  }
}
