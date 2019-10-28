import 'dart:async';
import 'dart:io' show Platform;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'model.profile.dart';
import 'util.preferences.dart';
import 'model.boardingpass.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
final GoogleSignIn _googleSignIn = new GoogleSignIn();
AppPreferences prefs = AppPreferences.newInstance();

class LoginFunctions {
  static Login myLogin = Login.newLogin();

  Profile p;
  String authID;
  int refreshID;

  FirebaseUser user;

  void firebaseAuth(GoogleSignInAccount cu, void done()) async {
    final GoogleSignInAuthentication googleAuth = await cu.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    user = await _auth.signInWithCredential(credential);

    setupToken((String token) {
      myLogin.saveOfflineLoginData(user.email, user.uid, token);
      done();
    });
  }

  void checkSignIn(
    void changeStatus(String s),
    void loggedIn(bool bb),
  ) async {
    void processGSIAccount(GoogleSignInAccount gsi) {
      if (gsi != null) {
        firebaseAuth(gsi, () => setupFCM(() => Profile.saveCredentials(_googleSignIn, (bool s) => loggedIn(true))));
      } else {
        loggedIn(false);
      }
    }

    void initListeners() {
      loggedIn(false);
      _googleSignIn.onCurrentUserChanged.listen(processGSIAccount);
    }

    FirebaseUser user = await _auth.currentUser();
    if (user != null && user.email != null) {
      myLogin.getOfflineLoginData(() {
        myLogin.fcm != null ? loggedIn(true) : initListeners();
      });
    } else {
      initListeners();
    }
  }

  Future<void> googleSignIn() async {
    try {
//      await _googleSignIn.signOut();
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  void initPhoneAuth(String s) {
    _auth.verifyPhoneNumber(
        phoneNumber: s,
        timeout: Duration(minutes: 1),
        verificationCompleted: null,
        verificationFailed: (AuthException ex) {},
        codeSent: (String s, [int i]) {
          authID = s;
          refreshID = i;
        },
        codeAutoRetrievalTimeout: null);
  }

  void submitCode(String smsCode, void showOtherInfo(), void loggedIn()) async {
    user = await _auth.signInWithCredential(PhoneAuthProvider.getCredential(
        verificationId: authID, smsCode: smsCode));
    (user.email == null || user.displayName == null)
        ? showOtherInfo()
        : setProfileAndLogin(user.displayName, user.email, loggedIn);
  }

  void setProfileAndLogin(String name, String email, void loggedIn()) {
    setupToken((String token) {
      myLogin.saveOfflineLoginData(email, user.uid, token);
      Profile.saveCredentialsPhoneAuth(name, email,
          "http://pngimg.com/uploads/running_shoes/running_shoes_PNG5818.png");
      loggedIn();
    });
  }

  void updateFirebaseUser(String name, String email, void done()) {
    UserUpdateInfo userInfo = UserUpdateInfo();
    userInfo.displayName = name;

    user.updateProfile(userInfo).then((FutureOr<dynamic> ss) {
      user.updateProfile(userInfo).then((FutureOr<dynamic> ss) {
        setProfileAndLogin(name, email, done);
      }, onError: (e) {});
    }, onError: (e) {});
  }

  void checkBoardingPass(void hasBoardingPasses(List<dynamic> boardingPasses)) {
    BoardingPassPresenter.getSavedBoardingPasses(hasBoardingPasses);
  }

  void saveBoardingPass(String s, void saved(bool b)) async {
    BoardingPassPresenter.getSavedBoardingPasses(
        (List<dynamic> boardingPasses) {
      boardingPasses.add(s);
      BoardingPassPresenter.saveBoardingPasses(boardingPasses, saved);
    });
  }

  static void logOut() {
    _googleSignIn.signOut();
    myLogin.deleteOfflineLoginData();
  }

  static void setupToken(void done(String s)) {
    _firebaseMessaging.getToken().then((String newToken) {
      assert(newToken != null);
      done(newToken);
    });
  }

  void setupFCM(void done()) {
    if (Platform.isIOS) iOSPermission();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print("onMessage: $message");
        return null;
      },
      onLaunch: (Map<String, dynamic> message) {
        print("onLaunch: $message");
        return null;
      },
      onResume: (Map<String, dynamic> message) {
        print("onResume: $message");
        return null;
      },
    );
    done();
  }

  static void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
  }
}
