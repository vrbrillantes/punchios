import 'package:flutter/material.dart';
import 'controller.attendance.dart';
import 'util.dialog.dart';
import 'model.session.dart';
import 'controller.participation.dart';
import 'ui.backdrop.dart';
import 'ui.util.dart';
import 'ui.buttons.dart';
import 'screen.questions.dart';

class ScreenWorkshopView extends StatelessWidget {
  ScreenWorkshopView({this.workshop, this.attendance});

  final AttendanceHolder attendance;
  final Workshop workshop;

  @override
  Widget build(BuildContext context) {
    return new ScreenWorkshopViewState(workshop: workshop, attendance: attendance);
  }
}

class ScreenWorkshopViewState extends StatefulWidget {
  ScreenWorkshopViewState({this.workshop, this.attendance});

  final AttendanceHolder attendance;

  final Workshop workshop;

  @override
  _ScreenWorkshopViewBuild createState() => new _ScreenWorkshopViewBuild(workshop: workshop, attendance: attendance);
}

class _ScreenWorkshopViewBuild extends State<ScreenWorkshopViewState> {
  _ScreenWorkshopViewBuild({this.workshop, this.attendance});

  final AttendanceHolder attendance;
  final Workshop workshop;
  ParticipationHolder pp;

  GenericDialogGenerator dialog;
  bool isQuestionTime = false;
  bool isFeedbackTime = false;
  bool isFinished = false;

  @override
  void initState() {
    dialog = GenericDialogGenerator.init(context);
    setTime();
    pp = ParticipationHolder.workshop(context, attendance.event, workshop, attendance.profile);
    super.initState();
  }

  void showQA() {
    Navigator.pushNamed(context, '/questions', arguments: ScreenQuestionAruments(profile: attendance.profile, eventID: workshop.eventID, sessionID: workshop.ID, isAdmin: false));
  }

  void setTime() {
    if (DateTime.now().isAfter(workshop.end.datetime.subtract(Duration(minutes: 30)))) {
      isFeedbackTime = true;
    }
    if (DateTime.now().isAfter(workshop.end.datetime)) {
      isFinished = true;
    }
    if (DateTime.now().isAfter(workshop.start.datetime) && DateTime.now().isBefore(workshop.end.datetime.add(Duration(minutes: 30)))) {
      isQuestionTime = true;
    }
  }

  Widget firstButton() {
    if (attendance.workshopAttendance.containsKey(workshop.ID)) {
      if (attendance.workshopAttendance[workshop.ID].attendance.checkedOut)
        return null;
      else if (attendance.workshopAttendance[workshop.ID].attendance.feedback)
        return PunchRaisedButton(
          label: "Check out",
          action: () => attendance.checkInWorkshop(workshop, attendance.workshopAttendance[workshop.ID].key, "OUT", 0),
        );
      else if (attendance.workshopAttendance[workshop.ID].attendance.checkedIn && isQuestionTime)
        return PunchRaisedButton(label: "Ask a question", action: showQA);
      else if (!attendance.workshopAttendance[workshop.ID].attendance.checkedIn)
        return PunchOutlineButton(label: "Cancel", action: () => attendance.cancelWorkshop(workshop.ID, () => setState(() {})));
    }
    return SizedBox();
  }

  Widget thirdButton() {
    return PunchRaisedButton(
        label: "Register",
        action: () => attendance.registerWorkshop(
            workshop,
            () => setState(() {
                  attendance.checkAttendanceWorkshop(workshop);
                })));
  }

  Widget secondButton() {
    if (attendance.workshopAttendance.containsKey(workshop.ID)) {
      if (attendance.workshopAttendance[workshop.ID].attendance.checkedIn && isFeedbackTime && !attendance.workshopAttendance[workshop.ID].attendance.feedback)
        return PunchRaisedButton(
          label: "Send feedback",
          action: () => pp.sendFeedbackWorkshop(
              false,
              () => attendance.setFeedbackWorkshop(
                    workshop.ID,
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
              title: Text(workshop.name, style: AppTextStyles.appbarTitle),
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
                                  child: Text("${workshop.start.time} - ${workshop.end.time}", style: AppTextStyles.sessionTime),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(workshop.name, style: AppTextStyles.styleWhiteBold(16)),
                                    SizedBox(height: 7),
                                    Text(workshop.venue, style: AppTextStyles.styleWhiteBold(14)),
                                    SizedBox(height: 16),
                                    Text(workshop.description, style: AppTextStyles.styleWhite(14)),
                                  ],
                                ),
                              ),
                              attendance.workshopAttendance.containsKey(workshop.ID)
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 22, vertical: 6),
                                      child: Text("Registered to this workshop", style: AppTextStyles.styleWhiteBold(12)),
                                    )
                                  : thirdButton(),
                              firstButton(),
                              secondButton(),
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
