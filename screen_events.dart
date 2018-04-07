import 'dart:async';
import 'package:flutter/material.dart';
import 'item_todo.dart';
//import 'item_todos.dart';
import 'ui_banner.dart';
import 'util_firebase.dart';
import 'nav_iconview.dart';
import 'nav_customicon.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screen_responses.dart';

final googleSignIn = new GoogleSignIn();
final auth = FirebaseAuth.instance;

class ScreenEvents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new HomePage();
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  List<NavigationIconView> _navigationViews;
  List<Todo> _messages = <Todo>[];
  StreamSubscription _subscriptionTodo;

  @override
  void initState() {
//    _ensureLoggedIn();
    FirebaseTodos.getTodoStream("Public", _updateTodo)
        .then((StreamSubscription s) => _subscriptionTodo = s);
    super.initState();
    _navigationViews = <NavigationIconView>[
      new NavigationIconView(
        icon: const Icon(Icons.access_alarm),
        title: 'Alarm',
        color: Colors.deepPurple,
        vsync: this,
        fbref: "Public",
      ),
      new NavigationIconView(
        icon: new CustomIcon(),
        title: 'Box',
        color: Colors.deepOrange,
        vsync: this,
        fbref: "Attendees/vcbrillantesglobecomph",
      ),
      new NavigationIconView(
        icon: const Icon(Icons.cloud),
        title: 'Cloud',
        color: Colors.teal,
        vsync: this,
        fbref: "Attendees/vcbrillantesglobecomph",
      )
    ];
  }

  @override
  void dispose() {
    if (_subscriptionTodo != null) {
      _subscriptionTodo.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BottomNavigationBar botNavBar = new BottomNavigationBar(
      items: _navigationViews
          .map((NavigationIconView navigationView) => navigationView.item)
          .toList(),
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        setState(() {
          _navigationViews[_currentIndex].controller.reverse();
          _currentIndex = index;
          _navigationViews[_currentIndex].controller.forward();
          FirebaseTodos.getTodoStream(_navigationViews[_currentIndex].fbreference, _updateTodo)
              .then((StreamSubscription s) => _subscriptionTodo = s);
        });
      },
    );
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("App Bar Title"),
      ),
      body: new ListView.builder(
        padding: new EdgeInsets.all(8.0),
        itemCount: _messages.length,
        itemBuilder: (_, int index) {
          return new EventBanner(snapshot: _messages[index]);
        },
      ),
      bottomNavigationBar: botNavBar,
    );
  }


  _updateTodo(Todos value) {
    var name = value.todolist;
    setState((){
      _messages = name;
    });
  }
}











