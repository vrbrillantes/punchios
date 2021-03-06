import 'package:flutter/material.dart';
import 'dart:async';
import 'util.dialog.dart';
import 'model.events.dart';
import 'model.notification.dart';
import 'controller.notifications.dart';
import 'model.profile.dart';
import 'model.badges.dart';
import 'screen.textDialog.dart';
import 'ui.eventActions.dart';

import 'util.firebase.dart';
import 'util.preferences.dart';
import 'util.qr.dart';

class EventListHolder {
  Map<String, Event> allEvents = {};
  List<String> attendingEvents = <String>[];
  List<List<String>> mapEventsList = [<String>[], <String>[]];

  EventListHolder(this.context) {
    dialog = GenericDialogGenerator.init(context);
  }

  void initNotifs(String userKey) {
    myNotifications = NotificationHolder.init(userKey);
  }

  StreamSubscription _subscriptionTodo;
  StreamSubscription _subscriptionTodo2;
  GenericDialogGenerator dialog;

  final BuildContext context;

  bool isOnline = false;

  NotificationHolder myNotifications = NotificationHolder();
  Events events = Events();

  void setStatus(bool s) {
    isOnline = s;
  }

  void setAttendingEvents(List<String> ls) {
    attendingEvents = ls;
  }

  void setInterestedEvents(List<String> ls) {
    mapEventsList[1] = ls;
  }

  void disposeSubscriptions() {
    if (_subscriptionTodo != null) _subscriptionTodo.cancel();
    if (_subscriptionTodo2 != null) _subscriptionTodo2.cancel();
  }

  void getEvents(void done()) {
    void setEvents(Map data) {
      allEvents = events.parseEvents(data);
      mapEventsList[0] = events.getActiveEvents(allEvents.values.toList());
    }

    isOnline
        ? EventPresenter.getEvents(setEvents, (StreamSubscription ss) {
            _subscriptionTodo2 = ss;
          })
        : EventPresenter.getOfflineEvents(setEvents);
  }


//  void getFile(void sss(String i)) {
//    EventPresenter.getFile((data) {
//      sss(data['HELLO']);
//    });
//  }
  void readNotification(String pn) {
    myNotifications.readNotification(myNotifications.allNotifications[pn]);
  }

  void getNotifications(void done()) {
    if (isOnline)
      myNotifications.getNotifications(
        done,
        (PunchNotification nn) => dialog.notificationDialog(nn, myNotifications.readNotification),
        (List<PunchNotification> llnn) {},
        (StreamSubscription ss) {
          _subscriptionTodo = ss;
        },
      );
  }
}

class BadgesHolder {
  final String eventID;
  final String userKey;
  final BuildContext context;

  List<Badge> eventBadges = <Badge>[];
  List<String> earnedBadges = <String>[];
  GenericDialogGenerator dialog;

  bool hasBadges() {
    return eventBadges.length > 0;
  }
  BadgesHolder(this.context, this.eventID, this.userKey) {
    dialog = GenericDialogGenerator.init(context);

    EventPresenter.getEventBadgesByEventID(eventID, (Map data) {
      eventBadges = EventBadges.readBadges(data);
//      done();
    });
  }

  void getEarnedBadges(void done()) {
    EventPresenter.getEventEarnedBadgesByUserID(eventID, userKey, (Map data) {
      earnedBadges = EventBadges.readEarnedBadges(data);
      done();
    });
  }

//  void getEventBadges(void done()) {
//    print("getting badges");
//  }

  void scanBadge(Badge boothID, void done()) {
    earnedBadges.contains(boothID.id)
        ? dialog.confirmDialog(dialog.showBadgeString(boothID.description, boothID.icon))
        : QRActions.scanBooth(
            boothID: boothID.id,
            returnCode: (String s) => EventPresenter.earnBooth(eventID, userKey, boothID.id, (Map data) {
                  earnedBadges = EventBadges.readEarnedBadges(data);
                  done();
                }),
            wrongQR: () => dialog.confirmDialog(dialog.wrongQRString));
  }
}

class EventHolder {
  GenericDialogGenerator dialog;
  List<EventLink> eventLinks = <EventLink>[];
  List<String> collaborators = <String>[];
  bool isOnline;
  Events eventLists = Events();
  final Event event;
  final BuildContext context;

  EventHolder(this.context, this.event) {
    dialog = GenericDialogGenerator.init(context);
  }

  void setStatus(bool s) {
    isOnline = s;
  }

  void getLinks(void done()) {
    EventPresenter.getLinks(event.eventID, (Map data) {
      eventLinks = eventLists.readLinks(data);
    });
  }

  bool isCollaborator(String email) {
    return collaborators.contains(email);
  }

  void processCollab(List<String> lc, void done()) {
    collaborators = lc;
    done();
  }

