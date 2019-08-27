import 'package:flutter/material.dart';
import 'model.events.dart';
import 'model.profile.dart';

import 'ui.backdrop.dart';
import 'ui.eventWidgets.dart';
import 'ui.util.dart';
import 'ui.buttons.dart';
import 'ui.eventActions.dart';
import 'ui.list.session.dart';
import 'ui.list.workshops.dart';

import 'util.qr.dart';
import 'util.dialog.dart';
import 'util.internet.dart';

import 'screen.sessions.dart';
import 'controller.participation.dart';
import 'controller.attendance.dart';
import 'controller.sessions.dart';
import 'controller.events.dart';
import 'ui.list.badges.dart';

class ScreenEventArguments {
  final Event loadEvent;
  final Profile profile;

  ScreenEventArguments({this.profile, this.loadEvent});
}

class ScreenEventView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ScreenEventArguments args = ModalRoute.of(context).settings.arguments;
    return new ScreenEventViewState(args: args);
  }
}

class ScreenEventViewState extends StatefulWidget {
  ScreenEventViewState({this.args});

  final ScreenEventArguments args;

  @override
  _ScreenEventViewBuild createState() => new _ScreenEventViewBuild(args: args);
}

class _ScreenEventViewBuild extends State<ScreenEventViewState> with TickerProviderStateMixin {
  _ScreenEventViewBuild({this.args});

  final ScreenEventArguments args;

  GenericDialogGenerator dialog;
  PunchInternetUtils netUtils;
  SessionsHolder sessionsHolder;
  EventHolder eventHolder;

  BadgesHolder badgesHolder;
  ParticipationHolder participationHolder;
  AttendanceHolder attendanceHolder;

  Profile profile;
  Event loadEvent;
  AttendeeHolder eventAttendees;

  bool isAwaitingRegistration = false;
  bool isOverlaid = false;
  bool isOnline = false;

  bool buttonsDone = false;
  bool editing = false;

  bool showDetails = false;
  bool showShowMore = false;

  @override
  void initState() {
    loadEvent = args.loadEvent;
    profile = args.profile;
    dialog = GenericDialogGenerator.init(context);
    eventHolder = EventHolder(context, loadEvent);
    participationHolder = ParticipationHolder(context, loadEvent, profile);
    attendanceHolder = AttendanceHolder.newCalendarHolder(context, profile, loadEvent);
    badgesHolder = BadgesHolder(context, loadEvent.eventID, profile.profileLogin.userKey);
    sessionsHolder = SessionsHolder(context, loadEvent.eventID);
    eventAttendees = AttendeeHolder.init(loadEvent.eventID);
    netUtils = PunchInternetUtils(onlineInitState, (bool s) {
      setStatus(s);
    });

    _controller2 = AnimationController(vsync: this, duration: Duration(milliseconds: 999));
    _curvedController2 = CurvedAnimation(parent: _controller2, curve: Curves.easeInOutCubic);
    animation2 = Tween<double>(end: 1, begin: 0).animate(_curvedController2);
    super.initState();
  }

  void onlineInitState(bool s) {
    setStatus(s);
    setStatus(s);
    eventHolder.getCollaborators(() => setState(() {}));
    eventHolder.getLinks(() => setState(() {}));
    attendanceHolder.getAttendance((bool isRegistered) {
      setState(() {
        showDetails = !isRegistered;
        showShowMore = isRegistered;
        if (isAwaitingRegistration && attendanceHolder.attendance.checkedIn) {
          Navigator.pop(context);
          isAwaitingRegistration = false;
          dialog.confirmDialog(dialog.checkedInString(loadEvent.eventDetails.name));
        }
      });
    });
    eventAttendees.getFirebase(isOnline, () => setState(() {}));
    sessionsHolder.getSessions(() => setState(() {}));
  }

  void setStatus(bool s) {
    setState(() {
      sessionsHolder.setStatus(s);
      eventHolder.setStatus(s);
      attendanceHolder.setStatus(s);

      isOnline = s;
    });
  }

  void toggleDetails() {
    setState(() {
      showDetails = !showDetails;
    });
  }

