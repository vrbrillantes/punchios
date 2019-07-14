import 'util.firebase.dart';
import 'util.preferences.dart';

class PreferencePresenter {
  static void getVersion(String userID, void versionRetrieved(Map data)) {
    FirebaseMethods.getAppVersion(userID, (Map data) {
      versionRetrieved(data);
    });
  }
}

class PunchPreferences {
  bool isValidVersion;
  bool isUpdated = true;
  String currentBuild = "1.2.60.61";
  String currentVersion = "B60";
  PunchPreferences.init(void done()) {
    PreferencePresenter.getVersion(currentVersion, (Map data) {readVersion(data);done();});
  }
  void readVersion(Map data) {
    isValidVersion = data['Current'];
    isUpdated = data['Android'] == currentBuild;
  }
}