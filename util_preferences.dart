import 'dart:async';

class Preferences {
  static const String ACCOUNT_KEY = "accountKey";

//  static Future<bool> setAccountKey(String accountKey) async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    prefs.setString(ACCOUNT_KEY, accountKey);
//    return prefs.commit();
//  }

  static Future<String> getAccountKey() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String accountKey = prefs.getString(ACCOUNT_KEY);

    // workaround - simulate a login setting this
//    if (accountKey == null) {
//      accountKey = "-KriFiUADpl-X07hnBC-";
//    }

    return "-KriFiUADpl-X07hnBC-";
  }
}