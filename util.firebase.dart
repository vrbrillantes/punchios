import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

final dbEventList = FirebaseDatabase.instance.reference().child('CurrentEvents');
//final dbEventList = FirebaseDatabase.instance.reference().child('EventList');
final dbEventFeedback = FirebaseDatabase.instance.reference().child('EventFeedback');
final dbSessionFeedback = FirebaseDatabase.instance.reference().child('SessionFeedback');
final dbWorkshopFeedback = FirebaseDatabase.instance.reference().child('WorkshopFeedback');
final dbEventLinks = FirebaseDatabase.instance.reference().child('EventLinks');
final dbEventCollaborators = FirebaseDatabase.instance.reference().child('EventCollaborators');
final dbSessions = FirebaseDatabase.instance.reference().child("EventSessions");
final dbGroups = FirebaseDatabase.instance.reference().child("EventInvitations");
final dbSubs = FirebaseDatabase.instance.reference().child("Subscriptions");

final dbEventNotifications = FirebaseDatabase.instance.reference().child('EventNotifications');
final dbUserNotifications = FirebaseDatabase.instance.reference().child('UserNotifications');

final dbMyAccount = FirebaseDatabase.instance.reference().child('MyAccount');
final dbMyAccountOld = FirebaseDatabase.instance.reference().child('Users');

final dbCalendar = FirebaseDatabase.instance.reference().child('Calendar');
final dbInterested = FirebaseDatabase.instance.reference().child('InterestedEvents');

final dbSessionFeedbackResponses = FirebaseDatabase.instance.reference().child('SessionFeedbackResponses');
final dbWorkshopFeedbackResponses = FirebaseDatabase.instance.reference().child('WorkshopFeedbackResponses');
final dbEventFeedbackResponses = FirebaseDatabase.instance.reference().child('EventFeedbackResponses');
final dbRegistrations = FirebaseDatabase.instance.reference().child('EventAttendance');
//final dbRegistrations = FirebaseDatabase.instance.reference().child('Registrations');
final dbAttendanceStats = FirebaseDatabase.instance.reference().child('EventRegistrations');
//final dbSessionRegistrations = FirebaseDatabase.instance.reference().child('SessionRegistrations');
final dbSessionRegistrations = FirebaseDatabase.instance.reference().child('SessionAttendance');
final dbWorkshopsRegistrations = FirebaseDatabase.instance.reference().child('WorkshopAttendance');
final dbQuestions = FirebaseDatabase.instance.reference().child("Questions");
final dbSessionQuestions = FirebaseDatabase.instance.reference().child("SessionQuestions");
final dbWorkshopQuestions = FirebaseDatabase.instance.reference().child("WorkshopQuestions");
final dbEarnedBadges = FirebaseDatabase.instance.reference().child("EarnedBadges");
final dbEventBadges = FirebaseDatabase.instance.reference().child("EventBadges");
final dbKiosk = FirebaseDatabase.instance.reference().child('Kiosk');

//final dbNotifications = FirebaseDatabase.instance.reference().child('Notifications');
//final dbUserInfo = FirebaseDatabase.instance.reference().child('Users');
//final dbAdmins = FirebaseDatabase.instance.reference().child('Admins');
//final dbBadges = FirebaseDatabase.instance.reference().child('Badges');
//final dbTopics = FirebaseDatabase.instance.reference().child('Topics');
//final dbSessionRegistrations = FirebaseDatabase.instance.reference().child('SessionRegistrations');
//final dbAttendance = FirebaseDatabase.instance.reference().child('Attendance');
//final dbSessionAttendance = FirebaseDatabase.instance.reference().child('SessionAttendance');
//final dbFeedback = FirebaseDatabase.instance.reference().child("Feedback");
//final dbSessions = FirebaseDatabase.instance.reference().child('Modules');
//final dbEarnedBooths = FirebaseDatabase.instance.reference().child('EarnedBooths');
//final dbEarnedBadges = FirebaseDatabase.instance.reference().child('EarnedBadges');
//final dbEventBooths = FirebaseDatabase.instance.reference().child('EventBooths');
//final dbEventBadges = FirebaseDatabase.instance.reference().child('EventBadges');

class FirebaseMethods {
  static Future<StreamSubscription<Event>> getEventsByActiveStatus(void onData(Map todo)) async {
    return dbEventList.onValue.listen((Event e) => onData(e.snapshot.value));
  }

