import 'package:flutter/material.dart';
import 'util.dialog.dart';
import 'model.profile.dart';
import 'util.preferences.dart';
import 'util.firebase.dart';

class ProfilePresenter {
  static AppPreferences prefs = AppPreferences.newInstance();

  static void getMyOldAccount(String userKey, void onData(Map data)) {
    FirebaseMethods.getMyAccountOld(userKey, onData);
  }

  static void getMySubscriptions(String userID, void onData(Map data)) {
    FirebaseMethods.getSubsByUserKey(userID, (Map data) {
      onData(data);
      prefs.initInstance(() {
        prefs.setStringEncode('mySubscriptions', data, (bool s) {
          print("Saved events");
        });
      });
    });
  }

  static void getOfflineSubscriptions(void done(Map v)) {
    prefs.initInstance(() {
      prefs.getStringDecode('mySubscriptions', done, () {});
    });
  }

  static void saveProfile(Profile p, void done(bool s)) async {
    prefs.initInstance(() {
      prefs.setStrings({'email': p.email, 'name': p.name, 'photo': p.photo}, done);
    });
  }

  static void getPrefsProfile(void done(Map<String, String> data)) {
    prefs.initInstance(() {
      prefs.getStrings(['email', 'name', 'photo'], done);
    });
  }

  static void saveGuest(Profile p) async {
    prefs.initInstance(() {
      prefs.setStrings({'email': p.email, 'first': p.firstName, 'last': p.lastName}, (bool s) {});
    });
  }

  static void getGuest(void done(Map<String, String> data)) {
    prefs.initInstance(() {
      prefs.getStrings(['email', 'first', 'last'], done);
    });
  }

  static void getOnlineAccount(String uuid, void onData(Map data)) {
    FirebaseMethods.getMyAccount(uuid, (Map data) {
      onData(data);
      prefs.initInstance(() {
        prefs.setStringEncode('myAccount', data, (bool s) {});
      });
    });
  }

  static void getOfflineAccount(void done(Map v)) {
    prefs.initInstance(() {
      prefs.getStringDecode('myAccount', done, () {});
    });
  }

  static void setMyAccount(String uuid, Map data, void onData()) {
    FirebaseMethods.setMyAccount(uuid, data, onData);
  }
}

class LoginPresenter {
  static AppPreferences prefs = AppPreferences.newInstance();

  static void getOfflineLoginData(void done(Map<String, String> data)) {
    prefs.initInstance(() {
      prefs.getStrings(['fcm', 'username', 'uuid'], done);
    });
  }

  static void saveStrings(Map<String, String> data) {
    prefs.initInstance(() {
      prefs.setStrings(data, (bool s) {});
    });
  }
}

class ProfileHolder {
  Profile profile;
  final BuildContext context;
  Login newLogin = Login.newLogin();

  void setStatus(bool s) {
    isOnline = s;
  }

  GenericDialogGenerator dialog;
  Map<String, EventSubscription> mySubscriptions = {};
  bool isOnline;

  ProfileHolder(this.context, void done(String userKey)) {
    dialog = GenericDialogGenerator.init(context);
    newLogin.getOfflineLoginData(() {
      profile = Profile.init(newLogin);
      profile.getPrefsProfile();
      done(newLogin.userKey);
    });
  }

  void getSubscriptions(void done()) {
    profile.getSubscriptions(isOnline, (Map<String, EventSubscription> ss) {
      mySubscriptions = ss;
      done();
    });
  }

  void getOnlineAccount(void done(bool s)) {
    profile.getOnlineAccount(isOnline, done);
  }
}
