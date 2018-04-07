import 'item_todo.dart';
import 'util_preferences.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class FirebaseTodos {
  /// FirebaseTodos.getTodoStream("-KriJ8Sg4lWIoNswKWc4", _updateTodo)
  /// .then((StreamSubscription s) => _subscriptionTodo = s);
  static Future<StreamSubscription<Event>> getTodoStream(String todoKey,
      void onData(Todos todo)) async {
    String accountKey = await Preferences.getAccountKey();

    StreamSubscription<Event> subscription = FirebaseDatabase.instance
        .reference()
        .child('HELLO')
        .child('Events')
//        .child('-L56EyFw3Ymm3o6A56jM')
        .orderByChild(todoKey)
        .equalTo(true)
        .onValue
        .listen((Event event) {
      var todos = new Todos.fromJson(event.snapshot.key, event.snapshot.value);
      onData(todos);
    });

    return subscription;
  }

//  /// FirebaseTodos.getTodo("-KriJ8Sg4lWIoNswKWc4").then(_updateTodo);
//  static Future<Todo> getTodo(String todoKey) async {
//    Completer<Todo> completer = new Completer<Todo>();
//
//    String accountKey = await Preferences.getAccountKey();
//
//    FirebaseDatabase.instance
//        .reference()
//        .child('HELLO')
//        .child('Events')
//        .child('-L56EyFw3Ymm3o6A56jM')
////        .orderByChild('Public')
////        .equalTo(true)
//        .once()
//        .then((DataSnapshot snapshot) {
//      var todo = new Todo.fromJJ(snapshot.key, snapshot.value);
//      completer.complete(todo);
//    });
//
//    return completer.future;
//  }
}