  static void getEventByEventID(String eventID, void onData(Map data)) {
    dbEventList.child(eventID).once().then((DataSnapshot ss) => onData(ss.value));
  }

  static void getSubsByUserKey(String userKey, void onData(Map data)) {
    dbSubs.child(userKey).once().then((DataSnapshot ss) => onData(ss.value));
  }

  static void getSessionsByEventID(String eventID, void onData(Map data)) {
    dbSessions.child(eventID).once().then((DataSnapshot ss) => onData(ss.value));
  }

  static void setMyAccount(String uuid, Map data, void onData()) {
    dbMyAccount.child(uuid).set(data).whenComplete(onData);
  }

  static void getMyAccount(String uuid, void onData(Map data)) {
    dbMyAccount.child(uuid).once().then((DataSnapshot ss) => onData(ss.value));
  }

  static void getMyAccountOld(String userKey, void onData(Map data)) {
    dbMyAccountOld.child(userKey).once().then((DataSnapshot ss) => onData(ss.value));
  }

  static void getCalendarByUserKey(String userKey, void onData(Map data)) {
    dbCalendar.child(userKey).once().then((DataSnapshot ss) => onData(ss.value));
  }

  static void getInterestedEventsByUserKey(String userKey, void onData(Map data)) {
    dbInterested.child(userKey).once().then((DataSnapshot ss) => onData(ss.value));
  }

  static void setInterestedEventsByEventID(String userKey, String eventID, bool set, void onData(Map data)) {
    DatabaseReference myInterests = dbInterested.child(userKey);
    myInterests.child(eventID).set(set).whenComplete(() => myInterests.once().then((DataSnapshot ss) => onData(ss.value)));
  }

  static void getEventBadgesByEventID(String eventID, void onData(Map data)) {
    dbEventBadges.child(eventID).once().then((DataSnapshot ss) => onData(ss.value));
  }

  static void setEventBadgeByUserKey(String eventID, String userKey, String boothID, void onData(Map data)) {
    DatabaseReference earnBadge = dbEarnedBadges.child(eventID).child(userKey);
    earnBadge.child(boothID).set(true).whenComplete(() => earnBadge.once().then((DataSnapshot ss) => onData(ss.value)));
//    earnBadge.child(boothID).set(true).whenComplete(done);
  }

  static void getEventEarnedBadgesByUserKey(String eventID, String userKey, void onData(Map data)) {
    dbEarnedBadges.child(eventID).child(userKey).once().then((DataSnapshot ss) => onData(ss.value));
  }

//  static Future<StreamSubscription<Event>> getAttendanceByUserKey(
//      String userKey, String eventID, void onData(Map data)) async {
//    return dbRegistrations
//        .child(eventID)
//        .child(userKey)
//        .onValue
//        .listen((Event e) => onData(e.snapshot.value));
//  }
  static Future<StreamSubscription<Event>> getSessionAttendanceByEventID2(String eventID, String userKey, void onData(Map data)) async {
    return dbSessionRegistrations.child(eventID).child(userKey).onValue.listen((Event e) => onData(e.snapshot.value));
  }

  static void getSessionAttendanceByEventID(String eventID, String userKey, void onData(Map data)) {
    dbSessionRegistrations.child(eventID).child(userKey).once().then((DataSnapshot ss) => onData(ss.value));
  }

  static void setSessionAttendanceFeedbackSent(String eventID, String slotID, String userKey, void onData(Map data)) {
    DatabaseReference mySessionAttendance = dbSessionRegistrations.child(eventID).child(userKey);
    mySessionAttendance.child(slotID).child('Feedback').set(true).whenComplete(() => mySessionAttendance.once().then((DataSnapshot ss) => onData(ss.value)));
  }

  static void setWorkshopAttendanceFeedbackSent(String eventID, String workshopID, String userKey, void onData(Map data)) {
//    DatabaseReference mySessionAttendance = dbSessionRegistrations.child(eventID).child(userKey); TODO WORKSHOP ATTENDANCE
//    mySessionAttendance.child(slotID).child('Feedback').set(true).whenComplete(() => mySessionAttendance.once().then((DataSnapshot ss) => onData(ss.value)));
  }

  static void getSessionsSlotsBySessionID(String eventID, String sessionID, String slotID, void onData(Map data)) {
    dbSessionRegistrations.child(eventID).orderByChild(slotID + "/SessionID").equalTo(sessionID).once().then((DataSnapshot ss) => onData(ss.value));
  }

