import 'package:flutter/material.dart';
import 'ui.util.dart';
import 'ui.buttons.dart';
import 'ui.backdrop.dart';
import 'util.login.dart';
import 'util.internet.dart';

class ScreenLogin extends StatelessWidget {
  ScreenLogin({this.onLogIn,
    this.hasBoardingPass,
    this.initGuest,
    this.hasOfflineLogin});

  final Function(bool) onLogIn;
  final Function(String) initGuest;
  final Function(List<dynamic>) hasBoardingPass;
  final Function(bool) hasOfflineLogin;

  @override
  Widget build(BuildContext context) {
    return new ScreenLoginState(
        onLogIn: onLogIn,
        hasBoardingPass: hasBoardingPass,
        initGuest: initGuest,
        hasOfflineLogin: hasOfflineLogin);
  }
}

class ScreenLoginState extends StatefulWidget {
  ScreenLoginState({this.onLogIn,
    this.hasBoardingPass,
    this.initGuest,
    this.hasOfflineLogin});

  final void Function(bool) onLogIn;
  final Function(bool) hasOfflineLogin;
  final Function(String) initGuest;
  final Function(List<dynamic>) hasBoardingPass;

  @override
  _ScreenLoginBuild createState() =>
      new _ScreenLoginBuild(
          onLogIn: onLogIn,
          hasBoardingPass: hasBoardingPass,
          initGuest: initGuest,
          hasOfflineLogin: hasOfflineLogin);
}

class _ScreenLoginBuild extends State<ScreenLoginState> {
  _ScreenLoginBuild({this.onLogIn,
    this.hasBoardingPass,
    this.initGuest,
    this.hasOfflineLogin});

  PunchInternetUtils netUtils;
  LoginFunctions loginFunctions = LoginFunctions();
  bool returnedLogin = false;
  final void Function(bool) onLogIn;
  final Function(bool) hasOfflineLogin;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = new GlobalKey<FormState>();
  bool phoneAuth = false;
  bool additionalFields = false;
  final Function(String) initGuest;

  final Function(List<dynamic>) hasBoardingPass;

  @override
  void initState() {
    super.initState();
    loginFunctions.checkSignIn((String s) => setState(()=>loginStatus = s),loggedIn, notLoggedIn);
//    netUtils = PunchInternetUtils((bool s) {
//      s
//          ? loginFunctions.checkSignIn(loggedIn, notLoggedIn)
//          : loginFunctions.hasOfflineLogin(hasOfflineLogin);
//    }, (bool s) {});
  }

  @override
  void dispose() {
    netUtils.disposeSubscriptions();
    super.dispose();
  }

  void loggedIn() async {
    setState(() {
      onLogIn(true);
    });
    layoutChange();
  }

  void notLoggedIn() {
    loginFunctions.checkBoardingPass((List<dynamic> bb) {
      bb.length > 0 ? hasBoardingPass(bb) : onLogIn(false);
    });
    layoutChange();
  }

  void layoutChange() {
    setState(() {
      returnedLogin = true;
      hiddenHeight = 120;
      opacity = 1;
    });
  }

  void showAdditionalFields() {
    setState(() {
      additionalFields = !additionalFields;
    });
  }

  void showPhoneAuth() {
    setState(() {
      phoneAuth = !phoneAuth;
    });
  }

  double hiddenHeight = 0;
  double opacity = 0;

  void submitPhone() {
    final FormState form = _formKey.currentState;
    form.save();
    loginFunctions.initPhoneAuth(loginValues['phone']);
  }

  void saveInfo() {
    final FormState form = _formKey2.currentState;
    form.save();
    loginFunctions.updateFirebaseUser(
        loginValues['name'], loginValues['email'], loggedIn);
  }

  void submitVerif() {
    final FormState form = _formKey.currentState;
    form.save();
    loginFunctions.submitCode(
        loginValues['code'], showAdditionalFields, loggedIn);
  }

  Map<String, String> loginValues = {};

  void saveValue(String key, String value) {
    if (value != "" &&
        value != " " &&
        !RegExp(r'[^0-9A-Za-z,@_+.\/-\s]').hasMatch(value))
      loginValues[key] = value;
  }

  String loginStatus = "Signed out";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Backdrop(),
          Positioned.fill(
            left: 40,
            right: 40,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOutCubic,
                  height: hiddenHeight,
                ),
                AnimatedOpacity(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOutCubic,
                  opacity: opacity,
                  child: Column(
                    children: <Widget>[
                      PunchRaisedButton(
                        label: "Sign in",
                        action:
                        returnedLogin ? loginFunctions.googleSignIn : null,
                      ),
//                      Text(loginStatus),
//                      phoneAuth
//                          ? SizedBox()
//                          : PunchRaisedButton(
//                              label: "Phone Login",
//                              action: returnedLogin ? showPhoneAuth : null,
//                            ),
                    ],
                  ),
                ),
                phoneAuth
                    ? SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      additionalFields
                          ? Form(
                        key: _formKey2,
                        child: Column(
                          children: <Widget>[
                            StyledTextFormField(
                                field: "name",
                                action: saveValue,
                                label: "Name"),
                            StyledTextFormField(
                                field: "email",
                                action: saveValue,
                                label: "Email"),
                            PunchRaisedButton(
                              label: "Save information",
                              action: saveInfo,
                            ),
                          ],
                        ),
                      )
                          : Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            StyledTextFormField(
                                field: "phone",
                                action: saveValue,
                                label: "Mobile Number"),
                            PunchRaisedButton(
                                label: "Request verification code",
                                action: submitPhone),
                            StyledTextFormField(
                                field: "code",
                                action: saveValue,
                                label: "Verification Code"),
                            PunchRaisedButton(
                              label: "Verify code",
                              action: submitVerif,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    : SizedBox()
              ],
            ),
          ),
          Positioned.fill(
            left: 40,
            right: 40,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                phoneAuth
                    ? SizedBox()
                    : Image.asset('images/logo_punch-main@3x.png'),
                AnimatedContainer(
                  duration: Duration(seconds: 1),
                  curve: Curves.easeInOutCubic,
                  height: hiddenHeight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
