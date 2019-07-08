import 'package:flutter/material.dart';
import 'ui.util.dart';
import 'ui.backdrop.dart';
import 'util.dialog.dart';
import 'controller.sessions.dart';
import 'controller.calendar.dart';
import 'controller.attendance.dart';
import 'ui.list.session.dart';
import 'model.session.dart';
import 'model.attendance.dart';

class ScreenSessions extends StatelessWidget {
  ScreenSessions({this.sessions, this.calendarHolder, this.eventName});

  final SessionsHolder sessions;
  final AttendanceHolder calendarHolder;
  final String eventName;

  @override
  Widget build(BuildContext context) {
    return ScreenSessionsState(sessions: sessions, calendarHolder: calendarHolder, eventName: eventName);
  }
}

class ScreenSessionsState extends StatefulWidget {
  ScreenSessionsState({this.sessions, this.calendarHolder, this.eventName});

  final String eventName;
  final SessionsHolder sessions;
  final AttendanceHolder calendarHolder;

  @override
  _ScreenSessionsBuild createState() => _ScreenSessionsBuild(sessions: sessions, calendarHolder: calendarHolder, eventName: eventName);
}

class _ScreenSessionsBuild extends State<ScreenSessionsState> {
  _ScreenSessionsBuild({this.sessions, this.calendarHolder, this.eventName});

  GenericDialogGenerator dialog;
  final String eventName;
  final SessionsHolder sessions;
  final AttendanceHolder calendarHolder;
  List<Session> sessionList = <Session>[];
  String selectedID;
  List<Slot> sortedSlots = <Slot>[];

  @override
  void initState() {
    dialog = GenericDialogGenerator.init(context);
    sessions.getSessions(() {
      setState(() {
        sortedSlots = sessions.eventSlots.values.toList();
        sortedSlots.sort((a, b) => a.start.datetime.compareTo(b.start.datetime));
        sessionList = sortedSlots[0].slotSessions;
        selectedID = sortedSlots[0].ID;
      });
    });

    super.initState();
  }

  void showSessions(Session ss, GlobalKey gk) {
    sessions.showSessionScreen(ss, calendarHolder);
  }

  void showSlots(Session ss) {
    calendarHolder.registerSession(ss, () => setState(() => calendarHolder.checkAttendance(ss)));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          unselectedWidgetColor: AppColors.appGreyscalePlus,
        ),
        child: Stack(
          children: <Widget>[
            Backdrop2(),
            Scaffold(
              backgroundColor: const Color(0x00000000),
              appBar: AppBar(
                leading: IconButton(icon: Icon(Icons.keyboard_arrow_left), onPressed: () => Navigator.pop(context)),
                backgroundColor: AppColors.appColorBackground,
                title: Text("Sessions", style: AppTextStyles.appbarTitle),
              ),
              body: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return Padding(padding: EdgeInsets.only(left: 18, top: 20), child: Text(eventName, style: AppTextStyles.styleWhiteBold(20)));
                      },
                      childCount: 1,
                    ),
                  ),

                  EventViewSessionsBuild(
                    sessionHolder: sessions,
                    attendanceHolder: calendarHolder,
                    isOverlaid: (bool s){},
                    days: true,
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