  static void getWorkshopsBySessionID(String eventID, String workshopID, void onData(Map data)) {
    dbWorkshopsRegistrations.child(eventID).orderByChild('WorkshopID').equalTo(workshopID).once().then((DataSnapshot ss) => onData(ss.value));
  }

  static Future<StreamSubscription<Event>> getWorkshopsByUserID(String eventID, String userID, void onData(Map data)) async {
    return dbWorkshopsRegistrations.child(eventID).orderByChild('UserID').equalTo(userID).onValue.listen((Event e) => onData(e.snapshot.value));
  }

  static void setSessionAttendanceByUserKey(String eventID, String userKey, String slotID, String child, String dateTime, void onData()) {
    dbSessionRegistrations.child(eventID).child(userKey).child(slotID).child(child).set(dateTime).whenComplete(onData);
  }

  static void setUserSessionAttendanceBySessionID(String eventID, String userKey, String slotID, Map data, void onData(Map data)) {
    DatabaseReference mySessions = dbSessionRegistrations.child(eventID).child(userKey);
    mySessions.child(slotID).set(data).whenComplete(() => mySessions.once().then((DataSnapshot ss) => onData(ss.value)));
  }

  static void setUserWorkshopAttendanceByWorkshopID(String eventID, String userID, Map data, void onData(Map data)) {
    DatabaseReference myWorkshops = dbWorkshopsRegistrations.child(eventID);
    myWorkshops.push().set(data).whenComplete(() => myWorkshops.orderByChild('UserID').equalTo(userID).once().then((DataSnapshot ss) => onData(ss.value)));
  }

  static void setSessionAttendanceByAttendee(String eventID, String userKey, String slotID, Map data, void onData(Map data)) {
    DatabaseReference mySessions = dbSessionRegistrations.child(eventID).child(userKey);
    mySessions.child(slotID).set(data).whenComplete(() => mySessions.once().then((DataSnapshot ss) => onData(ss.value)));
  }

  static void setWorkshopAttendanceByAttendee(String eventID, String workshopKey, String userKey, String status, String value, void onData(Map data)) {
    DatabaseReference myWorkshops = dbWorkshopsRegistrations.child(eventID);
    myWorkshops.child(workshopKey).child(status).set(value).whenComplete(() => myWorkshops.orderByChild('UserID').equalTo(userKey).once().then((DataSnapshot ss) => onData(ss.value)));
  }

  static void setWorkshopCancelAttendanceByAttendee(String eventID, String workshopKey, String userKey, Map data, void onData(Map data)) {
    DatabaseReference myWorkshops = dbWorkshopsRegistrations.child(eventID);
    myWorkshops.child(workshopKey).set(data).whenComplete(() => myWorkshops.orderByChild('UserID').equalTo(userKey).once().then((DataSnapshot ss) => onData(ss.value)));
  }

  static Future<StreamSubscription<Event>> getAttendanceByUserKey(String userKey, String eventID, void onData(Map data)) async {
    return dbRegistrations.child(eventID).child(userKey).onValue.listen((Event e) => onData(e.snapshot.value));
  }

//  static void getAttendanceByUserKey(String userKey, String eventID, void onData(Map data)) {
//    dbRegistrations.child(eventID).child(userKey).once().then((DataSnapshot ss) => onData(ss.value));
//  }

  static void getAttendeesByEventID(String eventID, void onData(Map data)) {
    dbRegistrations.child(eventID).once().then((DataSnapshot ss) => onData(ss.value));
  }

  static void getAttendanceStats(String eventID, void onData(Map data)) {
    dbAttendanceStats.child(eventID).once().then((DataSnapshot ss) => onData(ss.value));
  }

  static void setAttendanceByAttendee(String eventID, String userKey, Map attendance, void onData(Map data)) {
    DatabaseReference myAttendance = dbRegistrations.child(eventID).child(userKey);
    myAttendance.set(attendance).whenComplete(() => myAttendance.once().then((DataSnapshot ss) => onData(ss.value)));
  }

  static void setAttendanceCheckoutByAttendee(String eventID, String userKey, void onData(Map data)) {
    DatabaseReference myAttendance = dbRegistrations.child(eventID).child(userKey);
    myAttendance.child('Checkout').set(true).whenComplete(() => myAttendance.once().then((DataSnapshot ss) => onData(ss.value)));
  }

