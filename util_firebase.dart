import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'model_events.dart';
import 'model_profile.dart';
import 'model_question.dart';
import 'model_sessionregistration.dart';
import 'model_session.dart';
import 'model_feedback.dart';
import 'util_account.dart';

final dbEvents = FirebaseDatabase.instance.reference().child('Events');
final dbSessions = FirebaseDatabase.instance.reference().child('Modules');
final dbRegistrations = FirebaseDatabase.instance.reference().child('Registrations');
final dbAttendance = FirebaseDatabase.instance.reference().child('Attendance');
final dbSessionAttendance = FirebaseDatabase.instance.reference().child('SessionAttendance');
final dbKiosk = FirebaseDatabase.instance.reference().child('Kiosk');
final dbFeedback = FirebaseDatabase.instance.reference().child("Feedback");
final dbQuestions = FirebaseDatabase.instance.reference().child("Questions");
final dbNotifications = FirebaseDatabase.instance.reference().child('Notifications');
final dbUserInfo = FirebaseDatabase.instance.reference().child('Users');
final dbAdmins = FirebaseDatabase.instance.reference().child('Admins');

class FirebaseMethods {
  static Future<StreamSubscription<Event>> getPublicEvents(String filter, void onData(ListEvent todo)) async {
    StreamSubscription<Event> subscription = dbEvents.orderByChild(filter).equalTo(true).onValue.listen((Event event) {
      onData(new ListEvent.fromJson(event.snapshot.key, event.snapshot.value));
    });
    return subscription;
  }

  static void registerToken(String token, String userKey) {
    dbUserInfo.child(userKey).child("FCMToken").set(token);
  }

  static Future<StreamSubscription<Event>> getEventQuestions(String filter, void onData(ListEventQuestion todo)) async {
    StreamSubscription<Event> subscription = dbQuestions.orderByChild("QuestionKey").equalTo(filter).onValue.listen((Event event) {
      onData(ListEventQuestion.fromJson(event.snapshot.key, event.snapshot.value));
    });
    return subscription;
  }
  static Future<StreamSubscription<Event>> getEventFeedback(String filter, void onData(ListEventFeedback todo)) async {
    StreamSubscription<Event> subscription = dbFeedback.orderByChild("FeedbackKey").equalTo(filter).onValue.listen((Event event) {
      onData(ListEventFeedback.fromJson(event.snapshot.key, event.snapshot.value));
    });
    return subscription;
  }

  //TODO remove subscription
  static Future<StreamSubscription<Event>> getPrivateEvents(String filter, List<ItemEvent> eventList, void onData(ListEvent todo)) async {
    StreamSubscription<Event> subscription = dbEvents.orderByChild(filter).equalTo(true).onValue.listen((Event event) {
      var todos = new ListEvent.appendFromJson(eventList, event.snapshot.key, event.snapshot.value);
      onData(todos);
    });

    return subscription;
  }

  //TODO replace
  static Future<StreamSubscription<Event>> getAttendingEvents(String filter, void onData(ListEvent todo)) async {
    StreamSubscription<Event> subscription = dbEvents.orderByChild(filter).equalTo(true).onValue.listen((Event event) {
      onData(ListEvent.fromJson(event.snapshot.key, event.snapshot.value));
    });

    return subscription;
  }

  //TODO remove subscription
  //TODO user parameter
  static Future<StreamSubscription<Event>> getCreatedEvents(String filter, void onData(ListEvent todo)) async {
    StreamSubscription<Event> subscription = dbEvents.orderByChild("Creator").equalTo(filter).onValue.listen((Event event) {
      var todos = new ListEvent.fromJson(event.snapshot.key, event.snapshot.value);
      onData(todos);
    });

    return subscription;
  }

  //TODO remove subscription
  static Future<StreamSubscription<Event>> getMyEvents(String filter, void onData(ListEvent todo)) async {
    StreamSubscription<Event> subscription =
        FirebaseDatabase.instance.reference().child('Events').orderByChild(filter).equalTo(true).onValue.listen((Event event) {
      var todos = new ListEvent.fromJson(event.snapshot.key, event.snapshot.value);
      onData(todos);
    });

    return subscription;
  }

  //TODO remove subscription
  static Future getSessionDetails(String filter, void onData(ListSession todo)) async {
    dbSessions.orderByChild("EventID").equalTo(filter).once().then((DataSnapshot event) {
      onData(new ListSession.fromJson(event.key, event.value));
    });
//    StreamSubscription<Event> subscription =
//        FirebaseDatabase.instance.reference().child('Modules').orderByChild("EventID").equalTo(filter).onValue.listen((Event event) {
//      if (event.snapshot.value != null) onData();
//    });
//
//    return subscription;
  }

  static Future getAttendees(String eventID, void onData(ListEventAttendees todo)) async {
    dbRegistrations.child(eventID).once().then((DataSnapshot snapshot) {
      onData(ListEventAttendees.fromJson(eventID, snapshot.value));
    });
  }

  static void createToken(String eventID, void onCreate(String token)) {
//    String token = StringUtil.randomString(4);
    String token = dbEvents.child(eventID).child('Tokens').push().key;
    dbEvents.child(eventID).child('Tokens').child(token).set("NEW").whenComplete(() {
      onCreate(token);
    });
  }

  static Future<StreamSubscription<Event>> getQR(String eventID, String token, void onData(String key)) async {
    StreamSubscription<Event> subscription = dbEvents.child(eventID).child("Tokens").child(token).onValue.listen((Event event) {
      onData(event.snapshot.value);
    });

    return subscription;
  }

  static void registerMeEvent(String userKey, String eventID) {
    dbRegistrations.child(eventID).child(userKey).set({'Status': false, 'Time': DateTime.now().toString()});
  }

