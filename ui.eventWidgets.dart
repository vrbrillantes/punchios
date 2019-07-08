import 'package:flutter/material.dart';
import 'model.events.dart';
import 'model.notification.dart';
import 'ui.util.dart';
import 'util.qr.dart';

import 'package:url_launcher/url_launcher.dart';

class UIElements {
  static void modalBS(BuildContext context, String direction, void onScan(), String userKey, {String eventID, String sessionID, String attendanceKey, bool waitlisted = false}) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return CheckInWidget(
            waitlisted: waitlisted,
            eventID: eventID,
            sessionID: sessionID,
            userKey: userKey,
            direction: direction,
            scanQR: onScan,
            attendanceKey: attendanceKey,
          );
        });
  }
}

//class HomeTabBar extends AppBar {
//  HomeTabBar({this.onItemTapped, this.selectedIndex, this.showNotifications, this.myNotifications});
//
//  final int selectedIndex;
//  final Function(int) onItemTapped;
//  final VoidCallback showNotifications;
//  final Notifications myNotifications;
//
//  @override
//  Widget build(BuildContext context) {
//    return AppBar(
//      bottom: TabBar(
//        indicatorColor: AppColors.appAccentYellow,
//        indicatorWeight: 5,
//        isScrollable: true,
//        tabs: punchItems.map<Widget>((TabBarItem tbi) {
//          return TabBarPadding(tbItem: tbi, selected: selectedIndex);
//        }).toList(),
//        onTap: onItemTapped,
//      ),
//      backgroundColor: AppColors.appColorMainTransparent,
//      automaticallyImplyLeading: false,
//      title: Image.asset(
//        'images/logo_punch-main.png',
//        height: 40,
//      ),
//      actions: <Widget>[
//        NotificationIcon(unreadNotifications: myNotifications, showNotifications: showNotifications),
////                  IconButton(icon: Icon(Icons.apps), onPressed: () {}),
////                  IconButton(icon: Icon(Icons.search), onPressed: () {}),
//      ],
//    );
//  }
//}

class PlaceholderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Stack(
        children: <Widget>[
          Container(
            height: 120,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: <Color>[AppColors.appGreyscalePlus, AppColors.appGreyscaleMinus],
              end: Alignment.topRight,
              begin: Alignment.bottomLeft,
            )),
            width: double.infinity,
          ),
          Positioned(
            right: 16,
            top: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                height: 90,
                color: AppColors.appGreyscaleBaseline,
                width: 90,
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 132,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 17,
                  color: AppColors.appGreyscaleBaseline,
                  width: 150,
                ),
                SizedBox(height: 2),
                Container(
                  height: 15,
                  color: AppColors.appGreyscaleBaseline,
//                  decoration: BoxDecoration(
//                      gradient: LinearGradient(
//                        colors: <Color>[AppColors.appGreyscaleMinus, AppColors.appGreyscalePlus],
//                        begin: Alignment.topRight,
//                        end: Alignment.bottomLeft,
//                      )),
                  width: 90,
                ),
                SizedBox(height: 2),
                Container(
                  height: 40,
                  color: AppColors.appGreyscaleBaseline,
                  width: 200,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NewBanner extends StatelessWidget {
  NewBanner(this.loadEvent, this.onShowInterest, this.isInterested); // modified
  final Event loadEvent; // modified

  final bool isInterested;
  final VoidCallback onShowInterest;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Stack(
        children: <Widget>[
          SizedBox(height: 120),
          Positioned(
            right: 16,
            top: 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Hero(
                tag: loadEvent.eventID,
                child: Image.network(loadEvent.eventDetails.banner, height: 90.0, width: 90.0, fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 132,
            child: EventDetails(loadEvent: loadEvent),
          ),
          Positioned(
            bottom: 0,
            left: 16,
            child: EventIcons(interestedval: isInterested, onShowInterest: onShowInterest),
          ),
        ],
      ),
    );
  }
}

class EventIcons extends StatelessWidget {
  EventIcons({this.onShowInterest, this.space = true, this.cal = false, this.calv = false, this.interested = false, this.interestedval = false});

  final bool space;
  final bool cal;
  final bool calv;
  final bool interested;
  final bool interestedval;
  final VoidCallback onShowInterest;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: space ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: space ? 0 : 8),
//        InkWell(
//          onTap: () {},
//          child: Row(
//            children: <Widget>[
//              Icon(Icons.share, size: 14, color: AppColors.appGreyBlue),
//              Text('Share', style: AppTextStyles.bannerActions),
//            ],
//          ),
//        ),
//        SizedBox(width: 8),
//        InkWell(
//          onTap: () {},
//          child: Row(
//            children: <Widget>[
//              Icon(Icons.event_note, size: 14, color: calv ? AppColors.appAccentYellow : AppColors.appGreyBlue),
//              Text('Add to calendar', style: calv ? AppTextStyles.bannerActionsClicked : AppTextStyles.bannerActions),
//            ],
//          ),
//        ),
        InkWell(
          onTap: onShowInterest,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: <Widget>[
                Icon(Icons.star, size: 14, color: interestedval ? AppColors.appAccentYellow : AppColors.appGreyBlue),
                Text('Interested', style: interestedval ? AppTextStyles.bannerActionsClicked : AppTextStyles.bannerActions),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class EventDetails extends StatelessWidget {
  EventDetails({this.loadEvent});

  final Event loadEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(loadEvent.eventDetails.name, style: AppTextStyles.bannerTitle),
        Text("${loadEvent.start.simpleDate} (${loadEvent.start.shortweekday})", style: AppTextStyles.bannerDate),
        Text(loadEvent.eventDetails.shortDescription, style: AppTextStyles.bannerDescription),
      ],
    );
  }
}

