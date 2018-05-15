import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'model_events.dart';
import 'model_feedback.dart';
import 'model_profile.dart';
import 'model_session.dart';
import 'model_sessionregistration.dart';
import 'util_firebase.dart';
import 'util_account.dart';
import 'ui_sessionbanner.dart';
import 'screen_questions.dart';
import 'screen_eventsessions.dart';
import 'screen_eventfeedback.dart';
import 'screen_newQuestion.dart';
import 'util_preferences.dart';

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
  bool _loggedIn = false;

  StreamSubscription _subscriptionTodo;
  List<ItemSession> _sessionList = <ItemSession>[];
  Map<String, String> _attendanceList = {};

  void loggedIn(credentials) {
    setState(() {
      _loggedIn = true;
      _profile = ItemProfile.saveCredentials(credentials);
      AppPreferences.saveLogin(_profile);

      if (loadEvent.attendeelist.containsKey(AccountUtils.getUserKey(_profile.email))) {
        if (loadEvent.attendeelist[AccountUtils.getUserKey(_profile.email)] == true) _registered = true;
      }
    });
  }

  @override
  void initState() {
    AppPreferences.getLogin(_showLogin);
    FirebaseMethods.getSessionDetails(loadEvent.key, _showSessions).then((StreamSubscription s) => _subscriptionTodo = s);
    super.initState();
  }

  _showLogin(ItemProfile p) {
    setState(() {
      if (p.name != null) {
        _loggedIn = true;
        _profile = p;
        if (loadEvent.attendeelist.containsKey(AccountUtils.getUserKey(_profile.email))) {
          if (loadEvent.attendeelist[AccountUtils.getUserKey(_profile.email)] == true) _registered = true;
        }
        FirebaseMethods
            .getMyEventRegisteredSessions(loadEvent.key, _profile.email, _showAttendance, _noAttendance)
            .then((StreamSubscription s) => _subscriptionTodo = s);
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

  void _gotoQuestions() {
    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) =>
            new ScreenQuestionView(
              loadEvent: loadEvent,
            )));
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

  Future _gotoFeedback() async {
    List<ItemFeedback> answers =
    await Navigator.push(
        context, new MaterialPageRoute(builder: (context) => new ScreenEventFeedback(loadEvent: loadEvent, questionlist: loadEvent.questionlist,)));
    if (answers != null) FirebaseMethods.submitFeedback(_profile.name, loadEvent.key, answers);
  }

  Future sendFeedback(ItemSession s) async {
    List<ItemFeedback> answers =
    await Navigator.push(
        context, new MaterialPageRoute(builder: (context) => new ScreenEventFeedback(loadEvent: loadEvent, questionlist: s.questionlist)));
    if (answers != null) FirebaseMethods.submitSessionFeedback(_profile.name, loadEvent.key, s.key, answers);
  }

  Future _registerSession() async {
    bool registered = await Navigator.push(context, new MaterialPageRoute(builder: (context) => new ScreenEventSessions(loadEvent: loadEvent)));
    if (registered)
      FirebaseMethods.registerMe(_profile.email, loadEvent.key, (() {
        setState(() {
          _registered = true;
        });
      }));
  }

  void _registerEvent() {
    if (_loggedIn) {
      FirebaseMethods.registerMe(_profile.email, loadEvent.key, (() {
        setState(() {
          _registered = true;
        });
      }));
    }
  }

  void _leaveEvent() {
    FirebaseMethods.unregisterMe(_profile.email, loadEvent.key, (() {
      setState(() {
        _registered = false;
      });
    }));
  }

  Future _editAttendance() async {
    await Navigator.push(context, new MaterialPageRoute(builder: (context) => new ScreenEventSessions(loadEvent: loadEvent)));
    FirebaseMethods
        .getMyEventRegisteredSessions(loadEvent.key, _profile.email, _showAttendance, _noAttendance)
        .then((StreamSubscription s) => _subscriptionTodo = s);
  }

  Future _askQuestion() async {
    String s = await Navigator.push(context, new MaterialPageRoute(builder: (context) => new ScreenNewQuestion()));
    if (s != null) FirebaseMethods.submitQuestion(_profile.name, _profile.photo, loadEvent.key, s);
  }

  Future askSessionQuestion(ItemSession session) async {
    String s = await Navigator.push(context, new MaterialPageRoute(builder: (context) => new ScreenNewQuestion()));
    if (s != null) FirebaseMethods.submitSessionQuestion(_profile.name, _profile.photo, loadEvent.key, session.key, s);
  }


  @override
  Widget build(BuildContext context) {
    RaisedButton toshow = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Register'),
      onPressed: null,
      disabledColor: Colors.grey.shade200,
    );

    RaisedButton register = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Register'),
      onPressed: _registerEvent,
    );
    RaisedButton registerSession = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Register'),
      onPressed: _registerSession,
    );

    RaisedButton leave = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Cancel my registration'),
      onPressed: _leaveEvent,
    );
    RaisedButton viewQuestions = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('View questions'),
      onPressed: _gotoQuestions,
    );

    RaisedButton editAttendance = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Edit my registration'),
      onPressed: _editAttendance,
    );

    RaisedButton ask = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Ask a question'),
      onPressed: _askQuestion,
    );

    //TODO ask session button
    RaisedButton askSession = new RaisedButton(
      textColor: Colors.white,
      child: const Text('Ask a question'),
      disabledColor: Colors.grey.shade200,
      onPressed: null,
    );

    RaisedButton rate = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Submit feedback'),
      onPressed: _gotoFeedback,
    );

    if (_registered) {
      if (new DateTime.now().isBefore(loadEvent.start.datetime)) {
        if (_sessionList.length > 0) {
          toshow = editAttendance;
        } else {
          toshow = leave;
        }
      } else {
        if (_sessionList.length > 0) {
          if (_attendanceList != null) {
            toshow = askSession;
          } else {
            toshow = editAttendance;
          }
        } else {
          toshow = ask;
        }
      }
      if (new DateTime.now().isAfter(loadEvent.end.datetime)) toshow = rate;
    } else {
      if (_loggedIn) {
        if (_sessionList.length > 0) {
          toshow = registerSession;
        } else {
          toshow = register;
        }
      }
    }

    List<Widget> buttons = <Widget>[];
    buttons.add(new Expanded(child: toshow));
    if (loadEvent.creator == _profile.email || _profile.email == "vcbrillantes@globe.com.ph") buttons.add(new Expanded(child: viewQuestions));

    return new Theme(
      data: new ThemeData(
        brightness: Brightness.light,
        platform: Theme
            .of(context)
            .platform,
      ),
      child: new Scaffold(
        bottomNavigationBar: new BottomAppBar(
          color: Colors.white,
          child: new Container(
            padding: const EdgeInsets.all(16.0),
            child: new Row(
                children: buttons
            ),
          ),
        ),
        appBar: new AppBar(
          title: new Text(loadEvent.name),
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
                        title: new Text(loadEvent.name, style: Theme
                            .of(context)
                            .textTheme
                            .title),
                      );
                    case 1:
                      return new Row(
                        children: <Widget>[
                          new Expanded(
                              child: new ListTile(
                                leading: const Icon(Icons.date_range),
                                title: new Text(loadEvent.start.longdate, style: Theme
                                    .of(context)
                                    .textTheme
                                    .body2),
                                subtitle: new Text(loadEvent.start.time + " - " + loadEvent.end.time, style: new TextStyle(color: Colors.grey)),
                              )),
                          new Expanded(
                              child: new ListTile(
                                leading: const Icon(Icons.location_on),
                                title: new Text(loadEvent.venue, style: Theme
                                    .of(context)
                                    .textTheme
                                    .body2),
                                subtitle: new Text(loadEvent.venueSpec, style: new TextStyle(color: Colors.grey)),
                              )),
                        ],
                      );
                    case 2:
                      return new Container(
                        padding: EdgeInsets.all(16.0),
                        child: new Text(loadEvent.description, style: Theme
                            .of(context)
                            .textTheme
                            .body1),
                      );
                  }
                },
                childCount: 4,
              ),
            ),
            new SliverList(
              delegate: new SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  void _askSessionQuestion() {
                    askSessionQuestion(_sessionList[index]);
                  }

                  void _sendFeedback() {
                    sendFeedback(_sessionList[index]);
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

  _showAttendance(ListSessionRegistrations v) {
    setState(() {
      _attendanceList = v.attendeelist;
    });
  }

  _noAttendance() {
    setState(() {
      _attendanceList = null;
    });
  }
}
