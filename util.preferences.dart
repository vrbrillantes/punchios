import 'package:shared_preferences/shared_preferences.dart';

//import 'util.login.dart';
import 'dart:convert';

class AppPreferences {
  AppPreferences.newInstance();

  static const String currentVersion = "3.0.1.57";
  static SharedPreferences prefs;

  void initInstance(void done()) async {
    if (prefs == null) {
      prefs = await SharedPreferences.getInstance();
    }
    done();
  }

  void setStrings(Map<String, String> stringValues, void onValue(bool s)) {
    stringValues.forEach((k, v) async {
      await prefs.setString(k, v).then(onValue);
    });
  }

  void setString(String k, String v) async {
    await prefs.setString(k, v);
  }

  void setStringEncode(String k, Map v, void onWrite(bool b)) async {
    await prefs.setString(k, json.encode(v)).then(onWrite);
  }

  void setStringEncodeList(String k, List<dynamic> v, void onWrite(bool b)) async {
    await prefs.setString(k, json.encode(v)).then(onWrite);
  }

  void getStringDecode(String k, void done(Map v), void empty()) async {
    String value = await prefs.get(k);
    value != null ? done(json.decode(value)) : empty();
  }

  void getStringDecodeList(String k, void done(List<dynamic> v), {void empty()}) async {
    String value = await prefs.get(k);
    value != null ? done(json.decode(value)) : empty();
  }

  void getStrings(List<String> stringKeys, void done(Map<String, String> data)) {
    Map<String, String> stringValues = {};
    stringKeys.forEach((String k) async {
      stringValues[k] = await prefs.get(k);
      if (stringValues.length == stringKeys.length) done(stringValues);
    });
  }

  void getString(String k, void done(String v)) async {
    String value = await prefs.get(k);
    done(value);
  }

//
//  static void checkVersion(void isUpdated(bool s)) {
////    FirebaseMethods.getAppVersion((String s) {
////      print(s + " APP VERSION");
////      s == currentVersion ? isUpdated(true) : isUpdated(false);
////    });
//  }
//
//  static void getDelivery(List<String> deliveryFields, String userKey, void onData(Map deliveryDetails)) async {
//    prefs = await SharedPreferences.getInstance();
//    Map deliveryDetails = {};
//    deliveryFields.forEach((String s) async {
//      String retrieved = await prefs.get(s + userKey);
//
//      retrieved == null ? null : deliveryDetails[s] = retrieved;
//      if (deliveryFields.length == deliveryDetails.length) {
//        onData(deliveryDetails);
//      }
//    });
//  }
//
//  static void saveDelivery(Map deliveryDetails, void done()) {
//    LoginFunctions.getUserName((String userID) async {
//      prefs = await SharedPreferences.getInstance();
//      deliveryDetails.forEach((key, value) async {
//        await prefs.setString(key + userID, value);
//        deliveryDetails.remove(key);
//        if (deliveryDetails.length == 0) {
//          done();
//        }
//      });
//    });
//  }
//
//  static void getLogin(void done(String username)) async {
//    prefs = await SharedPreferences.getInstance();
//    String username = await prefs.get('username');
//    done(username);
//  }
//
//  static void getToken(void done(String token)) async {
//    prefs = await SharedPreferences.getInstance();
//    String token = await prefs.get('fcmtoken');
//    done(token);
//  }
//
//  static void saveLogin(String username) async {
//    prefs = await SharedPreferences.getInstance();
//    prefs.setString('username', username);
//  }
//
//  static void saveToken(String username) async {
//    prefs = await SharedPreferences.getInstance();
//    prefs.setString('fcmtoken', username);
//  }
//
//  static void deleteLogin() async {
//    prefs = await SharedPreferences.getInstance();
//    prefs.remove('username');
//  }
}