  static void setAttendanceFeedbackSent(String eventID, String userKey, void onData(Map data)) {
    DatabaseReference myAttendance = dbRegistrations.child(eventID).child(userKey);
    myAttendance.child('Feedback').set(true).whenComplete(() => myAttendance.once().then((DataSnapshot ss) => onData(ss.value)));
  }

  static Future<StreamSubscription<Event>> getAllNotificationsByUserKey(String userKey, void onData(Map todo)) async {
    return dbUserNotifications.child(userKey).onValue.listen((Event e) => onData(e.snapshot.value));
  }

  static void setNotificationReadByNotificationID(String userKey, String eventID, String notifID) {
    dbUserNotifications.child(userKey).child(eventID).child(notifID).child('read').set(true);
  }

  static void setAttendeeNotificationByEventID(String eventID, String message, void onData()) {
    dbEventNotifications.child(eventID).set(message).whenComplete(onData);
  }

  static void setKioskQuestion(String referenceID, Map data) {
    dbKiosk.child(referenceID).child('Question').set(data);
  }

  static void setEventQuestion(String eventID, String sessionID, Map data, void onData()) {
    sessionID == null ? dbQuestions.child(eventID).push().set(data).whenComplete(onData) : dbSessionQuestions.child(eventID).child(sessionID).push().set(data).whenComplete(onData);
  }

  static Future<StreamSubscription<Event>> getEventQuestionsByEventIDRefresh(String eventID, String sessionID, void onData(Map todo)) async {
    return sessionID == null
        ? dbQuestions.child(eventID).onValue.listen((Event e) => onData(e.snapshot.value))
        : dbSessionQuestions.child(eventID).child(sessionID).onValue.listen((Event e) => onData(e.snapshot.value));
  }

  static void setQuestionVoteByUserKey(String eventID, String sessionID, String questionID, String userKey, void onData()) {
    sessionID == null
        ? dbQuestions.child(eventID).child(questionID).child('Votes').child(userKey).set(true).whenComplete(onData)
        : dbSessionQuestions.child(eventID).child(sessionID).child(questionID).child('Votes').child(userKey).set(true).whenComplete(onData);
  }

  static void getFeedbackQuestionsByEventID(String eventID, void feedbackRetrieved(Map data)) {
    dbEventFeedback.child(eventID).once().then((DataSnapshot ss) => feedbackRetrieved(ss.value));
  }

  static void getSessionFeedbackQuestionsByEventID(String eventID, void feedbackRetrieved(Map data)) {
    dbSessionFeedback.child(eventID).once().then((DataSnapshot ss) => feedbackRetrieved(ss.value));
  }

  static void getWorkshopFeedbackQuestionsByEventID(String eventID, void feedbackRetrieved(Map data)) {
    dbWorkshopFeedback.child(eventID).once().then((DataSnapshot ss) => feedbackRetrieved(ss.value));
  }

  static void setFeedbackAnswers(String eventID, String userKey, Map data, void onData()) {
    dbEventFeedbackResponses.child(eventID).child(userKey).set(data).whenComplete(onData);
  }

  static void setSessionFeedbackAnswers(String eventID, String sessionID, String userKey, Map data, void onData()) {
    dbSessionFeedbackResponses.child(eventID).child(sessionID).child(userKey).set(data).whenComplete(onData);
  }

  static void setWorkshopFeedbackAnswers(String eventID, String workshopID, String userKey, Map data, void onData()) {
    dbWorkshopFeedbackResponses.child(eventID).child(workshopID).child(userKey).set(data).whenComplete(onData);
  }

  static void setFeedbackQuestions() {}

  static void getFeedbackAnswersByEventID() {}

  static void getFeedbackAnswersByUserKey(String eventID, String userKey, Map data, void onData()) {}

  static void getEventLinksByEventID(String eventID, void onData(Map data)) {
    dbEventLinks.child(eventID).once().then((DataSnapshot ss) => onData(ss.value));
  }

  static void getEventCollaboratorsByEventID(String eventID, void onData(Map data)) {
    dbEventCollaborators.child(eventID).once().then((DataSnapshot ss) => onData(ss.value));
  }

  static void setEventCollaborator(String eventID, String uid, bool status, void onData(Map data), {String e}) {
    DatabaseReference collab = dbEventCollaborators.child(eventID);
    collab.child(uid).set(status ? (e != null ? e : uid) : null).whenComplete(() => collab.once().then((DataSnapshot ss) => onData(ss.value)));
  }
}
