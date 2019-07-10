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

  Map<String, WorkshopAttendance> workshopAttendance = {};

  String selectedName;

  @override
  void initState() {
    _controller2 = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _curvedController2 = CurvedAnimation(parent: _controller2, curve: Curves.easeInOutCubic);
    animation2 = Tween<double>(end: 1, begin: 0).animate(_curvedController2);
    animation1 = Tween<double>(end: 0, begin: 0).animate(_curvedController2);
    sessionHolder.getSessions(() => setState(() {}));
//    calendarHolder.getWorkshopAttendance((WorkshopsAttendance ss) => setState(() {print(ss.attendance.toString());}));
    calendarHolder.getWorkshopAttendance(() => setState(() => workshopAttendance = calendarHolder.workshopAttendance));
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
    Widget createBadge(Track e) {
//      int maxCompletion = e.minCompletion;
      int potentialCompletion = 0;
      int actualCompletion = 0;
      e.trackWorkshops.forEach((Workshop ww) {
//        maxCompletion += ww.weight;
        if (workshopAttendance.containsKey(ww.ID)) {
          potentialCompletion += ww.weight;
          if (workshopAttendance[ww.ID].attendance.checkedIn) actualCompletion += ww.weight;
        }
      });
      return Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(width: 90),
          Positioned(
            top: 2.5,
            left: 17.5,
            child: SizedBox(
              height: 55,
              width: 55,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.appGreyscalePlus2),
//                valueColor: AlwaysStoppedAnimation(badgesHolder.eventBadges.length == badgesHolder.earnedBadges.length ? AppColors.appAccentGreen : AppColors.appAccentOrange),
                strokeWidth: 5,
                value: 1,
              ),
            ),
          ),
          Positioned(
            top: 2.5,
            left: 17.5,
            child: SizedBox(
              height: 55,
              width: 55,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.appAccentYellow),
//                valueColor: AlwaysStoppedAnimation(badgesHolder.eventBadges.length == badgesHolder.earnedBadges.length ? AppColors.appAccentGreen : AppColors.appAccentOrange),
                strokeWidth: 5,
                value: 0.04 + (potentialCompletion/e.minCompletion),
              ),
            ),
          ),
          Positioned(
            top: 2.5,
            left: 17.5,
            child: SizedBox(
              height: 55,
              width: 55,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.appTeal),
//                valueColor: AlwaysStoppedAnimation(badgesHolder.eventBadges.length == badgesHolder.earnedBadges.length ? AppColors.appAccentGreen : AppColors.appAccentOrange),
                strokeWidth: 5,
                value: 0.02 + (actualCompletion/e.minCompletion),
              ),
            ),
          ),
          Positioned(
            top: 7.5,
            left: 22.5,
            child: ClipOval(
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: 45,
                child: e.image,
                width: 45,
              ),
            ),
          ),
          Positioned(
              top: 75,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[Text(e.name, style: AppTextStyles.styleWhite(14))],
              )),
        ],
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == 0) {
            return tracks.length == 0
                ? SizedBox()
                : Container(
                    margin: EdgeInsets.fromLTRB(18, 20, 18, 0),
                    child: Text("Badges earned", style: AppTextStyles.styleWhiteBold(16)),
                  );
          } else if (index == 1) {
            return tracks.length == 0
                ? SizedBox()
                : Container(
                    margin: EdgeInsets.symmetric(vertical: 30),
                    height: 60,
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      scrollDirection: Axis.horizontal,
                      children: sessionHolder.eventTracks.values.map<Widget>(createBadge).toList(),
                    ),
                  );
          } else if (index == 2) {
            return tracks.length == 0
                ? SizedBox()
                : Container(
                    margin: EdgeInsets.fromLTRB(18, 40, 18, 20),
                    child: Text("Categories (${sessionHolder.eventTracks.length})", style: AppTextStyles.styleWhiteBold(16)),
                  );
          } else {
            Track ss = sessionHolder.eventTracks[tracks[index - 3]];
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
                      ],
                    ),
                    onTap: () => changeMe(ss.ID),
                  ),
                  SizeTransition(
                    sizeFactor: selectedName == ss.ID ? animation2 : animation1,
                    child: Column(
                      //showWorkshopScreen
                      children: ss.trackWorkshops
                          .map<Widget>((Workshop ww) => InkWell(
                                child: WorkshopCardCard(
                                  workshop: ww,
                                  onPressed: tryAttend,
                                  text: workshopAttendance[ww.ID] != null ? workshopAttendance[ww.ID].attendance.textStatus : "Sign-up",
                                ),
                                onTap: () => sessionHolder.showWorkshopScreen(ww, calendarHolder),
                              ))
                          .toList(),
                    ),
                  )
                ],
              ),
            );
          }
        },
        childCount: tracks == null ? 3 : tracks.length + 3,
      ),
    );
  }
}

class WorkshopCardCard extends StatelessWidget {
  WorkshopCardCard({this.workshop, this.onPressed, this.text, this.onTap, this.height = 75, this.expand, this.direction = false});

  final VoidCallback expand;
  final VoidCallback onTap;
  final Function(Workshop, String) onPressed;
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
                  child: Text(text, style: AppTextStyles.sessionStatus),
                ),
                onTap: () => onPressed(workshop, text)),
          ),
        ],
      ),
    );
  }
}
