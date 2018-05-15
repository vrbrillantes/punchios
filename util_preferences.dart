import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'model_profile.dart';

class AppPreferences {
  static Future saveLogin(ItemProfile p) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', p.email);
    await prefs.setString('name', p.name);
    await prefs.setString('photo', p.photo);
  }
  static Future getLogin(void onData(ItemProfile todo)) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = await prefs.get('email');
    String photo = await prefs.get('photo');
    String name = await prefs.get('name');
    onData(ItemProfile.create(name, email, photo));
  }
}