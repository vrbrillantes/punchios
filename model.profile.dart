import 'controller.profile.dart';

class Login {
  String fcm;
  String username;
  String userKey;
  String uuid;

  Login.newLogin();

  void getOfflineLoginData(void done()) {
    LoginPresenter.getOfflineLoginData((Map data) {
      fcm = data['fcm'];
      username = data['username'];
      userKey = AccountUtils.getUserKey(username);
      uuid = data['uuid'];
      done();
    });
  }

  void saveOfflineLoginData(String username, String uuid, String token) {
    LoginPresenter.saveStrings({'fcm': token, 'uuid': uuid, 'username': username});
  }

  void deleteOfflineLoginData() {
    //TODO delete login
  }
}

class EventSubscription {
  final String subID;
  final String subName;
  final String type;

  const EventSubscription({this.subID, this.subName, this.type});
}

class SubscriptionList {
  Map<String, EventSubscription> mySubscriptions = {};

  SubscriptionList.newList(Map data) {
    data.forEach((k, v) {
      mySubscriptions[k] = EventSubscription(
        subName: v['name'],
        type: v['type'],
        subID: k,
      );
    });
  }
}

class Profile {
  String photo;
  bool set = false;
  String name = "";
  String email = "";
  String firstName = "";
  String lastName = "";

  String company = "";
  String position = "";
  String mobile = "";
  String group = "";
  String division = "";
  String department = "";

  String idNumber = "";
  String token;
  Login profileLogin;
  Map<String, String> updatedProfile;
  Map<dynamic, dynamic> userMap;

  Profile.init(this.profileLogin);

  void getSubscriptions(bool isOnline, void returnSubscriptions(Map<String, EventSubscription> mySubscriptions)) {
    isOnline
        ? ProfilePresenter.getMySubscriptions(profileLogin.userKey, (Map data) => returnSubscriptions(SubscriptionList.newList(data).mySubscriptions))
        : ProfilePresenter.getOfflineSubscriptions((Map data) => returnSubscriptions(SubscriptionList.newList(data).mySubscriptions));
  }

  void getOnlineAccount(bool isOnline, void done(bool s)) {
    isOnline
        ? ProfilePresenter.getOnlineAccount(profileLogin.uuid, (Map data) {
            if (data != null) {
              profileFromJson(data);
              done(true);
            } else
              ProfilePresenter.getMyOldAccount(profileLogin.userKey, (Map data2) {
                if (data2 != null) {
                  profileFromJson(data2);
                  setOnlineProfile(() {
                    done(true);
                  });
                } else {
                  done(false);
                }
              });
          })
        : ProfilePresenter.getOfflineAccount((Map data) {
            profileFromJson(data);
            done(data != null);
          });
  }

  void saveDetails(void done(bool s)) {
    if (updatedProfile.length == (email.endsWith("@globe.com.ph") ? 6 : 5)) {
      email.endsWith("@globe.com.ph") ? readEdits(updatedProfile) : readEditsOutsider(updatedProfile);
      setOnlineProfile(() => done(true));
    } else {
      done(false);
    }
  }

  void clear() {
    updatedProfile = {};
  }

  void updateProfileDetails(String key, String value) {
    if (value != "" && value != " " && !RegExp(r'[^0-9A-Za-z\/\s&+,.-]').hasMatch(value)) updatedProfile[key] = value;
  }

  void setOnlineProfile(void done()) {
    updateMap();
    ProfilePresenter.setMyAccount(profileLogin.uuid, userMap, done);
  }

  void setProfileData(Map<String, String> data) {
    email = data['email'];
    name = data['name'];
    photo = data['photo'];
  }

  Profile.saveGuest(Map<String, String> profile) {
    this.lastName = profile['last'];
    this.firstName = profile['first'];
    this.email = profile['email'];
    ProfilePresenter.saveGuest(this);
  }

  Profile.saveCredentialsPhoneAuth(String name, String email, String image) {
    this.name = name;
    this.email = email;
    this.photo = image;

//    this.userKey = AccountUtils.getUserKey(c.currentUser.email);
    ProfilePresenter.saveProfile(this, (bool s) {});
  }

  void getPrefsProfile() {
    ProfilePresenter.getPrefsProfile((Map<String, String> data) => setProfileData(data));
  }

  Profile.saveCredentials(c, void done(bool s)) {
    this.name = c.currentUser.displayName;
    this.email = c.currentUser.email;
    this.photo = c.currentUser.photoUrl;
//    this.userKey = AccountUtils.getUserKey(c.currentUser.email);
    ProfilePresenter.saveProfile(this, done);
  }

  void updateMap() {
    if (userMap == null) userMap = {};
    Map<String, String> nameMap = {};
    nameMap['Full'] = name;
    nameMap['First'] = firstName;
    nameMap['Last'] = lastName;
    userMap['Name'] = nameMap;

    userMap['Photo'] = photo;
    userMap['email'] = email;

    userMap['FCMToken'] = profileLogin.fcm;
    userMap['Division'] = division;

    userMap['Position'] = position;
    userMap['Mobile'] = mobile;
    userMap['Company'] = company;
    userMap['Group'] = group;
    userMap['ID Number'] = idNumber;
    userMap['Department'] = department;
  }

  void readEdits(Map<String, String> data) {
    firstName = data['First'];
    lastName = data['Last'];
    idNumber = data['ID'];
    group = data['Group'];
    division = data['Division'];
    department = data['Department'];
    name = "$firstName $lastName";
  }

  void readEditsOutsider(Map<String, String> data) {
    firstName = data['First'];
    lastName = data['Last'];
    company = data['Company'];
    position = data['Position'];
    mobile = data['Mobile'];
    name = "$firstName $lastName";
  }

  void profileFromJson(Map data) {
    userMap = data;
    name = data['Name']['Full'] != null ? data['Name']['Full'] : "";
    firstName = data['Name']['First'] != null ? data['Name']['First'] : "";
    lastName = data['Name']['Last'] != null ? data['Name']['Last'] : "";
    idNumber = data['ID Number'] != null ? data['ID Number'] : "";
    email = data['email'] != null ? data['email'] : "";
    company = data['Company'] != null ? data['Company'] : "";
    position = data['Position'] != null ? data['Position'] : "";
    mobile = data['Mobile'] != null ? data['Mobile'] : "";
    group = data['Group'] != null ? data['Group'] : "";
    division = data['Division'] != null ? data['Division'] : "";
    department = data['Department'] != null ? data['Department'] : "";
    token = data['FCMToken'] != null ? data['FCMToken'] : "";
    photo = data['Photo'] != null ? data['Photo'] : "";
  }
}

class AccountUtils {
  static String getUserKey(String email) {
    if (email != null) {
      String userKey = email.replaceAll("@", "");
      userKey = userKey.replaceAll(".", "");
      userKey = userKey.replaceAll("-", "");
      userKey = userKey.replaceAll("_", "");
      return userKey;
    }
    return "";
  }
}

class Subscription {
  final String type;
  final String name;
  final String subID;

  const Subscription({this.subID, this.name, this.type});
}
