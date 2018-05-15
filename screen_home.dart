import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'model_events.dart';
import 'model_profile.dart';
import 'util_firebase.dart';
import 'util_account.dart';
import 'util_preferences.dart';
import 'ui_eventbanner.dart';
import 'screen_newEvent.dart';
import 'screen_profile.dart';
import 'screen_eventview.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

class ScreenHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ScreenHomeState();
  }
}

class ScreenHomeState extends StatefulWidget {
  @override
  _ScreenHomeBuild createState() => new _ScreenHomeBuild();
}

class _ScreenHomeBuild extends State<ScreenHomeState> {
  ItemProfile _profile = ItemProfile.create(null, "", "");
  StreamSubscription _subscriptionTodo;
  List<ItemEvent> _eventList = <ItemEvent>[];
  Image _photo =  null;

  void loggedIn(credentials) {
    setState(() {
      _profile = ItemProfile.saveCredentials(credentials);
      _photo = new Image.network(_profile.photo);
      AppPreferences.saveLogin(_profile);
      FirebaseMethods
          .getPrivateEvents("Attendees/" + AccountUtils.getUserKey(credentials.currentUser.email), _eventList, _updateEvents)
          .then((StreamSubscription s) => _subscriptionTodo = s);
    });
  }

  @override
  void initState() {
    AppPreferences.getLogin(_showLogin);
    super.initState();
  }

  _showLogin(ItemProfile p) {
    FirebaseMethods.getPublicEvents("Public", _updateEvents).then((StreamSubscription s) => _subscriptionTodo = s);
    setState(() {
      if (p.name != null) {
        _profile = p;
        _photo = new Image.network(_profile.photo);
      } else {
        _testSignInWithGoogle();
      }
    });
  }

  @override
  void dispose() {
    if (_subscriptionTodo != null) {
      _subscriptionTodo.cancel();
    }
    super.dispose();
  }

  Future _gotoScreenNewEvent() async {
    ItemEvent newEvent = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ScreenNewEvent()),
    );
    FirebaseMethods.submitEvent(newEvent);
    print(newEvent);
  }

  void _viewProfile() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ScreenProfile()),
    );
  }

  void _testSignInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    loggedIn(_googleSignIn);
  }

  void _showEventView(ItemEvent e) {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ScreenEventView(loadEvent: e)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        brightness: Brightness.light,
        platform: Theme.of(context).platform,
      ),
      child: new Stack(
        children: <Widget>[
          new Scaffold(
            body: new Column(
              children: <Widget>[
                new Container(
                  decoration: new BoxDecoration(
                      gradient: new LinearGradient(
                    begin: FractionalOffset.topRight,
                    end: FractionalOffset.bottomLeft,
                    colors: [
                      const Color.fromARGB(255, 59, 199, 222),
                      const Color.fromARGB(255, 91, 134, 229),
                    ],
                    stops: [0.0, 1.0],
                  )),
                  width: 1000.0,
                  height: 200.0,
                ),
              ],
            ),
          ),
          new Scaffold(
            appBar: new AppBar(
              actions: <Widget>[
                new InkWell(
                  onTap: _viewProfile,
                  child: new Container(
                    padding: EdgeInsets.all(8.0),
                    child: new ClipOval(
                      child: new Hero(
                        tag: "Avatar",
                        child: _photo,
                      ),
//                      child: new Image.network(_profile.photo),
                    ),
                  ),
                )
              ],
              elevation: 0.0,
              backgroundColor: const Color(0x00000000),
              title: new Text("PunchApp"),
            ),
            backgroundColor: const Color(0x00000000),
//            floatingActionButton: new FloatingActionButton(onPressed: _gotoScreenNewEvent),
            body: new CustomScrollView(slivers: <Widget>[
              new SliverList(
                delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return new EventBanner(
                        snapshot: _eventList[index],
                        onPressed: () {
                          _showEventView(_eventList[index]);
                        });
                  },
                  childCount: _eventList.length,
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }

  _updateEvents(ListEvent value) {
    setState(() {
      _eventList = value.eventList;
    });
  }
}