class EventBanner extends StatelessWidget {
  EventBanner({this.loadEvent, this.onLongPress, this.onPressed, this.isInterested}); // modified
  final Event loadEvent; // modified

  final VoidCallback onLongPress;
  final VoidCallback onPressed;
  final bool isInterested;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: NewBanner(loadEvent, onLongPress, isInterested),
      onTap: onPressed,
    );
  }
}

class VerticalBanner extends StatelessWidget {
  VerticalBanner({this.checkIn, this.loadEvent, this.onPressed, this.onShowInterest, this.isInterested}); // modified
  final Event loadEvent; // modified

  final Function(String) onPressed;
  final VoidCallback checkIn;
  final VoidCallback onShowInterest;
  final bool isInterested;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: InkWell(
          onTap: () => onPressed(loadEvent.eventID),
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                height: 152,
                child: Image.network(loadEvent.eventDetails.banner, fit: BoxFit.cover),
              ),
              Positioned(
                top: 77,
                right: 10,
                height: 64,
                child: loadEvent.isToday ? InkWell(child: Image.asset('images/check-in_button@3x.png'), onTap: checkIn) : SizedBox(),
              ),
//              Positioned(
//                left: 0,
//                bottom: 0,
//                right: 0,
//                child: EventIcons(space: false, interestedval: isInterested, onShowInterest: onShowInterest),
//              ),
              Positioned.fill(
                top: 152,
                bottom: 0,
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 50,
                      child: Container(
                        color: loadEvent.isToday ? AppColors.appAccentYellow : AppColors.appGreyscalePlus,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(loadEvent.start.shortmonth, style: AppTextStyles.bannerDateMonth),
                            Text(loadEvent.start.day, style: AppTextStyles.bannerDateDay),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(padding: EdgeInsets.all(8), child: EventDetails(loadEvent: loadEvent)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerticalEventsButton extends StatelessWidget {
  VerticalEventsButton({this.onPressed}); // modified

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: Container(color: AppColors.appAccentPurple)),
            Positioned.fill(child: Image.asset('images/view-all_button.png', fit: BoxFit.cover)),
            Positioned.fill(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'View all',
                  style: AppTextStyles.styleWhiteBold(16),
                )
              ],
            )),
          ],
        ),
      ),
      onTap: onPressed,
    );
  }
}

class EventLabel extends StatelessWidget {
  EventLabel({this.label}); // modified
  final String label; // modified

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: AppTextStyles.eventTitle,
      ),
    );
  }
}

class EventDetailsBar extends StatelessWidget {
  EventDetailsBar({this.loadEvent});

  final Event loadEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: ListTile(
            title: Text(
                loadEvent.start.day != loadEvent.end.day
                    ? "${loadEvent.start.longmonth} ${loadEvent.start.day}-${loadEvent.end.day}, ${loadEvent.start.longyear} " + "(${loadEvent.start.shortweekday}-${loadEvent.end.shortweekday})"
                    : "${loadEvent.start.longdate} (${loadEvent.start.shortweekday})",
                style: AppTextStyles.eventDetails),
            leading: Image.asset('images/calendar@2x.png', height: 20),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: ListTile(
            title: Text(loadEvent.eventDetails.venue, style: AppTextStyles.eventDetails),
            leading: Image.asset('images/location@2x.png', height: 20),
          ),
        ),
      ],
    );
  }
}

class SessionDetailsBar extends StatelessWidget {
  SessionDetailsBar({this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: ListTile(
          title: Text('View sessions for this event', style: AppTextStyles.eventDetailsOrangeBold),
          leading: Image.asset('images/sessions@2x.png', height: 20),
        ),
      ),
    );
  }
}

