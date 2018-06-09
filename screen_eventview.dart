import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'model_events.dart';
import 'model_profile.dart';
import 'model_session.dart';
import 'model_sessionregistration.dart';
import 'model_eventdetail.dart';
import 'model_feedback.dart';
import 'util_firebase.dart';
import 'ui_sessionbanner.dart';
import 'screen_viewListSessions.dart';
import 'util_gcal.dart';
import 'screen_eventCreate.dart';
import 'dialog_feedback.dart';
import 'dialog_inquiry.dart';
import 'alert_QR.dart';
import 'dialog_reg_cancel.dart';
import 'util_preferences.dart';
import 'alert_M_registration.dart' as DialReg;
//import 'alert_registration.dart';
import 'util_qr.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:googleapis/calendar/v3.dart' as Cal;

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

class ScreenEventView extends StatelessWidget {
  ScreenEventView({this.loadEvent});

  final ItemEvent loadEvent;

  @override
  Widget build(BuildContext context) {
    return new ScreenEventViewState(loadEvent: loadEvent);
  }
}

class ScreenEventViewState extends StatefulWidget {
  ScreenEventViewState({this.loadEvent});

  final ItemEvent loadEvent;

  @override
  _ScreenEventViewBuild createState() => new _ScreenEventViewBuild(loadEvent: loadEvent);
}

class _ScreenEventViewBuild extends State<ScreenEventViewState> {
  _ScreenEventViewBuild({this.loadEvent});

  ItemProfile _profile;
  final ItemEvent loadEvent;
  final double _appBarHeight = 175.0;
  bool _registered = false;
  bool _confirmed = false;
  bool _loggedIn = false;
  bool _isCreator = false;
  bool _isCollaborator = false;
  bool _isInvited = false;
  int confirmed = 0;
  int registered = 0;
  StreamSubscription _subscriptionTodo;
  List<ItemSession> _sessionList = <ItemSession>[];
  Map<String, ItemSessionRegistration> _attendanceList = {};

  void loggedIn(credentials) {
    setState(() {
      _loggedIn = true;
      _profile = ItemProfile.saveCredentials(credentials);
      if (loadEvent.creator == _profile.userKey) _isCreator = true;
      if (loadEvent.collaborators.containsKey(_profile.userKey)) _isCollaborator = true;
      AppPreferences.saveLogin(_profile);
    });
  }

  @override
  void initState() {
    GoogleCalendar.eventDetails(loadEvent, eventRetrieved);
    AppPreferences.getLogin(_showLogin);
    FirebaseMethods.getAttendees(loadEvent.key, _showAttendees);
    FirebaseMethods.getSessionDetails(loadEvent.key, _showSessions);
    super.initState();
  }

  void eventRetrieved(Cal.Event e) {
    setState(() {
      loadEvent.gCal = e;
      _isInvited = true;
    });
  }

  _showLogin(ItemProfile p) {
    setState(() {
      if (p.name != null) {
        _loggedIn = true;
        _profile = p;
        if (loadEvent.creator == _profile.userKey) _isCreator = true;
        if (loadEvent.collaborators.containsKey(_profile.userKey)) _isCollaborator = true;
        FirebaseMethods.getAttendance(loadEvent.key, _profile.userKey, _showAttendance, _isConfirmed, _isRegistered, _noAttendance);
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

  void _showQRScreen() {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new ShowQR(
                  action: "JE",
                  loadEvent: loadEvent.event,
                )));
  }

  void _showQRScreenLeave() {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new ShowQR(
                  action: "LE",
                  loadEvent: loadEvent.event,
                )));
  }

