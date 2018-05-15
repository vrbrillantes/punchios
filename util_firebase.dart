import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'model_events.dart';
import 'model_eventquestion.dart';
import 'model_sessionregistration.dart';
import 'model_session.dart';
import 'model_feedback.dart';
import 'util_account.dart';

class FirebaseMethods {
  static Future<StreamSubscription<Event>> getPublicEvents(String filter, void onData(ListEvent todo)) async {
    StreamSubscription<Event> subscription =
        FirebaseDatabase.instance.reference().child('HELLO').child('Events').orderByChild(filter).equalTo(true).onValue.listen((Event event) {
      var todos = new ListEvent.fromJson(event.snapshot.key, event.snapshot.value);
      onData(todos);
    });

    return subscription;
  }

  static Future<StreamSubscription<Event>> getEventQuestions(String filter, void onData(ListEventQuestion todo)) async {
    StreamSubscription<Event> subscription =
        FirebaseDatabase.instance.reference().child('HELLO').child('Questions').orderByChild("EventID").equalTo(filter).onValue.listen((Event event) {
      var todos = new ListEventQuestion.fromJson(event.snapshot.key, event.snapshot.value);
      onData(todos);
    });

    return subscription;
  }

  static Future<StreamSubscription<Event>> getPrivateEvents(String filter, List<ItemEvent> eventList, void onData(ListEvent todo)) async {
    StreamSubscription<Event> subscription =
        FirebaseDatabase.instance.reference().child('HELLO').child('Events').orderByChild(filter).equalTo(true).onValue.listen((Event event) {
      var todos = new ListEvent.appendFromJson(eventList, event.snapshot.key, event.snapshot.value);
      onData(todos);
    });

    return subscription;
  }

  static Future<StreamSubscription<Event>> getAttendingEvents(String filter, void onData(ListEvent todo)) async {
    StreamSubscription<Event> subscription =
        FirebaseDatabase.instance.reference().child('HELLO').child('Events').orderByChild(filter).equalTo(true).onValue.listen((Event event) {
      var todos = new ListEvent.fromJson(event.snapshot.key, event.snapshot.value);
      onData(todos);
    });

    return subscription;
  }

  static Future<StreamSubscription<Event>> getCreatedEvents(String filter, void onData(ListEvent todo)) async {
    StreamSubscription<Event> subscription = FirebaseDatabase.instance
        .reference()
        .child('HELLO')
        .child('Events')
        .orderByChild("Creator")
        .equalTo("esroyo@globe.com.ph")
        .onValue
        .listen((Event event) {
      var todos = new ListEvent.fromJson(event.snapshot.key, event.snapshot.value);
      onData(todos);
    });

    return subscription;
  }

  static Future<StreamSubscription<Event>> getMyEvents(String filter, void onData(ListEvent todo)) async {
    StreamSubscription<Event> subscription =
        FirebaseDatabase.instance.reference().child('HELLO').child('Events').orderByChild(filter).equalTo(true).onValue.listen((Event event) {
      var todos = new ListEvent.fromJson(event.snapshot.key, event.snapshot.value);
      onData(todos);
    });

    return subscription;
  }

  static Future<StreamSubscription<Event>> getSessionDetails(String filter, void onData(ListSession todo)) async {
    StreamSubscription<Event> subscription =
        FirebaseDatabase.instance.reference().child('HELLO').child('Modules').orderByChild("EventID").equalTo(filter).onValue.listen((Event event) {
          if (event.snapshot.value != null) {
            var todos = new ListSession.fromJson(event.snapshot.key, event.snapshot.value);
            onData(todos);
          }
    });

    return subscription;
  }

  static Future registerMe(String email, String eventID, Future onRegister()) async {
    final reference = FirebaseDatabase.instance
        .reference()
        .child('HELLO')
        .child("Events")
        .child(eventID)
        .child("Registrants")
        .child(AccountUtils.getUserKey(email));
    reference.set(true).whenComplete(onRegister);
  }