class AttendeesDetailsBar extends StatelessWidget {
  AttendeesDetailsBar({this.loadEvent, this.eventAttendees});

  final Event loadEvent;
  final int eventAttendees;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Text('Going', style: AppTextStyles.bannerTitle),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18.0),
          child: Text("${(eventAttendees).toString()} attending", style: AppTextStyles.eventDetailsGrey),
        ),
      ],
//      crossAxisAlignment: CrossAxisAlignment.start,
//      children: <Widget>[
//        Container(
//          child: ListTile(
//            title: Text('Going', style: AppTextStyles.bannerTitle),
//          ),
//        ),
//        ,

//        Container(
//          padding: EdgeInsets.symmetric(horizontal: 18.0),
//          child: Row(
//            children: <Widget>[
//              Padding(
//                padding: EdgeInsets.all(8),
//                child: ClipOval(
//                  child:
//                      Image.network("https://lh4.googleusercontent.com/-gEK1m_TuetY/AAAAAAAAAAI/AAAAAAAACrk/xKRbizticDI/s96-c/photo.jpg", height: 32),
//                ),
//              ),
//              Padding(
//                padding: EdgeInsets.all(8),
//                child: ClipOval(
//                  child:
//                      Image.network("https://lh3.googleusercontent.com/-NQQibIsXQaA/AAAAAAAAAAI/AAAAAAAAAk0/KIZ1QCZpiM4/s96-c/photo.jpg", height: 32),
//                ),
//              ),
//              Padding(
//                padding: EdgeInsets.all(8),
//                child: ClipOval(
//                  child:
//                      Image.network("https://lh6.googleusercontent.com/-_Uk8opug3eE/AAAAAAAAAAI/AAAAAAAAASQ/SmYmmvy1uAs/s1337/photo.jpg", height: 32),
//                ),
//              ),
//              eventAttendees > 3 ? Text("${(eventAttendees - 3).toString()} others", style: AppTextStyles.eventDetailsGrey) : SizedBox(),
//            ],
//          ),
//        ),
//      ],
    );
  }
}

class RelatedInfoDetailsBar extends StatelessWidget {
  RelatedInfoDetailsBar({this.eventLinks});

  final List<EventLink> eventLinks;

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return eventLinks.length == 0
        ? SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                child: Text('Related content', style: AppTextStyles.bannerTitle),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: eventLinks.map<Widget>((EventLink e) {
                      return InkWell(
                          child: Container(child: Text(e.name, style: AppTextStyles.eventLinks), padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6)), onTap: () => _launchURL(e.link));
                    }).toList()),
              ),
            ],
          );
  }
}

//class EventDetailsEdit extends StatelessWidget {
//  EventDetailsEdit({this.loadEvent});
//
//  final Event loadEvent;
//
//  @override
//  Widget build(BuildContext context) {
//    return Column(
//      children: <Widget>[
//        Container(
//          padding: EdgeInsets.symmetric(horizontal: 16.0),
//          child: ListTile(
//            title: Text("${loadEvent.start.longdate} | ${loadEvent.start.weekday}", style: AppTextStyles.titleStyleDark),
//            subtitle: Text("${loadEvent.start.time} - ${loadEvent.end.time}"),
//            leading: Icon(Icons.event_note),
//          ),
//        ),
//        Container(
//          padding: EdgeInsets.symmetric(horizontal: 16.0),
//          child: ListTile(
//            title: Text(loadEvent.eventDetails.venue, style: AppTextStyles.titleStyleDark),
//            subtitle: Text(loadEvent.eventDetails.venueSpec),
//            leading: Icon(Icons.location_on),
//          ),
//        ),
//        Container(
//          padding: EdgeInsets.symmetric(horizontal: 16.0),
//          child: ListTile(
//            title: Text(loadEvent.start.longdate + " | " + loadEvent.start.weekday, style: AppTextStyles.titleStyleDark),
//          ),
//        ),
//      ],
//    );
//  }
//}

class LikeCircle extends StatefulWidget {
  LikeCircle({this.cc, this.onTap, this.inFocus});

  final VoidCallback onTap;
  final bool inFocus;
  final ColorHolder cc;

  @override
  _CircleBuild createState() => _CircleBuild(cc: cc, onTap: onTap, inFocus: inFocus);
}

class _CircleBuild extends State<LikeCircle> with TickerProviderStateMixin {
  _CircleBuild({this.cc, this.onTap, this.inFocus});

  final VoidCallback onTap;
  final ColorHolder cc;
  final bool inFocus;