  void getCollaborators(void done()) {
    void assignCollab(Map data) {
      collaborators = eventLists.readCollaborators(data);
      done();
    }

    isOnline ? EventPresenter.getCollaborators(event.eventID, assignCollab) : EventPresenter.getOfflineCollaborators(event.eventID, assignCollab);
  }

  void removeCollaborator(String s, void done(Map data)) {
    dialog.choiceDialog(dialog.collabAskRemoveString, onYes: () => EventPresenter.removeCollaborator(event.eventID, AccountUtils.getUserKey(s), done));
  }

  void showCollab() {
    void redoThis(Map data) {
      collaborators = eventLists.readCollaborators(data);
      showCollab();
    }

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return CollabList(
            collabs: collaborators,
            onAdd: () => addCollab(redoThis),
            onDelete: (String s) => removeCollaborator(s, redoThis),
          );
        });
  }

  void addCollab(void done(Map data)) {
    ScreenTextInit.doThis(context, dialog.collabScreen(event.eventDetails.name), (String s) {
      EventPresenter.setCollaborator(event.eventID, AccountUtils.getUserKey(s), s, done);
    });
  }

  void sendNotifications() {
    ScreenTextInit.doThis(
        context, dialog.broadcastString(event.eventDetails.name), (String s) => EventPresenter.sendNotification(event.eventID, s, () => dialog.confirmDialog(dialog.notifSubmittedString)));
  }

}


AppPreferences prefs = AppPreferences.newInstance();

class EventPresenter {
  static void getEvents(void eventsRetrieved(Map data), void returnSS(StreamSubscription ss)) {
    FirebaseMethods.getEventsByActiveStatus((Map data) {
      eventsRetrieved(data);
      prefs.initInstance(() => prefs.setStringEncode('allEvents', data, (bool s) {}));
    }).then(returnSS);
  }

  static void getEventByEventID(String s, void eventsRetrieved(Map data)) {
    FirebaseMethods.getEventByEventID(s, (Map data) {
      eventsRetrieved(data);
    });
  }
//  static void getFile(void image(Map data)) {
//    FirebaseMethods.getFile(image);
//  }

  static void sendNotification(String eid, String m, void done()) {
    FirebaseMethods.setAttendeeNotificationByEventID(eid, m, done);
  }

  static void earnBooth(eventID, userKey, boothID, void done(Map data)) {
    if (userKey != null) FirebaseMethods.setEventBadgeByUserKey(eventID, userKey, boothID, done);
  }

  static void getEventBadgesByEventID(String eid, void done(Map data)) {
    FirebaseMethods.getEventBadgesByEventID(eid, done);
  }

  static void getEventEarnedBadgesByUserID(String eid, String uid, void done(Map data)) {
    FirebaseMethods.getEventEarnedBadgesByUserKey(eid, uid, done);
  }

  static void getCollaborators(String eid, void done(Map data)) {
    FirebaseMethods.getEventCollaboratorsByEventID(eid, (Map data) {
      done(data);
      prefs.initInstance(() => prefs.setStringEncode('$eid collaborators', data, (bool s) {}));
    });
  }

  static void getOfflineCollaborators(String eid, void done(Map data)) {
    prefs.initInstance(() {
      prefs.getStringDecode('$eid collaborators', done, () {});
    });
  }

  static void getLinks(String eid, void done(Map data)) {
    FirebaseMethods.getEventLinksByEventID(eid, done);
  }

  static void removeCollaborator(String eid, String uid, void done(Map data)) {
    FirebaseMethods.setEventCollaborator(eid, uid, false, done);
  }

  static void setCollaborator(String eid, String uid, String email, void done(Map data)) {
    FirebaseMethods.setEventCollaborator(eid, uid, true, done, e: email);
  }

  static void saveEvent(Event ee, void onWrite(bool b)) {
    prefs.initInstance(() {
      prefs.setStringEncode(ee.eventID, ee.eventMap, onWrite);
    });
  }

  static void getEvent(String s, void done(Map v)) {
    prefs.initInstance(() {
      prefs.getStringDecode(s, done, () {});
    });
  }

  static void getSavedEvents(void done(Map v)) {
    prefs.initInstance(() {
      prefs.getStringDecode('savedEvents', done, () {});
    });
  }

  static void getInterestedEvents(void done(Map v)) {
    prefs.initInstance(() {
      prefs.getStringDecode('savedInterestedEvents', done, () {});
    });
  }

  static void getOfflineEvents(void done(Map v)) {
    prefs.initInstance(() {
      prefs.getStringDecode('allEvents', done, () {});
    });
  }

  static void saveEvents(Map v, void onWrite(bool b)) {
    prefs.initInstance(() {
      prefs.setStringEncode('savedEvents', v, onWrite);
    });
  }

  static void saveInterestedEvents(Map v, void onWrite(bool b)) {
    prefs.initInstance(() {
      prefs.setStringEncode('savedInterestedEvents', v, onWrite);
    });
  }
}
