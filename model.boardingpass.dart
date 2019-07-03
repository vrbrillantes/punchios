import 'util.preferences.dart';

class BoardingPassPresenter {
  static AppPreferences prefs = AppPreferences.newInstance();
  static void getSavedBoardingPasses(void done(List<dynamic> vv)) {
    prefs.initInstance(() {
      prefs.getStringDecodeList('savedBoardingPasses', (List<dynamic> v) {
        done(v);
      }, empty: () {
        done(<dynamic>[]);
      });
    });
  }

  static void saveBoardingPasses(List<dynamic> v, void onWrite(bool b)) {
    prefs.initInstance(() {
      prefs.setStringEncodeList('savedBoardingPasses', v, onWrite);
    });
  }
}