  static Future<StreamSubscription<Event>> getMyEventRegisteredSessions(
      String eventID, String email, void onData(ListSessionRegistrations todo), void onNoData()) async {
    StreamSubscription<Event> subscription = FirebaseDatabase.instance
        .reference()
        .child('HELLO')
        .child('Registrations')
        .child(eventID)
        .child(AccountUtils.getUserKey(email))
        .onValue
        .listen((Event event) {
      if (event.snapshot.value != null) {
        var todos = new ListSessionRegistrations.fromJson(event.snapshot.key, event.snapshot.value);
        onData(todos);
      } else {
        onNoData();
      }
    });

    return subscription;
  }

  static Future registerMeSession(String email, String eventID, String sessionID, String slot, Future onRegister()) async {
    final reference = FirebaseDatabase.instance.reference().child('HELLO').child('Registrations').child(eventID).child(AccountUtils.getUserKey(email));
    reference.child(slot).set(sessionID).whenComplete(onRegister);
  }

  static Future unregisterMeSession(String email, String eventID, String sessionID, String slot, Future onLeave()) async {
    final reference = FirebaseDatabase.instance.reference().child('HELLO').child('Registrations').child(eventID).child(AccountUtils.getUserKey(email));
    reference.child(slot).set({}).whenComplete(onLeave);
  }

  static void unregisterMe(String email, String eventID, Future onLeave()) {
    final reference = FirebaseDatabase.instance
        .reference()
        .child('HELLO')
        .child("Events")
        .child(eventID)
        .child("Registrants")
        .child(AccountUtils.getUserKey(email));
    reference.set(false).whenComplete(onLeave);
  }

  static void submitQuestion(String name, String photo, String key, String s) {
    final reference = FirebaseDatabase.instance.reference().child('HELLO').child("Questions");
    reference.push().set({'Message': s, 'Name': name, 'EventID': key, 'Photo': photo});
  }

  static void submitSessionQuestion(String name, String photo, String eventKey, String sessionKey, String s) {
    final reference = FirebaseDatabase.instance.reference().child('HELLO').child("Questions");
    reference.push().set({'Message': s, 'Name': name, 'EventID': eventKey, 'SessionID': sessionKey, 'Photo': photo});
  }

  static void submitFeedback(String name, String key, List<ItemFeedback> s) {
    List<String> questions = <String>[];
    List<String> feedback = <String>[];
    void iterateFeedback(ItemFeedback s) {
      questions.add(s.question);
      feedback.add(s.answer);
    }

    final reference = FirebaseDatabase.instance.reference().child('HELLO').child("Feedback");
    s.forEach(iterateFeedback);
    reference.push().set({'Name': name, 'EventID': key, 'Feedback': feedback, 'Questions': questions});
  }

  static void submitSessionFeedback(String name, String eventKey, String sessionKey, List<ItemFeedback> s) {
    List<String> questions = <String>[];
    List<String> feedback = <String>[];
    void iterateFeedback(ItemFeedback s) {
      questions.add(s.question);
      feedback.add(s.answer);
    }

    final reference = FirebaseDatabase.instance.reference().child('HELLO').child("Feedback");
    s.forEach(iterateFeedback);
    reference.push().set({'Name': name, 'EventID': eventKey, 'SessionID': sessionKey, 'Feedback': feedback, 'Questions': questions});
  }

  static void submitEvent(ItemEvent newEvent) {
    final reference = FirebaseDatabase.instance.reference().child('HELLO').child("Events");
    reference.push().set({
      'Name': newEvent.name,
      'Description': newEvent.description,
      'Brief': newEvent.brief,
      'Venue': newEvent.venue,
      'VenueSpec': newEvent.venueSpec,
//      'StartDate': newEvent.fromdate.toString(),
//      'EndDate': newEvent.fromdate.toString(),
      'Banner': newEvent.banner,
      'Creator': "developer",
      'EventID': "sss",
      'Public': newEvent.public,
    });
  }

//  static Future<StreamSubscription<Event>> getSessions(
//      String todoKey, void onData(Sessions todo)) async {
//    StreamSubscription<Event> subscription = FirebaseDatabase.instance
//        .reference()
//        .child('HELLO')
//        .child('Modules')
//        .orderByChild("EventID")
//        .equalTo(todoKey)
//        .onValue
//        .listen((Event event) {
//      var todos =
//          new Sessions.fromJson(event.snapshot.key, event.snapshot.value);
//      onData(todos);
//    });
//
//    return subscription;
//  }
}
