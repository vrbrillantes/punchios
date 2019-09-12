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

  Map<dynamic, dynamic> scannedAttendees = {};
  int checkedInAttendeeCount = 0;
  int regAttendeeCount = 0;
  AttendeeHolder.init(this.eventID) {
    AttendancePresenter.getScannedAttendees(eventID, (Map<dynamic, dynamic> atd) =>scannedAttendees = atd);
  }

  void checkIn(String userKey, bool isOnline, void checkInResult(bool r)) {
    isOnline
        ? AttendancePresenter.setAttendance(true, eventID, userKey, (Map data) => checkInResult(data['Status']))
        : AttendancePresenter.setScannedAttendees(eventID, addScannedAttendee(userKey, "IN"));
  }

  void checkInSession(String slotID, String userKey, String direction, bool isOnline, void checkInResult(bool r)) {
    isOnline ? AttendancePresenter.selfSetSessionAttendance(eventID, userKey, slotID, direction, () {}) : print("DO THIS"); //TODO WSS
  }

  Map<dynamic, dynamic> addScannedAttendee(String userKey, String direction) {
    scannedAttendees[userKey] = {'time': DateTime.now().toString(), 'direction': direction};
    return scannedAttendees;
  }
  void checkOut(String userKey, bool isOnline, void checkInResult(bool r)) {
    isOnline
        ? AttendancePresenter.checkout(eventID, userKey, (Map data) => checkInResult(data['Checkout']))
        : AttendancePresenter.setScannedAttendees(eventID, addScannedAttendee(userKey, "OUT"));
  }

  void getFirebase(bool isOnline, void attendeesRetrieved()) {
    if (isOnline) {
      AttendancePresenter.getAttendanceStats(eventID, (Map data) {
        if (data != null) {

          regAttendeeCount = data['AttendeeRegistered'];
          checkedInAttendeeCount = data['AttendeeCheckedIn'];
        }
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

//  Map<String, SlotAttendance> sessionAttendance = {}; TODO SESSION ATTENDANCE IS THIS NEEDED
  Map<String, WorkshopAttendance> workshopAttendance = {};
  bool isOnline;
  StreamSubscription _subscriptionEventAttendance;
  StreamSubscription _subscriptionSessionAttendance;
  StreamSubscription _subscriptionWorkshopAttendance;

  String waitForAttendanceSessionID;
  String waitForAttendanceWorkshopID;

  SessionAttendance sessions;
  WorkshopsAttendance workshops;

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

  void setFeedbackWorkshop(String workshopID, void done()) {
    AttendancePresenter.setFeedbackWorkshop(event.eventID, workshopID, userKey, (Map data) {
//      workshops.parseAttendance(data); TODO PARSE ATTENDANCE WORKSHOP
      done();
    });
//    sessions.setFeedback(slotID, done);
  }

  void setFeedbackSession(String slotID, void done()) {
    AttendancePresenter.setFeedbackSession(event.eventID, slotID, userKey, (Map data) {
      sessions.parseAttendance(data);
      done();
    });
//    sessions.setFeedback(slotID, done);
  }

  void getAttendance(void done(bool s)) {
    void readAttendance(Map data) {
      attendance = Attendance.newAttendance(event.eventID, profile);
      attendance.readAttendance(data);
      done(attendance.registered);
    }

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

  void getWorkshopAttendance(void done()) {
    workshops = WorkshopsAttendance(event.eventID, userKey);

    if (_subscriptionWorkshopAttendance != null) _subscriptionWorkshopAttendance.cancel();

    AttendancePresenter.getWorkshopAttendance(event.eventID, userKey, (Map data) {
      workshopAttendance = workshops.parseAttendance(data);
      if (waitForAttendanceWorkshopID != null && workshopAttendance[waitForAttendanceWorkshopID].attendance.checkedIn) {
        waitForAttendanceWorkshopID = null;
        Navigator.pop(context);
        dialog.confirmDialog(dialog.checkedInString("workshop"));
      }
      done();
    }, (StreamSubscription ss) => _subscriptionSessionAttendance = ss);
  }

  void getSessionsAttendance(void done(SessionAttendance sa)) {
    sessions = SessionAttendance(event.eventID, userKey);

    if (_subscriptionSessionAttendance != null) _subscriptionSessionAttendance.cancel();

    AttendancePresenter.getSessionAttendance2(event.eventID, userKey, (Map data) {
      sessions.parseAttendance(data); //TODO SESSION ATTENDANCE IS THIS NEEDED ASSIGN RETURN VALUE
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

  void cancelWorkshop(String workshopID, void done()) {
    void done(String s) {
      AttendancePresenter.setAttendanceCancelWorkshop(event.eventID, workshopID, workshopAttendance[workshopID].key, userKey, s, (Map data) {
        workshops.parseAttendance(data);
        dialog.confirmDialog(dialog.attendanceCancelConfirmString);
      });
    }

    ScreenTextInit.doThis(context, dialog.cancelString(event.eventDetails.name), done);
    print(workshopAttendance[workshopID].key);
  }

  void cancelSession(String slotID, void done()) {
    ScreenTextInit.doThis(
        context,
        dialog.cancelString(event.eventDetails.name),
        (String s) => AttendancePresenter.setAttendanceCancelSession(event.eventID, slotID, s, userKey, (Map data) {
//              attendance.readAttendance(data);
              sessions.parseAttendance(data);
              dialog.confirmDialog(dialog.attendanceCancelConfirmString);
            }));
  }

  void register({bool checkedIn = false}) {
//    FeedbackQuestions.forRegistration(event.eventID, checkedIn);
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
  }

  void registerWorkshop(Workshop ss, void done()) {
    AttendancePresenter.setWorkshopAttendance(ss.eventID, userKey, ss.ID, (Map data) {
      workshops.parseAttendance(data);
      done();
    });
  }

  void tryAttendWorkshop(Workshop ww, String status, void slotsLeft(int i), void done()) {
    if (workshopAttendance.containsKey(ww.ID)) {
      AttendanceStatus thisAttendance = workshopAttendance[ww.ID].attendance;
      switch (thisAttendance.textStatus) {
        case "Check-in":
          checkAttendanceWorkshopCheckIn(ww, slotsLeft);
          break;
        case "Ready to checkout":
          checkInWorkshop(ww, workshopAttendance[ww.ID].key, "OUT", 0);
          break;
      }
    }
  }

  void tryAttend(Session session, String status, void slotsLeft(int i), void done()) {
    String currentSession = sessions.mySlots[session.slotID];
    AttendanceStatus slotStatus = sessions.attendance[currentSession];
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
      registerSession(session, () {
        done();
        checkAttendance(session);
      });
//      dialog.choiceDialog(dialog.transferAttendanceString,
//          onYes: () => registerSession(session, () {
//                done();
//                checkAttendance(session);
//              }));
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

  void checkAttendanceWorkshop(Workshop ss) {
    AttendancePresenter.getWorkshopAttendees(event.eventID, ss.ID, (Map data) {
      Map<String, int> sortedAttendees = workshops.sortedAttendees(ss.ID, data);
      ss.maxAttendees < sortedAttendees[userKey]
          ? dialog.confirmDialog(dialog.workshopWaitingListString(sortedAttendees[userKey], ss.maxAttendees))
          : dialog.confirmDialog(dialog.workshopSuccessRegistration(ss.name));
    });
  }

  void checkAttendanceCheckIn(Session ss, void attendeesLeft(int i)) {
    AttendancePresenter.getSessionAttendees(event.eventID, ss.ID, ss.slotID, (Map data) {
      Map<String, int> sortedAttendees = sessions.sortedAttendees(ss.slotID, data);
      checkInSession(ss, "IN", sortedAttendees[userKey] - ss.maxAttendees); //TODO return check in
    });
  }

  void checkAttendanceWorkshopCheckIn(Workshop ww, void attendeesLeft(int i)) {
    AttendancePresenter.getWorkshopAttendees(ww.eventID, ww.ID, (Map data) {
      Map<String, int> sortedAttendees = workshops.sortedAttendees(ww.ID, data);
      checkInWorkshop(ww, workshopAttendance[ww.ID].key, "IN", sortedAttendees[userKey] - ww.maxAttendees); //TODO return check in
    });
  }

//  void setAttendanceSessionSelf(String slotID, String direction, void attendanceSet()) {
//    AttendancePresenter.selfSetSessionAttendance(event.eventID, userKey, slotID, direction, attendanceSet);
//  }

  void checkInSession(Session ss, String direction, int sequence) {
    waitForAttendanceSessionID = ss.ID;
    UIElements.modalBS(context, direction, () {
      Navigator.pop(context);
      waitForAttendanceSessionID = null;
      QRActions.scanCheckInSessionSelf(
          direction: direction,
          sessionID: ss.ID,
          returnCode: (String s) => AttendancePresenter.selfSetSessionAttendance(event.eventID, userKey, ss.slotID, direction, () => dialog.confirmDialog(dialog.checkedInString(ss.name))),
          wrongQR: () => dialog.confirmDialog(dialog.wrongQRString));
    }, profile.profileLogin.userKey, eventID: ss.eventID, sessionID: ss.ID, waitlisted: sequence > 0);
  }

  void checkInWorkshop(Workshop ss, String attendanceKey, String direction, int sequence) {
    waitForAttendanceSessionID = ss.ID;
    UIElements.modalBS(context, direction, () {
      Navigator.pop(context);
      waitForAttendanceSessionID = null;
      QRActions.scanCheckInWorkshopSelf(
          direction: direction,
          workshopID: ss.ID,
          returnCode: (String s) => AttendancePresenter.setAttendanceCheckInWorkshop(event.eventID, attendanceKey, userKey, (data) => dialog.confirmDialog(dialog.checkedInString(ss.name))),
          wrongQR: () => dialog.confirmDialog(dialog.wrongQRString));
    }, profile.profileLogin.userKey, eventID: ss.eventID, attendanceKey: attendanceKey, waitlisted: sequence > 0);
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

  static void setAttendanceCancelWorkshop(String eventID, String workshopID, String workshopKey, String userKey, String reason, void attendanceCancelled(Map data)) {
    if (workshopKey != null)
      FirebaseMethods.setWorkshopCancelAttendanceByAttendee(eventID, workshopKey, userKey, {'Reason': reason, 'CancelledUser': userKey, 'CancelledWorkshop': workshopID}, attendanceCancelled);
  }

  static void setAttendanceCheckInWorkshop(String eventID, String workshopKey, String userKey, void attendanceCancelled(Map data)) {
    if (workshopKey != null) FirebaseMethods.setWorkshopAttendanceByAttendee(eventID, workshopKey, userKey, 'CheckedIn', DateTime.now().toString(), attendanceCancelled);
  }

  static void setAttendanceCheckOutWorkshop(String eventID, String workshopKey, String userKey, void attendanceCancelled(Map data)) {
    if (workshopKey != null) FirebaseMethods.setWorkshopAttendanceByAttendee(eventID, workshopKey, userKey, 'CheckedOut', DateTime.now().toString(), attendanceCancelled);
  }

  static void setAttendanceFeedbackWorkshop(String eventID, String workshopKey, String userKey, void attendanceCancelled(Map data)) {
    if (workshopKey != null) FirebaseMethods.setWorkshopAttendanceByAttendee(eventID, workshopKey, userKey, 'Feedback', DateTime.now().toString(), attendanceCancelled);
  }

  static void setFeedback(String eventID, String userKey, void attendanceSet(Map data)) {
    if (userKey != null) FirebaseMethods.setAttendanceFeedbackSent(eventID, userKey, attendanceSet);
  }

  static void setFeedbackSession(String eventID, String slotID, String userKey, void attendanceSet(Map data)) {
    if (userKey != null) FirebaseMethods.setSessionAttendanceFeedbackSent(eventID, slotID, userKey, attendanceSet);
  }

  static void setFeedbackWorkshop(String eventID, String workshopID, String userKey, void attendanceSet(Map data)) {
    if (userKey != null) FirebaseMethods.setWorkshopAttendanceFeedbackSent(eventID, workshopID, userKey, attendanceSet);
  }

  static void getSessionAttendance2(String eventID, String userID, void onData(Map data), void returnSS(StreamSubscription ss)) {
    FirebaseMethods.getSessionAttendanceByEventID2(eventID, userID, onData).then(returnSS);
  }

  static void getSessionAttendees(String eventID, String sessionID, String slotID, void done(Map data)) {
    FirebaseMethods.getSessionsSlotsBySessionID(eventID, sessionID, slotID, done);
  }

  static void getWorkshopAttendees(String eventID, String workshopID, void done(Map data)) {
    FirebaseMethods.getWorkshopsBySessionID(eventID, workshopID, done);
  }

  static void getWorkshopAttendance(String eventID, String userID, void done(Map data), void returnSS(StreamSubscription ss)) {
    FirebaseMethods.getWorkshopsByUserID(eventID, userID, done).then(returnSS);
  }

  static void setSessionAttendance(String eventID, String userID, String slotID, String sessionID, void onData(Map data)) {
    if (userID != null) FirebaseMethods.setUserSessionAttendanceBySessionID(eventID, userID, slotID, {'SessionID': sessionID, 'Registered': DateTime.now().toString()}, onData);
  }

  static void setWorkshopAttendance(String eventID, String userID, String workshopID, void onData(Map data)) {
    if (userID != null) FirebaseMethods.setUserWorkshopAttendanceByWorkshopID(eventID, userID, {'UserID': userID, 'WorkshopID': workshopID, 'Registered': DateTime.now().toString()}, onData);
  }

  static void selfSetSessionAttendance(String eventID, String userID, String slotID, String direction, void onData()) {
    if (userID != null) FirebaseMethods.setSessionAttendanceByUserKey(eventID, userID, slotID, direction == "IN" ? "CheckedIn" : "CheckedOut", DateTime.now().toString(), onData);
  }
}
