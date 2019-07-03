import 'package:flutter/material.dart';
import 'util.dialog.dart';
import 'model.profile.dart';



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
