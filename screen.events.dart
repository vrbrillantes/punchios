import 'package:flutter/material.dart';
import 'ui.backdrop.dart';
import 'ui.list.event.dart';
import 'ui.util.dart';
import 'ui.eventWidgets.dart';
import 'screen.profileview.dart';
import 'screen.eventview.dart';
import 'util.internet.dart';
import 'controller.events.dart';
import 'controller.profile.dart';
import 'controller.calendar.dart';

class ScreenEvents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ScreenEventsState();
  }
}

class ScreenEventsState extends StatefulWidget {
  @override
  _ScreenEventsBuild createState() => new _ScreenEventsBuild();
}

class _ScreenEventsBuild extends State<ScreenEventsState> with TickerProviderStateMixin {
  EventListHolder eventsHolder;
  ProfileHolder profileHolder;
  CalendarHolder calendarHolder;
  int _selectedIndex = 0;
  bool profileSet = true;
  PunchInternetUtils netUtils;

  @override
  void initState() {
    eventsHolder = EventListHolder(context);
    calendarHolder = CalendarHolder.newCal(context);
    profileHolder = ProfileHolder(
        context,
        (String userKey) => setState(() {
              calendarHolder.addProfile(profileHolder.profile);
              eventsHolder.initNotifs(userKey);
              netUtils = PunchInternetUtils(onlineInitState, setStatus);
            }));

    _controller2 = AnimationController(vsync: this, duration: Duration(milliseconds: 999));
    _curvedController2 = CurvedAnimation(parent: _controller2, curve: Curves.easeInOutSine);
    animation2 = Tween<double>(end: 1, begin: 0).animate(_curvedController2);
    super.initState();
  }

  @override
  void dispose() {
    eventsHolder.disposeSubscriptions();
    netUtils.disposeSubscriptions();
    super.dispose();
  }

  void setStatus(bool s) {
    eventsHolder.setStatus(s);
    profileHolder.setStatus(s);
    calendarHolder.setStatus(s);
  }

  void onlineInitState(bool s) {
    setStatus(s);
    eventsHolder.getEvents(() => setState(() {}));
    eventsHolder.getNotifications(() => setState(() {}));

    profileHolder.getOnlineAccount(setProfileSet);
    profileHolder.getSubscriptions(() => setState(() {}));

    calendarHolder.getCal((List<String> ls) => setState(() {
          eventsHolder.setAttendingEvents(ls);
        }));
    calendarHolder.getInterests((List<String> ls) => setState(() {
          eventsHolder.setInterestedEvents(ls);
        }));
  }

  void setProfileSet(bool s) {
    setState(() {
      profileSet = s;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  AnimationController _controller2;
  CurvedAnimation _curvedController2;
  Animation<double> animation2;

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          brightness: Brightness.light,
          platform: Theme.of(context).platform,
        ),
        child: Stack(children: <Widget>[
          Backdrop(),
          DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                bottom: TabBar(
                  indicatorColor: AppColors.appAccentYellow,
                  indicatorWeight: 5,
                  isScrollable: true,
                  tabs: punchItems.map<Widget>((TabBarItem tbi) {
                    return TabBarPadding(tbItem: tbi, selected: _selectedIndex);
                  }).toList(),
                  onTap: _onItemTapped,
                ),
                backgroundColor: AppColors.appColorMainTransparent,
                automaticallyImplyLeading: false,
                title: Image.asset(
                  'images/logo_punch-main.png',
                  height: 40,
                ),
                actions: <Widget>[
                  NotificationIcon(
                      unreadNotifications: eventsHolder.myNotifications,
                      showNotifications: () {
                        _controller2.status == AnimationStatus.completed ? _controller2.reverse() : _controller2.forward();
                      })
//                  IconButton(icon: Icon(Icons.apps), onPressed: () {}),
//                  IconButton(icon: Icon(Icons.search), onPressed: () {}),
                ],
              ),
              backgroundColor: const Color(0x00000000),
              body: (_selectedIndex == 2 || profileSet == false)
                  ? ProfileForm(
                      profile: profileHolder.profile,
                      dialog: eventsHolder.dialog,
                      profileSet: setProfileSet,
                    )
                  : AllListEvent(
//                  : TransformingEvent(
                      refresh: () => setState(() {}),
                      interested: calendarHolder.setInterestedEvent,
                      onPressed: showEvent,
                      selectedIndex: _selectedIndex,
                      allEvents: eventsHolder,
                      checkInPressed: calendarHolder.checkIn,
                      subscriptionList: profileHolder.mySubscriptions,
                    ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: <Widget>[
                Positioned(
                    right: 8,
                    top: 40,
                    child: SizeTransition(
                      sizeFactor: animation2,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: eventsHolder.myNotifications.unreadNotifications
                              .map<Widget>((String s) => Card(
                                    child: InkWell(
                                      onTap: () => eventsHolder.readNotification(s),
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        child: Text(eventsHolder.myNotifications.allNotifications[s].message, style: AppTextStyles.bannerActions),
                                      ),
                                    ),
                                  ))
                              .toList()),
                    )),
              ],
            ),
          ),
        ]));
  }

  void showEvent(String eventID) {
    Navigator.pushNamed(context, '/eventView', arguments: ScreenEventArguments(profile: profileHolder.profile, loadEvent: eventsHolder.allEvents[eventID]));
  }
}