  void actionPressed(String s) {
    switch (s) {
      case "feedback":
        participationHolder.sendFeedback(eventHolder.isCollaborator(profile.email), () => attendanceHolder.setFeedback(() => setState(() {})));
        break;
      case "notif":
        eventHolder.sendNotifications();
        break;
      case "question":
        participationHolder.gotoQuestions(eventHolder.isCollaborator(profile.email));
        break;
      case "checkin":
        isAwaitingRegistration = true;
        attendanceHolder.checkIn();
        break;
      case "checkout":
        attendanceHolder.checkOut();
        break;
      case "register":
        loadEvent.regQuestions ? participationHolder.sendRegistrationQuestions(attendanceHolder.register) : attendanceHolder.register();
        break;
      case "cancel":
        attendanceHolder.cancel(() => setState(() {}));
        break;
      case "admin":
        showAdminActions();
        break;
      case "noFB":
        dialog.confirmDialog(dialog.feedbackNotAvailable);
        break;
      case "collab":
        eventHolder.showCollab();
        break;
      case "showScanned":
        showScanned();
        break;
      case "scanSession":
        scanAttendeeSession();
        break;
      case "scan":
        scanAttendee();
        break;
      case "sessions":
        gotoSessions();
        break;
      case "doneEditing":
        setState(() {
          editing = false;
        });
        break;
      case "edit":
        setState(() {
          editing = true;
        });
        break;
    }
  }

