import 'model.session.dart';
import 'model.attendance.dart';
import 'package:flutter/material.dart';
import 'ui.util.dart';
import 'controller.sessions.dart';
import 'ui.buttons.dart';
import 'controller.attendance.dart';
import 'dart:ui';

class EventViewSessionsBuild extends StatefulWidget {
  EventViewSessionsBuild({this.sessionHolder, this.attendanceHolder, this.isOverlaid, this.days = false, this.showSessionsButton});

  final Function(bool) isOverlaid;
  final VoidCallback showSessionsButton;

  final bool days;
  final SessionsHolder sessionHolder;
  final AttendanceHolder attendanceHolder;

  @override
  EventViewSessionState createState() =>
      EventViewSessionState(sessionHolder: sessionHolder, showSessionsButton: showSessionsButton, attendanceHolder: attendanceHolder, days: days, isOverlaid: isOverlaid);
}

class EventViewSessionState extends State<EventViewSessionsBuild> with TickerProviderStateMixin {
  EventViewSessionState({this.sessionHolder, this.attendanceHolder, this.isOverlaid, this.days, this.showSessionsButton});

  final bool days;
  final SessionsHolder sessionHolder;
  final AttendanceHolder attendanceHolder;

  final VoidCallback showSessionsButton;
  final Function(bool) isOverlaid;
  AnimationController _controller2;
  CurvedAnimation _curvedController2;
  Animation<double> animation2;
  Map<String, AttendanceStatus> sessionAttendance = {};

  List<dynamic> sortedDays = <dynamic>[];
  List<String> showSessions = <String>[];
  String selectedName;

  OverlayState oss;
  OverlayState oss2;
  OverlayEntry overlayEntry;
  OverlayEntry overlayEntry2;
  bool somethingIsExpanded = false;

  @override
  void initState() {
    _controller2 = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _curvedController2 = CurvedAnimation(parent: _controller2, curve: Curves.easeInOutQuint);
    animation2 = Tween<double>(end: 1, begin: 0).animate(_curvedController2);
    sessionHolder.getSessions(() {
      setState(() {
        List<dynamic> newDays = days ? sessionHolder.eventSlots.values.toList() : sessionHolder.eventDays.values.toList();
        newDays.sort((a, b) => a.start.datetime.compareTo(b.start.datetime));
        newDays.forEach((e) {
//          sortedDays.add(e); TODO DEBUG THINGY
          if (e.end.datetime.isAfter(DateTime.now().subtract(Duration(hours: 12))) || days) sortedDays.add(e);
        });
      });
    });
    attendanceHolder.getSessionsAttendance((SessionAttendance ss) {
      setState(() {
        sessionAttendance = ss.attendance;
      });
    });
    super.initState();
  }

  void hideExpanded() async {
    _controller2.reverse(from: 1);
    await Future.delayed(Duration(milliseconds: 600));
    overlayEntry2.remove();
    overlayEntry.remove();
    somethingIsExpanded = false;
    isOverlaid(somethingIsExpanded);
  }

  void showExpanded(Session ss, GlobalKey thisKey) async {
    if (!somethingIsExpanded) {
      somethingIsExpanded = true;
      isOverlaid(somethingIsExpanded);
      oss = Overlay.of(context);
      oss2 = Overlay.of(context);

      AttendanceStatus sas = attendanceHolder.sessions.attendance[ss.ID];
      String text = sas == null ? "Register" : sas.textStatus;

      RenderBox rbb = thisKey.currentContext.findRenderObject();
      double heightOffset = rbb.localToGlobal(Offset.zero).dy;
      Size medhi = MediaQuery.of(context).size;
      overlayEntry = OverlayEntry(
          builder: (context) => AnimatedBuilder(
                builder: (context, anim) {
                  return Positioned(
                    top: ((medhi.height - 500) / 2) + (heightOffset * (1 - animation2.value)) - (((medhi.height - 500) / 2) * (1 - animation2.value)),
                    width: MediaQuery.of(context).size.width,
                    child: SessionCardCard(
                      slot: sessionHolder.eventSlots[ss.slotID],
                      session: ss,
                      text: text,
                      onPressed: () => tryAttend(ss, text),
                      expand: hideExpanded,
                      direction: true,
                      height: 144 + (animation2.value * 356),
                    ),
                  );
                },
                animation: _controller2,
              ));

//      child: new BackdropFilter(
//          filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      overlayEntry2 = OverlayEntry(
          builder: (context) => Positioned(
                top: 0,
                left: 0,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                  child: Container(
                    height: medhi.height,
                    width: medhi.width,
                    decoration: BoxDecoration(
                      color: AppColors.appColorMainTransparent,
                    ),
                  ),
                ),
              ));
      oss2.insert(overlayEntry2);
      oss.insert(overlayEntry);
      _controller2.forward(from: 0);
    }
  }

  void tryAttend(Session ss, String sss) async {
    if (somethingIsExpanded) hideExpanded();
    attendanceHolder.tryAttend(ss, sss, (int i) {}, () => setState(() {}));
  }

  void changeSlot(s) {
    showSessions = <String>[];
    setState(() {
      s.runtimeType == Slot
          ? sessionHolder.getSlotSessions(s).forEach((Session sss) => showSessions.add(sss.ID))
          : sessionHolder.getDaySessions(s).forEach((Session sss) => showSessions.add(sessionAttendance.containsKey(sss.ID) ? sss.ID : null));
      selectedName = s.ID;
    });
  }

  SessionBrowserMarker createMarker(e, void onPressed()) {
    return SessionBrowserMarker(
      selected: e.ID == selectedName,
      top: e.name,
      bottom: "${e.start.time} - ${e.end.time}",
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> sessionKeys = days ? sessionHolder.map.keys.toList() : sessionAttendance.keys.toList();
    if (sessionKeys.toString() == "[]")
      sessionKeys.sort((a, b) => sessionHolder.eventSlots[sessionHolder.map[a].slotID].start.datetime.compareTo(sessionHolder.eventSlots[sessionHolder.map[b].slotID].start.datetime));
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == 0) {
            return sortedDays.length == 0
                ? SizedBox()
                : Container(
                    margin: EdgeInsets.fromLTRB(18, 20, 18, 0),
                    child: Text("Sessions you signed up for", style: AppTextStyles.styleWhiteBold(16)),
                  );
          } else if (index == 1) {
            return sortedDays.length == 0
                ? SizedBox()
                : Container(
                    margin: EdgeInsets.symmetric(vertical: 15),
                    height: 44,
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      scrollDirection: Axis.horizontal,
                      children: sortedDays.map<Widget>((e) => createMarker(e, () => changeSlot(e))).toList(),
                    ),
                  );
          } else if (index == sessionKeys.length + 2) {
            return showSessionsButton == null
                ? SizedBox()
                : Row(
                    children: <Widget>[
                      PunchOSFlatButton(
                        label: "View sessions for this event",
                        onPressed: showSessionsButton,
                        bold: true,
                      )
                    ],
                  );
          } else {
            Session ss = sessionHolder.map[sessionKeys[index - 2]];
            double thisHeight = (ss != null && showSessions.contains(ss.ID)) ? 166 : 0;

            return ss != null
                ? AnimatedContainer(
                    duration: thisHeight == 0 ? Duration(seconds: 1, milliseconds: 400) : Duration(milliseconds: 900),
                    curve: Curves.easeInOutCubic,
                    height: thisHeight,
                    child: SessionCard(
                      slot: sessionHolder.eventSlots[ss.slotID],
                      onPressed: tryAttend,
                      onTap: () => sessionHolder.showSessionScreen(ss, attendanceHolder),
                      showDetails: showExpanded,
                      session: ss,
                      attendance: sessionAttendance[ss.ID],
                    ),
                  )
                : SizedBox();
          }
        },
