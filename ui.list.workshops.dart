import 'model.session.dart';
import 'model.attendance.dart';
import 'package:flutter/material.dart';
import 'ui.util.dart';
import 'controller.sessions.dart';
import 'controller.attendance.dart';

class WorkshopView extends StatefulWidget {
  WorkshopView({this.sessionHolder, this.calendarHolder});

  final SessionsHolder sessionHolder;
  final AttendanceHolder calendarHolder;

  @override
  WorkshopViewState createState() => WorkshopViewState(sessionHolder: sessionHolder, calendarHolder: calendarHolder);
}

class WorkshopViewState extends State<WorkshopView> with TickerProviderStateMixin {
  WorkshopViewState({this.sessionHolder, this.calendarHolder});

  final SessionsHolder sessionHolder;
  final AttendanceHolder calendarHolder;

  Map<String, SessionAttendanceStatus> sessionAttendance = {};

  String selectedName;

//  List<dynamic> sortedDays = <dynamic>[];
//  List<String> showSessions = <String>[];
//
//  OverlayState oss;
//  OverlayState oss2;
//  OverlayEntry overlayEntry;
//  OverlayEntry overlayEntry2;
//  bool somethingIsExpanded = false;

  @override
  void initState() {
    _controller2 = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _curvedController2 = CurvedAnimation(parent: _controller2, curve: Curves.easeInOutCubic);
    animation2 = Tween<double>(end: 1, begin: 0).animate(_curvedController2);
    animation1 = Tween<double>(end: 0, begin: 0).animate(_curvedController2);
    sessionHolder.getSessions(() => setState(() {}));
    calendarHolder.getSessionsAttendance((SessionAttendance ss) => setState(() => sessionAttendance = ss.attendance));
    super.initState();
  }

  void changeMe(String newName) {
    setState(() {
      selectedName != null
          ? _controller2.reverse().then((_) {
              if (selectedName != newName) {
                setState(() {
                  selectedName = newName;
                  _controller2.forward();
                });
              } else {
                setState(() => selectedName = null);
              }
            })
          : setState(() {
              _controller2.forward();
              selectedName = newName;
            });
    });
  }

  AnimationController _controller2;
  CurvedAnimation _curvedController2;
  Animation<double> animation2;
  Animation<double> animation1;

  void tryAttend(Workshop ss, String sss) async {
    calendarHolder.tryAttendWorkshop(ss, sss, (int i) {}, () => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    List<String> tracks = sessionHolder.eventTracks.keys.toList();
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == 0) {
            return tracks.length == 0
                ? SizedBox()
                : Container(
                    margin: EdgeInsets.fromLTRB(18, 20, 18, 0),
                    child: Text("Sessions you signed up for", style: AppTextStyles.styleWhiteBold(16)),
                  );
          } else {
            Track ss = sessionHolder.eventTracks[tracks[index - 1]];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 9, horizontal: 18),
              child: Column(
                children: <Widget>[
                  InkWell(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: ClipOval(
                              child: Container(
                                child: Icon(
                                  selectedName == ss.ID ? Icons.expand_less : Icons.expand_more,
                                  color: AppColors.appColorWhite,
                                ),
                                decoration: BoxDecoration(color: AppColors.appAccentPurple),
                              ),
                            ),
                          ),
                          padding: EdgeInsets.all(11),
                        ),
                        Expanded(
                          child: Text(
                            ss.name,
                            style: AppTextStyles.styleDarkPurpleBold(14),
                          ),
                        ),
                      ],),
                    onTap: () => changeMe(ss.ID),
                  ),
                  SizeTransition(
                    sizeFactor: selectedName == ss.ID ? animation2 : animation1,
                    child: Column(
                      children: ss.trackWorkshops.map<Widget>((Workshop ww) => WorkshopCardCard(workshop: ww)).toList(),
                    ),
                  )
                ],
              ),
            );
          }
        },
        childCount: tracks == null ? 1 : tracks.length + 1,
      ),
    );
  }
}

class WorkshopCardCard extends StatelessWidget {
  WorkshopCardCard({this.workshop, this.onPressed, this.text, this.onTap, this.height = 75, this.expand, this.direction = false});

  final VoidCallback expand;
  final VoidCallback onTap;
  final VoidCallback onPressed;
  final bool direction;
  final Workshop workshop;
  final String text;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.only(left: 45),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 37,
            right: 15,
            left: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  workshop.name,
                  style: AppTextStyles.workshopTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            top: 15,
            left: 0,
            child: Text("${workshop.start.time} - ${workshop.end.time}", style: AppTextStyles.workshopTime),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: InkWell(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 23, vertical: 18),
                  child: Text("checked-in", style: AppTextStyles.sessionStatus),
                ),
                onTap: onPressed),
          ),
        ],
      ),
    );
  }
}
