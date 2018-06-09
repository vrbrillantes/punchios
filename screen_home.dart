import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'model_events.dart';
import 'model_profile.dart';
import 'util_firebase.dart';
import 'util_qr.dart';
import 'util_preferences.dart';
import 'ui_eventbanner.dart';
import 'screen_eventCreate.dart';
import 'screen_profile.dart';
import 'screen_eventView.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'ui_backdrop.dart';
import 'package:googleapis/calendar/v3.dart' as Cal;
import 'util_gcal.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn(
  scopes: ['https://www.googleapis.com/auth/calendar'],
);

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
  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  ItemProfile _profile = ItemProfile.create(null, "", "", "");
  StreamSubscription _subscriptionTodo;
  List<ItemEvent> _eventList = <ItemEvent>[];
  FloatingActionButton fab;

//  String barcode = "";

  void loggedIn(credentials) {
    setState(() {
      _profile = ItemProfile.saveCredentials(credentials);
      AppPreferences.saveLogin(_profile);

      _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) {
          print("onMessage: $message");
//          _showItemDialog(message);
        },
        onLaunch: (Map<String, dynamic> message) {
          print("onLaunch: $message");
//          _navigateToItemDetail(message);
        },
        onResume: (Map<String, dynamic> message) {
          print("onResume: $message");
//          _navigateToItemDetail(message);
        },
      );
      _firebaseMessaging.getToken().then((String token) {
        assert(token != null);
        AppPreferences.saveFCMToken(token);
        FirebaseMethods.registerToken(token, _profile.userKey);
      });
    });
  }

  @override
  void initState() {
    tryLogin();
    FirebaseMethods.getPublicEvents("Public", _updateEvents).then((StreamSubscription s) => _subscriptionTodo = s);
//    fab = new FloatingActionButton(
//      onPressed: _readQR,
//      child: const Icon(Icons.select_all),
//    );
    super.initState();
  }

  void tryLogin() async {
    AppPreferences.getLogin((ItemProfile p) {
      setState(() {
        if (p.name != null) {
          _profile = p;
          FirebaseMethods.getAdmins(_profile.userKey, showAdmin);
        } else {
          _testSignInWithGoogle();
        }
      });
    });
  }

  void showAdmin(bool isAdmin) {
    if (isAdmin) {
      setState(() {
        fab = new FloatingActionButton(
          onPressed: _gotoScreenNewEvent,
          child: const Icon(Icons.add),
        );
      });
    }
  }

  @override
  void dispose() {
    if (_subscriptionTodo != null) {
      _subscriptionTodo.cancel();
    }
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(
        brightness: Brightness.light,
        platform: Theme
            .of(context)
            .platform,
      ),
      child: new Stack(
        children: <Widget>[
          new Backdrop(),
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
                        child: new Image.network(_profile.photo),
                      ),
                    ),
                  ),
                )
              ],
              elevation: 0.0,
              backgroundColor: const Color(0x00000000),
              title: new Text("PunchApp"),
            ),
            backgroundColor: const Color(0x00000000),
            floatingActionButton: fab,
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
    GoogleCalendar.eventListCheck(value.eventList, (ItemEvent el) {
      setState(() {
        print("adding" + el.event.name);
        _eventList.add(el);
      });
    });
  }

  void _viewProfile() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ScreenProfile()),
    );
  }

  void _showEventView(ItemEvent e) {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ScreenEventView(loadEvent: e)),
    );
  }

  void _gotoScreenNewEvent() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ScreenEventDetails()),
    );
  }

  Future _readQR() async {
    String barcode = await BarcodeScanner.scan();
    QRActions.readQR(_profile.userKey, barcode, null, null);
  }
}
