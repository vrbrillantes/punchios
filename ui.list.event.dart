import 'package:flutter/material.dart';
import 'model.events.dart';
import 'model.profile.dart';
import 'screen.eventscaffold.dart';
import 'ui.eventWidgets.dart';
import 'ui.util.dart';
import 'controller.events.dart';

List<String> pageTitles = <String>['All events', 'Events I\'m interested in', 'My profile'];

class ListEvent extends StatelessWidget {
  ListEvent({
    this.subscriptionList,
    this.selectedIndex,
    this.onPressed,
    this.allEvents,
    this.interested,
  });

  final Function(Event) interested;
  final Function(String) onPressed;
  final int selectedIndex;
  final EventListHolder allEvents;
  final Map<String, EventSubscription> subscriptionList;

  @override
  Widget build(BuildContext context) {
    List<Event> sortedEvents = <Event>[];
    List<Event> filteredEvents = <Event>[];
    allEvents.mapEventsList[selectedIndex].forEach((String key) {
      if (allEvents.allEvents.containsKey(key)) {
        sortedEvents.add(allEvents.allEvents[key]);
      }
    });

    sortedEvents.sort((a, b) => a.start.datetime.compareTo(b.start.datetime));
    sortedEvents.forEach((Event e) {
      if (e.permittedUsers.length > 0) {
        e.permittedUsers.forEach((EventInvitation ei) {
          if (subscriptionList.containsKey(ei.invitationKey)) {
            filteredEvents.add(e);
          }
        });
      } else {
        filteredEvents.add(e);
      }
    });
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == 0) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              child: Text(pageTitles[selectedIndex], style: AppTextStyles.styleWhiteBold(22)),
            );
          } else {
            return filteredEvents.length > 0
                ? EventBanner(
                    loadEvent: filteredEvents[index - 1],
                    onPressed: () => onPressed(filteredEvents[index - 1].eventID),
                    onLongPress: () => interested(filteredEvents[index - 1]),
                    isInterested: allEvents.mapEventsList[1].contains(filteredEvents[index - 1].eventID),
                  )
                : PlaceholderBanner();
          }
        },
        childCount: filteredEvents.length > 0 ? filteredEvents.length + 1 : (selectedIndex == 1 ? 0 : 5),
      ),
    );
  }
}

class TransformingEvent extends StatefulWidget {
  TransformingEvent({this.onPressed, this.eventPressed, this.refresh, this.checkInPressed, this.interested, this.title = "Upcoming events", this.allEvents, this.selectedIndex, this.subscriptionList});

  final Function(Event, Function(List<String> ls)) interested;
  final Function(Event) checkInPressed;
  final Function(String) onPressed;
  final VoidCallback refresh;
  final String title;
  final EventListHolder allEvents;
  final int selectedIndex;
  final Function(Event, Key) eventPressed;

  final Map<String, EventSubscription> subscriptionList;

  @override
  _TransformingEventBuild createState() => _TransformingEventBuild(
      refresh: refresh, interested: interested, onPressed: onPressed, selectedIndex: selectedIndex, allEvents: allEvents, checkInPressed: checkInPressed, subscriptionList: subscriptionList);
}

class _TransformingEventBuild extends State<TransformingEvent> with TickerProviderStateMixin {
  _TransformingEventBuild({this.onPressed, this.refresh, this.checkInPressed, this.interested, this.title = "Upcoming events", this.allEvents, this.selectedIndex, this.subscriptionList});

  final Function(Event, Function(List<String> ls)) interested;
  final Function(Event) checkInPressed;
  final Function(String) onPressed;
  final VoidCallback refresh;
  final String title;
  final EventListHolder allEvents;
  final int selectedIndex;

  OverlayState oss2;
  OverlayEntry overlayEntry;

  AnimationController _controller2;
  CurvedAnimation _curvedController2;
  Animation<double> animation2;
  final Map<String, EventSubscription> subscriptionList;

  @override
  void initState() {
    _controller2 = AnimationController(vsync: this, duration: Duration(milliseconds: 999));
    _curvedController2 = CurvedAnimation(parent: _controller2, curve: Curves.elasticOut);
    animation2 = Tween<double>(end: 1, begin: 0).animate(_curvedController2);
    super.initState();
  }

  void setInterest(Event e) {
    interested(e, (List<String> ls) {
      allEvents.setInterestedEvents(ls);
      refresh();
    });
  }

