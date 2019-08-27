import 'package:flutter/material.dart';
import 'controller.attendance.dart';
import 'util.dialog.dart';
import 'model.session.dart';
import 'ui.backdrop.dart';
import 'ui.util.dart';
import 'ui.buttons.dart';
import 'screen.questions.dart';
import 'controller.participation.dart';

class ScreenSessionView extends StatelessWidget {
  ScreenSessionView({this.session, this.attendance, this.slot});

  final AttendanceHolder attendance;
  final Session session;

  final Slot slot;

  @override
  Widget build(BuildContext context) {
    return new ScreenSessionViewState(session: session, attendance: attendance, slot: slot);
  }
}

class ScreenSessionViewState extends StatefulWidget {
  ScreenSessionViewState({this.session, this.attendance, this.slot});

  final AttendanceHolder attendance;
  final Slot slot;

  final Session session;

  @override
  _ScreenSessionViewBuild createState() => new _ScreenSessionViewBuild(session: session, attendance: attendance, slot: slot);
}

class _ScreenSessionViewBuild extends State<ScreenSessionViewState> {
  _ScreenSessionViewBuild({this.session, this.attendance, this.slot});

  final AttendanceHolder attendance;
  final Slot slot;
  final Session session;
  ParticipationHolder pp;

  GenericDialogGenerator dialog;
  bool isQuestionTime = false;
  bool isFeedbackTime = false;
  bool isFinished = false;

  @override
  void initState() {
    dialog = GenericDialogGenerator.init(context);
    setTime();
    pp = ParticipationHolder.session(context, attendance.event, session, attendance.profile);
    super.initState();
  }

  void showQA() {
    Navigator.pushNamed(context, '/questions', arguments: ScreenQuestionAruments(profile: attendance.profile, eventID: session.eventID, sessionID: session.ID, isAdmin: false));
  }

  void setTime() {
    if (DateTime.now().isAfter(slot.end.datetime.subtract(Duration(minutes: 30)))) {
      isFeedbackTime = true;
    }
    if (DateTime.now().isAfter(slot.end.datetime)) {
      isFinished = true;
    }
    if (DateTime.now().isAfter(slot.start.datetime) && DateTime.now().isBefore(slot.end.datetime.add(Duration(minutes: 30)))) {
      isQuestionTime = true;
    }
  }

  Widget firstButton() {
    if (attendance.sessions.attendance.containsKey(session.ID)) {
      if (attendance.sessions.attendance[session.ID].checkedOut)
        return SizedBox();
      else if (attendance.sessions.attendance[session.ID].feedback)
        return PunchRaisedButton(
          label: "Check out",
          action: () => attendance.checkInSession(session, "OUT", 0),
        );
      else if (attendance.sessions.attendance[session.ID].checkedIn && isQuestionTime)
        return PunchRaisedButton(label: "Ask a question", action: showQA);
      else if (!attendance.sessions.attendance[session.ID].checkedIn) return PunchOutlineButton(label: "Cancel", action: () => attendance.cancelSession(session.slotID, () {}));
    }
    return SizedBox();
  }

  Widget thirdButton() {
    return PunchRaisedButton(
        label: "Register",
        action: () => attendance.registerSession(
            session,
            () => setState(() {
                  attendance.checkAttendance(session);
                })));
  }

  Widget fifthButton() {
    return PunchRaisedButton(
      label: "Check out",
      action: () => attendance.checkInSession(session, "OUT", 0),
    );
  }

  Widget fourthButton() {
    return PunchRaisedButton(
      label: "Send feedback",
      action: () => pp.sendFeedbackSession(
          false,
          () => attendance.setFeedbackSession(
                slot.ID,
                () => setState(() {}),
              )),
    );
  }

  Widget secondButton() {
    if (attendance.sessions.attendance.containsKey(session.ID)) {
      if (attendance.sessions.attendance[session.ID].checkedIn && isFeedbackTime && !attendance.sessions.attendance[session.ID].feedback)
        return PunchRaisedButton(
          label: "Send feedback",
          action: () => pp.sendFeedbackSession(
              false,
              () => attendance.setFeedbackSession(
                    slot.ID,
                    () => setState(() {}),
                  )),
        );
    }
    return SizedBox();
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
          Backdrop2(),
          Scaffold(
            backgroundColor: const Color(0x00000000),
            appBar: AppBar(
              leading: IconButton(icon: Icon(Icons.keyboard_arrow_left), onPressed: () => Navigator.pop(context)),
              backgroundColor: AppColors.appColorBackground,
              title: Text(session.name, style: AppTextStyles.appbarTitle),
            ),
            body: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Container(
                        color: Color(0x00000000),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 24),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                                child: Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: AppColors.appAccentYellow),
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Text("${slot.start.time} - ${slot.end.time}", style: AppTextStyles.sessionTime),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(session.name, style: AppTextStyles.styleWhiteBold(16)),
                                    SizedBox(height: 7),
                                    Text(session.venue, style: AppTextStyles.styleWhiteBold(14)),
                                    SizedBox(height: 16),
                                    Text(session.description, style: AppTextStyles.styleWhite(14)),
                                  ],
                                ),
                              ),

                              attendance.sessions.mySlots.containsKey(session.slotID)
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                                      child: Text(attendance.sessions.mySlots[session.slotID] == session.ID ? "Registered to this session" : "Registered to another session",
                                          style: AppTextStyles.styleWhiteBold(12)),
                                    )
                                  : thirdButton(),
                              firstButton(),
                              secondButton(),
//                              thirdButton(),//TODO TESTING REMOVE ALL OTHER BUTTONS
//                              fourthButton(),
//                              fifthButton(),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