  static void confirmAttendanceQR(String userKey, String eventID, String token, String key) {
    dbAttendance.child(eventID).push().set({'Finished': false, 'User': userKey, 'Token': token, 'Key': key, 'Time': DateTime.now().toString()});
  }
  static void finishAttendanceQR(String userKey, String eventID, String token, String key) {
    dbAttendance.child(eventID).push().set({'Finished': true, 'User': userKey, 'Token': token, 'Key': key, 'Time': DateTime.now().toString()});
  }
  //TODO functionality
  static void confirmSessionQR(String userKey, String eventID, String sessionID, String slot, String token, String key) {
    dbSessionAttendance.child(eventID).child(slot).child(sessionID).push().set({'Finished': false, 'User': userKey, 'Token': token, 'Key': key, 'Time': DateTime.now().toString()});
  }
  static void finishSessionQR(String userKey, String eventID, String sessionID, String slot, String token, String key) {
    dbSessionAttendance.child(eventID).child(slot).child(sessionID).push().set({'Finished': true, 'User': userKey, 'Token': token, 'Key': key, 'Time': DateTime.now().toString()});
  }

  static Future registerMeSession(String userKey, String eventID, String sessionID, String slot, Future onRegister()) async {
    dbRegistrations
        .child(eventID)
        .child(userKey)
        .child(slot)
        .set({'Done': false, 'Confirmed': false, 'Session': sessionID, 'Time': DateTime.now().toString()}).whenComplete(onRegister);
  }

  static Future cancelRegistration(String userKey, String eventID, String reason) async {
    dbRegistrations.child(eventID).child(userKey).set({'Reason': reason});
  }

  static Future cancelRegistrationSession(String userKey, String eventID, String slot, String reason) async {
    dbRegistrations.child(eventID).child(userKey).child(slot).set({'Reason': reason});
  }

  static Future getAttendance(
      String eventID, String userKey, void hasSessions(ListSessionRegistrations todo), void isConfirmed(), void hasEvent(), void onNoData()) async {
    dbRegistrations.child(eventID).child(userKey).once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        if (snapshot.value['Status'] == null && snapshot.value['Reason'] == null) {
          hasSessions(new ListSessionRegistrations.fromJson(snapshot.key, snapshot.value));
        } else {
          if (snapshot.value['Status'] != null) {
            if (snapshot.value['Status']) {
              isConfirmed();
            } else {
              hasEvent();
            }
          } else {
            onNoData();
          }
        }
      } else {
        onNoData();
      }
    });
  }

  static Future getAdmins(String userKey, void onData(bool isAdmin)) async {
    dbAdmins.child(userKey).once().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        onData(true);
      } else {
        onData(false);
      }
    });
  }

  //TODO reference
  static void submitQuestion(ItemProfile profile, String key, String s) {
    final reference = FirebaseDatabase.instance.reference().child("Questions");
    reference.push().set({'Question': s, 'Time': new DateTime.now().toString(), 'Name': profile.name, 'QuestionKey': key, 'Photo': profile.photo});
  }

  static void createFeedback(String sessionKey, String eventKey, ItemFeedback fb) {
    if (sessionKey != null) {
      dbSessions.child(sessionKey).child('Questions').push().set({'Q': fb.question, 'T': fb.type});
    } else {
      dbEvents.child(eventKey).child('Questions').push().set({'Q': fb.question, 'T': fb.type});
    }
  }

  static void submitCollaborator(String key, String email) {
    dbEvents.child(key).child('Collaborators').child(AccountUtils.getUserKey(email)).set(email);
  }

  static void submitFeedback(ItemProfile profile, String key, List<ItemFeedbackResponse> s) {
    List<Map<String, String>> feedback = <Map<String, String>>[];
    void iterateFeedback(ItemFeedbackResponse s) {
      Map<String, String> fb = {'Q': s.question, 'A': s.answer};
      feedback.add(fb);
    }

    s.forEach(iterateFeedback);
    dbFeedback.push().set({'Name': profile.name, 'FeedbackKey': key, 'Feedback': feedback, 'Time': new DateTime.now().toString()});
  }

  static void projectQuestion(ItemEventQuestion e) {
    dbKiosk.child(e.eventKey).child('Question').set({'Name': e.name, 'Question': e.question});

  }
  static void submitEvent(String creator, ItemEvent newEvent, List<ItemSession> sessionList) {
    String eventKey;
    newEvent.key == "new" ? eventKey = dbEvents.push().key : eventKey = newEvent.key;
    dbEvents.child(eventKey).set({
      'Active': true,
      'Name': newEvent.event.name,
      'Description': newEvent.event.description,
      'Brief': newEvent.brief,
      'Questions': newEvent.feedbackQuestions,
      'Venue': newEvent.event.venue,
      'GCalID': newEvent.gCalID,
      'VenueSpec': newEvent.venueSpec,
      'StartDate': newEvent.event.start.dbtime,
      'Collaborators' : newEvent.collaborators,
      'EndDate': newEvent.event.end.dbtime,
      'Banner': newEvent.banner,
      'Creator': creator,
      'Public': newEvent.public,
    });

    void iterateMapEntry(session) {
      print(session.name);
      dbSessions.push().set({
        'TimeStart': session.starttime.dbtime,
        'TimeEnd': session.endtime.dbtime,
        'EventID': eventKey,
        'Slot': session.slot,
        'Name': session.name,
        'EventDay': session.starttime.longdate,
        'EndTime': session.endtime.time,
        'StartTime': session.starttime.time
      });
    }

//    sessionList.forEach(iterateMapEntry);
  }
}