  void eventPressed(Event e, GlobalKey k) {
    RenderBox rbb = k.currentContext.findRenderObject();
    oss2 = Overlay.of(context);
    Size medhi = MediaQuery.of(context).size;

    overlayEntry = OverlayEntry(
//      builder: (context)=> ScaffoldEvent(event: e,)
      builder: (context) => AnimatedBuilder(
            builder: (context, anim) => Stack(
                  children: <Widget>[
                    Positioned(
                      width: 300 + (medhi.width * animation2.value) - (300 * animation2.value),
                      left: rbb.localToGlobal(Offset.zero).dx - (rbb.localToGlobal(Offset.zero).dx * animation2.value),
//                      top: 0,
                      top: rbb.localToGlobal(Offset.zero).dy - (rbb.localToGlobal(Offset.zero).dy * animation2.value),
                      child: ScaffoldEvent(event: e),
                      height: 200 + (medhi.height * animation2.value) - (200 * animation2.value),
                    )
                  ],
                ),
            animation: _controller2,
          ),
    );
    oss2.insert(overlayEntry);
    _controller2.forward();
//    _controller2.forward().then((_) => _controller2.reverse().then((_) => overlayEntry.remove()));
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      HorizontalListEvent(
        selectedIndex: selectedIndex,
        allEvents: allEvents,
        eventPressed: eventPressed,
        onPressed: onPressed,
        checkInPressed: checkInPressed,
        interested: setInterest,
      ),
      ListEvent(
        subscriptionList: subscriptionList,
        selectedIndex: selectedIndex,
        allEvents: allEvents,
        onPressed: onPressed,
        interested: setInterest,
      ),
    ]);
  }
}

class AllListEvent extends StatelessWidget {
  AllListEvent({this.onPressed, this.refresh, this.checkInPressed, this.interested, this.title = "Upcoming events", this.allEvents, this.selectedIndex, this.subscriptionList});

  final Function(Event, Function(List<String> ls)) interested;
  final Function(Event) checkInPressed;
  final Function(String) onPressed;
  final VoidCallback refresh;
  final String title;
  final EventListHolder allEvents;
  final int selectedIndex;

  final Map<String, EventSubscription> subscriptionList;

  void setInterest(Event e) {
    interested(e, (List<String> ls) {
      allEvents.setInterestedEvents(ls);
      refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      HorizontalListEvent(
        selectedIndex: selectedIndex,
        allEvents: allEvents,
        onPressed: onPressed,
        checkInPressed: checkInPressed,
        interested: setInterest,
      ),
      ListEvent(
        subscriptionList: subscriptionList,
        selectedIndex: selectedIndex,
        allEvents: allEvents,
        onPressed: onPressed,
        interested: setInterest,
      ),
    ]);
  }
}

class HorizontalListEvent extends StatelessWidget {
  HorizontalListEvent({this.eventPressed, this.checkInPressed, this.title = "Upcoming events", this.onPressed, this.allEvents, this.interested, this.selectedIndex});

  final Function(Event, GlobalKey) eventPressed;
  final Function(Event) checkInPressed;
  final Function(Event) interested;
  final Function(String) onPressed;
  final String title;
  final EventListHolder allEvents;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    List<Event> sortedEvents = <Event>[];
    if (selectedIndex == 1)
      allEvents.attendingEvents.forEach((String key) {
        if (allEvents.allEvents.containsKey(key) && allEvents.allEvents[key].end.datetime.isAfter(DateTime.now().subtract(Duration(days: 3)))) sortedEvents.add(allEvents.allEvents[key]);
      });
    sortedEvents.sort((a, b) => a.start.datetime.compareTo(b.start.datetime));
    List<Widget> viewEvent = sortedEvents.map<Widget>((Event e) {
//      GlobalKey thisKey = GlobalKey();
//      ScaffoldEvent ss = ScaffoldEvent(event: e);
//      return Container(
//        width: 300,
//        key: thisKey,
//        child: Card(
//            clipBehavior: Clip.antiAlias,
//            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//            child: InkWell(
//              onTap: () => eventPressed(e, thisKey),
//              child: ss,
//            )),
//      );
      return VerticalBanner(
        loadEvent: e,
        checkIn: () => checkInPressed(e),
        onPressed: onPressed,
        onShowInterest: () => interested(e),
        isInterested: allEvents.mapEventsList[1].contains(e.eventID),
      );
    }).toList();
    if (sortedEvents.length > 3) {
      viewEvent.add(Container(
        width: 110.0,
        child: VerticalEventsButton(onPressed: () {}),
      ));
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index == 0) {
            return sortedEvents.length == 0
                ? SizedBox()
                : Container(
                    padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                    child: Text(title, style: AppTextStyles.styleWhiteBold(22)),
                  );
          } else {
            return sortedEvents.length == 0
                ? SizedBox()
                : Container(
                    height: 270,
                    child: ListView(padding: EdgeInsets.symmetric(horizontal: 12), scrollDirection: Axis.horizontal, children: viewEvent),
                  );
          }
        },
        childCount: 2,
      ),
    );
  }
}