  void sendFeedback(List<ItemFeedback> lq, ItemEventDetails d) {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new ScreenEventFeedback(
                  questionList: lq,
                  feedback: d,
                )));
  }

  Future _registerSession() async {
    if (_loggedIn) {
      await Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new ScreenEventSessions(sessionList: _sessionList, attendanceList: _attendanceList, loadEvent: loadEvent)));
      FirebaseMethods.getAttendance(loadEvent.key, _profile.userKey, _showAttendance, _isConfirmed, _isRegistered, _noAttendance);
    }
  }

  Future _registerEvent() async {
    if (_loggedIn) {
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => DialReg.RegistrationDialog(context, loadEvent)
      );
//      await Navigator.push(context, new MaterialPageRoute(builder: (context) => new AlertRegistration(loadEvent: loadEvent)));
      FirebaseMethods.getAttendance(loadEvent.key, _profile.userKey, _showAttendance, _isConfirmed, _isRegistered, _noAttendance);
    }
  }

  Future _leaveEvent() async {
    await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new ScreenCancelRegistrationState(
                  loadEvent: loadEvent.event,
                )));
    FirebaseMethods.getAttendance(loadEvent.key, _profile.userKey, _showAttendance, _isConfirmed, _isRegistered, _noAttendance);
  }

  void askQuestion() {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new ScreenNewQuestion(
                  questionKey: loadEvent.event,
                )));
  }

  Future showEventDetails(ItemEvent e) async {
    bool edited = await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new ScreenEventDetails(loadEvent: e)),
    );
    if (edited) print("EDITED");
    //TODO event refresh
  }

  void askSessionQuestion(ItemSession session) {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new ScreenNewQuestion(
                  questionKey: session.session,
                )));
  }

  @override
  Widget build(BuildContext context) {
    RaisedButton primaryButton;
    RaisedButton secondaryButton;

    RaisedButton register = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Register'),
      onPressed: _registerEvent,
    );
    RaisedButton gregister = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Accept'),
      onPressed: _registerEvent,
    );

    RaisedButton registerSession = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Join a session'),
      onPressed: _registerSession,
    );

    RaisedButton leave = new RaisedButton(
      color: Colors.grey.shade600,
      textColor: Colors.white,
      child: const Text('Cancel registration'),
      onPressed: _leaveEvent,
    );

    RaisedButton scan = new RaisedButton(
      color: Colors.green.shade600,
      textColor: Colors.white,
      child: const Text('Check-In'),
      onPressed: _checkin,
    );

    //TODO functionality for checkout
    RaisedButton scanout = new RaisedButton(
      color: Colors.green.shade600,
      textColor: Colors.white,
      child: const Text('Check-Out'),
      onPressed: _checkout,
    );

    RaisedButton showQR = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Show QR'),
      onPressed: _showQRScreen,
    );
    RaisedButton showLeaveQR = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Checkout QR'),
      onPressed: _showQRScreenLeave,
    );

    RaisedButton editAttendance = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Edit my registration'),
      onPressed: _registerSession,
    );

    RaisedButton ask = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Ask a question'),
      onPressed: askQuestion,
    );

    RaisedButton rate = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Submit feedback'),
      onPressed: (() {
        sendFeedback(loadEvent.questionlist, loadEvent.event);
      }),
    );

    if (_confirmed) {
      if (new DateTime.now().isBefore(loadEvent.event.end.datetime)) {
        //before event
        _sessionList.length > 0 ? primaryButton = editAttendance : primaryButton = ask;
        secondaryButton = scanout;
      } else {
        //after event
        if (_sessionList.length == 0) primaryButton = rate;
      }
    } else if (_registered) {
      if (new DateTime.now().isBefore(loadEvent.event.end.datetime)) {
        //before event
        _sessionList.length > 0 ? primaryButton = editAttendance : primaryButton = leave;
        secondaryButton = scan;
      }
    } else {
      if (_loggedIn) {
        if (new DateTime.now().isBefore(loadEvent.event.end.datetime)) {
          if (_sessionList.length > 0) {
            primaryButton = registerSession;
          } else {
            primaryButton = register;
            _isInvited ? primaryButton = gregister : primaryButton = register;
          }
        }
      }
    }

    InkWell editEvent;
    List<Widget> buttons = <Widget>[];
    if (primaryButton != null) buttons.add(new Expanded(child: primaryButton));
    buttons.add(new SizedBox(
      width: 5.0,
    ));
    if (secondaryButton != null) buttons.add(new Expanded(child: secondaryButton));

    if (_isCreator || _isCollaborator) {
      editEvent = new InkWell(
        child: new Icon(
          Icons.create,
          color: Colors.blue.shade500,
        ),
        onTap: (() {
          showEventDetails(loadEvent);
        }),
      );
      if (new DateTime.now().isBefore(loadEvent.event.end.datetime)) buttons.add(new Expanded(child: showQR));
      if (new DateTime.now().isAfter(loadEvent.event.start.datetime)) buttons.add(new Expanded(child: showLeaveQR));
    }

    BottomAppBar botNav;
    if (buttons.length > 0) {
      botNav = new BottomAppBar(
        color: Colors.white,
        child: new Container(
          padding: const EdgeInsets.all(16.0),
          child: new Row(children: buttons),
        ),
      );
    }
    return new Theme(
      data: new ThemeData(
        brightness: Brightness.light,
        platform: Theme.of(context).platform,
      ),
      child: new Scaffold(
        bottomNavigationBar: botNav,
        appBar: new AppBar(
          title: new Text(loadEvent.event.name),
        ),
        body: new CustomScrollView(
          slivers: <Widget>[
            new SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: _appBarHeight,
              flexibleSpace: new FlexibleSpaceBar(
                background: new Hero(
                    tag: loadEvent.key,
                    child: new Image.network(
                      loadEvent.banner,
                      fit: BoxFit.cover,
                    )),
              ),
            ),
            new SliverList(
              delegate: new SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  switch (index) {
                    case 0:
                      return new ListTile(
                        title: new Text(loadEvent.event.name, style: Theme.of(context).textTheme.title),
                        trailing: editEvent,
                        subtitle: new Text("$confirmed confirmed out of $registered registered attendees"),
                      );
                    case 1:
                      return new Row(
                        children: <Widget>[
                          new Expanded(
                              child: new ListTile(
                            leading: const Icon(Icons.date_range),
                            title: new Text(loadEvent.event.start.longdate, style: Theme.of(context).textTheme.body2),
                            subtitle:
                                new Text(loadEvent.event.start.time + " - " + loadEvent.event.end.time, style: new TextStyle(color: Colors.grey)),
                          )),
                          new Expanded(
                              child: new ListTile(
                            leading: const Icon(Icons.location_on),
                            title: new Text(loadEvent.event.venue, style: Theme.of(context).textTheme.body2),
                            subtitle: new Text(loadEvent.venueSpec, style: new TextStyle(color: Colors.grey)),
                          )),
                        ],
                      );
                    case 2:
                      return new Container(
                        padding: EdgeInsets.all(16.0),
                        child: new Text(loadEvent.event.description, style: Theme.of(context).textTheme.body1),
                      );
                  }
                },
                childCount: 3,
              ),
            ),
            new SliverList(
              delegate: new SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  void _askSessionQuestion() {
                    askSessionQuestion(_sessionList[index]);
                  }

                  void _sendFeedback() {
                    sendFeedback(_sessionList[index].questionlist, _sessionList[index].session);
                  }

                  return new SessionBanner(
                    snapshot: _sessionList[index],
                    attendanceList: _attendanceList,
                    onAsk: _askSessionQuestion,
                    onFeedback: _sendFeedback,
                  );
                },
                childCount: _sessionList.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showSessions(ListSession value) {
    setState(() {
      _sessionList = value.sessionList;
    });
  }

  _showAttendees(ListEventAttendees value) {
    setState(() {
      registered = value.attendeeList.length;
      confirmed = value.confirmedAttendees.length;
    });
    print(value.confirmedAttendees.length);
    print(value.attendeeList.length);
  }

  _showAttendance(ListSessionRegistrations v) {
    setState(() {
      _registered = true;
      _attendanceList = v.attendeelist;
    });
  }

  _isConfirmed() {
    setState(() {
      _confirmed = true;
      _registered = true;
    });
  }

  _isRegistered() {
    setState(() {
      _registered = true;
    });
  }

  _noAttendance() {
    setState(() {
      _registered = false;
      _attendanceList = null;
    });
  }

  Future _checkin() async {
    String barcode = await BarcodeScanner.scan();
    bool validQR = QRActions.readQR(_profile.userKey, barcode, "JE", loadEvent.key);
    if (validQR) {
      showDialog(
          context: context,
          child: new AlertDialog(
            content: new Text("Thank you for checking in!"),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ));
    } else {
      showDialog(
          context: context,
          child: new AlertDialog(
            content: new Text("QR is invalid"),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ));
    }
  }

  Future _checkout() async {
    String barcode = await BarcodeScanner.scan();
    bool validQR = QRActions.readQR(_profile.userKey, barcode, "LE", loadEvent.key);
    if (validQR) {
      showDialog(
          context: context,
          child: new AlertDialog(
            content: new Text("Thank you for attending the event! Please don't forget to leave feedback"),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ));
    } else {
      showDialog(
          context: context,
          child: new AlertDialog(
            content: new Text("QR is invalid"),
            actions: <Widget>[
              new FlatButton(
                child: new Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ));
    }
  }
}