//        childCount: 2,
        childCount: sessionKeys == null ? 2 : sessionKeys.length + 3,
      ),
    );
  }
}

class SessionCardCard extends StatelessWidget {
  SessionCardCard({this.thisKey, this.session, this.onPressed, this.text, this.onTap, this.slot, this.height = 144, this.expand, this.direction = false});

  final VoidCallback expand;
  final VoidCallback onTap;
  final VoidCallback onPressed;
  final bool direction;
  final Slot slot;
  final Session session;
  final GlobalKey thisKey;
  final String text;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: thisKey,
      margin: EdgeInsets.symmetric(vertical: 11, horizontal: 18),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 50,
                right: 15,
                left: 15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      session.name,
                      style: AppTextStyles.bannerTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(session.venue, style: AppTextStyles.sessionVenue),
                  ],
                ),
              ),
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: AppColors.appAccentYellow),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text("${slot.start.time} - ${slot.end.time}", style: AppTextStyles.sessionTime),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 23, vertical: 18),
                      child: Text(text, style: AppTextStyles.sessionStatus),
                    ),
                    onTap: onPressed),
              ),
              Positioned(
                bottom: 20,
                left: 15,
                right: 15,
                top: 90,
                child: direction
                    ? SingleChildScrollView(
                        child: Text(session.description, style: AppTextStyles.bannerDescription, overflow: TextOverflow.fade),
                      )
                    : Text(session.description, style: AppTextStyles.bannerDescription, overflow: TextOverflow.fade),
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 30,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: FlatButton(
                        onPressed: expand,
                        child: Icon(direction ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: AppColors.appGreyscaleMinus),
                      )),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class SessionCard extends StatelessWidget {
  SessionCard({this.onTap, this.onPressed, this.session, this.attendance, this.slot, this.showDetails});

  final Function(Session, GlobalKey) showDetails;
  final Function(Session, String) onPressed;
  final VoidCallback onTap;
  final Session session;
  final Slot slot;
  final AttendanceStatus attendance;
  final GlobalKey thisKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    String text = attendance == null ? "Register" : attendance.textStatus;

    return SessionCardCard(
      thisKey: thisKey,
      session: session,
      onTap: onTap,
      slot: slot,
      text: text,
      expand: () => showDetails(session, thisKey),
      onPressed: () => onPressed(session, text),
    );
  }
}

class SessionBrowserMarker extends StatelessWidget {
  SessionBrowserMarker({this.top, this.bottom, this.onPressed, this.selected});

  final String top;
  final bool selected;
  final String bottom;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onPressed,
        child: Container(
          margin: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: selected ? AppColors.appAccentYellow : Color(0x00000000),
            border: selected ? null : Border.all(color: AppColors.appAccentYellow, width: 1, style: BorderStyle.solid),
          ),
          width: 115.0,
          child: Stack(
            children: <Widget>[
              Positioned(top: 7, left: 10, child: Text(top, style: selected ? AppTextStyles.slotName : AppTextStyles.styleWhiteBold(12))),
              Positioned(bottom: 7, left: 10, child: Text(bottom, style: selected ? AppTextStyles.slotTime : AppTextStyles.styleWhite(10))),
            ],
          ),
        ));
  }
}
