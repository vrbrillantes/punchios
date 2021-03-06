import 'model.notification.dart';
import 'util.firebase.dart';
import 'dart:async';

class ScreenNotifArgs {
  final NotificationHolder allNotifications;

  ScreenNotifArgs(this.allNotifications);
}

class NotificationPresenter {
  static void getNotifications(String userID, void onData(Map data), void returnSS(StreamSubscription s)) {
    FirebaseMethods.getAllNotificationsByUserKey(userID, onData).then(returnSS);
  }

  static void readNotification(String userID, String eventID, String notifID) {
    if (userID != null) FirebaseMethods.setNotificationReadByNotificationID(userID, eventID, notifID);
  }
}

class NotificationHolder {
  String userKey;
  List<String> unreadNotifications = <String>[];

  List<String> thisBatchOfUnread;
  List<String> notificationList = <String>[];
  Map<String, PunchNotification> allNotifications = {};

  void readNotification(PunchNotification pn) {
    NotificationPresenter.readNotification(userKey, pn.eventID, pn.notificationID);
  }

  void parseNotifications(Map data) {
    thisBatchOfUnread = <String>[];
    data.forEach((k, v) {
      v.forEach((kk, vv) {
        PunchNotification thisNotif = PunchNotification.readNew(kk, k, vv);
        allNotifications[kk] = thisNotif;
        notificationList.add(kk);
        if (!thisNotif.read) thisBatchOfUnread.add(kk);
      });
    });
  }

  NotificationHolder.init(this.userKey);

  NotificationHolder();

  void getNotifications(
      void done(),
      void onNew(PunchNotification newNot),
      void onNewList(List<PunchNotification> newListNot),
      void returnSS(StreamSubscription s),
      ) {
    NotificationPresenter.getNotifications(userKey, (Map data) {
      List<PunchNotification> newNotList = <PunchNotification>[];
      parseNotifications(data);

      if (unreadNotifications.length > 0) {
        thisBatchOfUnread.forEach((String s) {
          if (!unreadNotifications.contains(s)) newNotList.add(allNotifications[s]);
        });
      }
      unreadNotifications = thisBatchOfUnread;
      done();
      if (newNotList.length > 0) {
        newNotList.length == 1 ? onNew(newNotList[0]) : onNewList(newNotList);
      }
    }, returnSS);
  }
}