  double widgetSize = 64;
  AnimationController _controller;
  CurvedAnimation _curvedController;
  Animation<double> animation;
  AnimationController _controller2;
  CurvedAnimation _curvedController2;
  Animation<double> animation2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _curvedController = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    animation = Tween<double>(end: 1, begin: 0).animate(_curvedController);
    _controller2 = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _curvedController2 = CurvedAnimation(parent: _controller2, curve: Curves.easeInOutQuint);
    animation2 = Tween<double>(end: 1, begin: 0).animate(_curvedController2);
    _controller.forward(from: 0);
  }

  void olp() {
    _controller2.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        SizedBox(
          height: widgetSize,
          width: widgetSize,
        ),
        AnimatedBuilder(
          animation: _controller2,
          builder: (context, anim) {
            return Positioned(
              left: 32,
              top: 32,
              child: Transform(
                alignment: Alignment.centerLeft,
                transform: Matrix4.rotationZ(-1.57079633),
//                transform: Matrix4.diagonal3Values(1, 1, 1),
                child: Card(
                  margin: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  child: Container(
                    height: animation2.value * widgetSize,
                    width: animation2.value * widgetSize * 2 - animation2.value * widgetSize / 2,
                  ),
                  color: cc.color,
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _controller2,
          builder: (context, anim) {
            return Positioned(
              left: 16,
              bottom: 32 + 32 * animation2.value,
              child: Icon(
                Icons.cancel,
                size: 32,
                color: Colors.white,
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, anim) {
            return Positioned(
              left: (widgetSize / 2) - animation.value * (widgetSize / 2),
              top: (widgetSize / 2) - animation.value * (widgetSize / 2),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.diagonal3Values(1, 1, 1),
                child: InkWell(
                  onLongPress: olp,
                  onTap: onTap,
                  child: ClipOval(
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      color: cc.color,
                      height: animation.value * widgetSize,
                      width: animation.value * widgetSize,
                    ),
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}

class ColorHolder {
  final Color color;
  final String name;
  final String cmyk;
  final String rgbval;
  final String hex;

  const ColorHolder({this.color, this.name, this.cmyk, this.rgbval, this.hex});
}

class NotificationIcon extends StatelessWidget {
  NotificationIcon({this.unreadNotifications, this.showNotifications});

  final VoidCallback showNotifications;
  final Notifications unreadNotifications;

  @override
  Widget build(BuildContext context) {
    if (unreadNotifications == null || unreadNotifications.unreadNotifications.length == 0) {
      return IconButton(
        icon: Icon(Icons.notifications_none),
        onPressed: () {},
      );
    }
    return IconButton(
      icon: Icon(Icons.notifications, color: AppColors.appAccentYellow),
      onPressed: showNotifications,
    );
  }
}

class CheckInWidget extends StatelessWidget {
  CheckInWidget({this.eventID, this.sessionID, this.direction, this.userKey, this.scanQR, this.waitlisted, this.attendanceKey});

  final String sessionID;
  final String eventID;
  final String direction;
  final String userKey;
  final String attendanceKey;
  final bool waitlisted;
  final VoidCallback scanQR;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        waitlisted
            ? Container(
                width: 250,
                child: ListTile(
                  leading: Icon(
                    Icons.warning,
                    color: AppColors.appColorRed,
                  ),
                  title: Text(
                    "Waitlisted attendee",
                    style: AppTextStyles.qrDialog,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Container(
                width: 200,
                child: Text(
                  direction == "IN" ? "Present your QR code to the usher to check-in" : "Present your QR code to the usher to checkout",
                  style: AppTextStyles.qrDialog,
                  textAlign: TextAlign.center,
                ),
              ),
        sessionID == null
            ? (attendanceKey == null
                ? QRGenerator.attendeeEventQR(eventID: eventID, userKey: userKey, direction: direction)
                : QRGenerator.attendeeWorkshopQR(attendanceKey: attendanceKey, userKey: userKey, direction: direction))
            : QRGenerator.attendeeSessionQR(sessionID: sessionID, userKey: userKey, direction: direction),
        FlatButton(
          onPressed: scanQR,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset('images/scan-qr_icon@2x.png', height: 20),
              SizedBox(width: 6),
              Text(direction == "IN" ? 'Or check-in by scanning' : 'Or checkout by scanning', style: AppTextStyles.qrScanText),
            ],
          ),
        )
      ],
    );
  }
}

class StaticBanner extends StatelessWidget {
  StaticBanner({this.loadEvent}); // modified
  final Event loadEvent; // modified

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: loadEvent.eventID,
      child: Image.network(loadEvent.eventDetails.banner, height: 300, fit: BoxFit.cover),
    );
  }
}