  void gotoSessions() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ScreenSessions(
                  eventName: loadEvent.eventDetails.name,
                  sessions: sessionsHolder,
                  calendarHolder: attendanceHolder,
                )));
  }

  void showAdminActions() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return AdminButtons(
            myAttendance: attendanceHolder.attendance,
            onPress: (String action) {
              Navigator.pop(context);
              actionPressed(action);
            },
          );
        });
  }

  void showScanned() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return CheckedInList(
            collabs: eventAttendees.scannedAttendees.keys.map((v) => v.toString() + " " + eventAttendees.scannedAttendees[v]['direction']).toList(),
          );
        });
  }

  void scanAttendee() {
    QRActions.scanCheckInAttendee(
        eventID: loadEvent.eventID,
        returnCode: (String s, String dir) => dir == "IN"
            ? eventAttendees.checkIn(s, isOnline, (bool s) {
                if (s) dialog.confirmDialog(dialog.checkedInAttendeeString);
              })
            : eventAttendees.checkOut(s, isOnline, (bool s) {
                if (s) dialog.confirmDialog(dialog.checkOutAttendeeString);
              }),
        wrongQR: () => dialog.confirmDialog(dialog.wrongQRString));
  }

  void scanAttendeeSession() {
    QRActions.scanCheckInAttendeeSession(
        returnCode: (userKey, sessionID, dir) => eventAttendees.checkInSession(sessionsHolder.map[sessionID].slotID, userKey, dir, isOnline, (bool s) {
              if (s) dialog.confirmDialog(dir == "IN" ? dialog.checkedInAttendeeString : dialog.checkOutAttendeeString);
            }),
        wrongQR: () => dialog.confirmDialog(dialog.wrongQRString));
  }

  Future<bool> checkOverlay() {
    if (isOverlaid == false) {
      attendanceHolder.disposeSubscriptions();
      Navigator.pop(context);
    }
    return null;
  }

  void setOverlay(bool s) {
    setState(() {
      isOverlaid = s;
    });
  }

  AnimationController _controller2;
  CurvedAnimation _curvedController2;
  Animation<double> animation2;

  String selectedView = "";

  @override
  Widget build(BuildContext context) {
    double screenSize = (MediaQuery.of(context).size.width - 36) / 9;
    if (attendanceHolder.attendance != null) attendanceHolder.setTime(loadEvent);

    if (showDetails) {
      _controller2.forward();
    } else {
      _controller2.reverse();
    }
    return new Theme(
      data: new ThemeData(
        brightness: Brightness.light,
        platform: Theme.of(context).platform,
      ),
      child: new Stack(
        children: <Widget>[
          Backdrop2(),
          WillPopScope(
            onWillPop: () => checkOverlay(),
            child: Scaffold(
              backgroundColor: const Color(0x00000000),
              appBar: AppBar(
                leading: IconButton(icon: Icon(Icons.keyboard_arrow_left), onPressed: checkOverlay),
                backgroundColor: AppColors.appColorBackground,
                title: Text(loadEvent.eventDetails.name, style: AppTextStyles.appbarTitle),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              floatingActionButton: EventActions(
                myAttendance: attendanceHolder.attendance,
                editing: editing,
                isCollaborator: eventHolder.isCollaborator(profile.email),
                actionPressed: actionPressed,
              ),
              body: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    flexibleSpace: StaticBanner(loadEvent: loadEvent),
                    expandedHeight: 200,
                    automaticallyImplyLeading: false,
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        if (index == 0)
                          return Container(
                            color: AppColors.appColorWhite,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  EventStatus(myAttendance: attendanceHolder.attendance),
                                  Padding(
                                    padding: EdgeInsets.all(18),
                                    child: Text(loadEvent.eventDetails.name, style: AppTextStyles.eventTitle),
                                  ),
                                  EventDetailsBar(loadEvent: loadEvent),
                                  sessionsHolder.hasSessions() ? SessionDetailsBar(onPressed: gotoSessions) : SizedBox(),
                                  showShowMore
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            PunchOSFlatButton(onPressed: toggleDetails, label: "Show more", bold: true),
                                          ],
                                        )
                                      : SizedBox(),
                                  SizeTransition(
                                    sizeFactor: animation2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        AttendeesDetailsBar(loadEvent: loadEvent, eventAttendees: eventAttendees.regAttendeeCount),
                                        Padding(
                                          padding: EdgeInsets.all(18),
                                          child: Text(loadEvent.eventDetails.longDescription, style: AppTextStyles.eventDetailsGrey),
                                        ),
                                        RelatedInfoDetailsBar(eventLinks: eventHolder.eventLinks),
//                                        Padding(
//                                          padding: EdgeInsets.all(18),
//                                          child: EventIcons(space: false, interestedval: loadEvent.isInterested),
//                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 18)
                                ],
                              ),
                            ),
                          );
                      },
                      childCount: 1,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        void changeView(String s) {
                          setState(() {
                            selectedView = s;
                          });
                        }

                        List<String> buttons = <String>[];

                        if (badgesHolder.hasBadges()) buttons.add('Booths');
                        if (sessionsHolder.hasSessions()) buttons.add('Sessions');
                        if (sessionsHolder.hasWorkshops()) buttons.add('Workshops');
                        return SessionNavigationFlatButton(
                          changeView: changeView,
                          buttons: buttons,
                          selected: selectedView,
                        );
                      },
                      childCount: 1,
                    ),
                  ),
//                  SliverList(
//                    delegate: SliverChildBuilderDelegate(
//                      (BuildContext context, int index) => AnimatedSwitcher(
//                            duration: const Duration(milliseconds: 500),
//                            transitionBuilder: (Widget child, Animation<double> animation) {
//                              return ScaleTransition(child: child, scale: animation);
//                            },
//                            child: selectedView == "Booths" ? ListBadges(badgesHolder, screenSize) : SizedBox(),
//                          ),
//                      childCount: 1,
//                    ),
//                  ),
                  selectedView == "Sessions"
                      ? EventViewSessionsBuild(
                          sessionHolder: sessionsHolder,
                          attendanceHolder: attendanceHolder,
                          isOverlaid: setOverlay,
                          showSessionsButton: gotoSessions,
                        )
                      : (selectedView == "Booths"
                          ? SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  return ListBadges(badgesHolder, screenSize);
                                },
                                childCount: 1,
                              ),
                            )
                          : (selectedView == "Workshops"
                              ? WorkshopView(
                                  sessionHolder: sessionsHolder,
                                  calendarHolder: attendanceHolder,
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) => SizedBox(),
                                    childCount: 1,
                                  ),
                                ))),
                  EventActions2(
                    isOnline: isOnline,
                    myAttendance: attendanceHolder.attendance,
                    actionPressed: actionPressed,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
