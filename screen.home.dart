import 'package:flutter/material.dart';
import 'screen.login.dart';
import 'screen.events.dart';
import 'screen.profileview.dart';

class ScreenHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenHomeState();
  }
}

class ScreenHomeState extends StatefulWidget {
  @override
  _ScreenHomeBuild createState() => _ScreenHomeBuild();
}

class _ScreenHomeBuild extends State<ScreenHomeState> with SingleTickerProviderStateMixin {
  bool isLoggedIn = false;
  bool hasBoardingPass = false;
  bool showGuest = false;
//  List<dynamic> boardingPassList;

  @override
  void initState() {
    super.initState();
  }

  void loggedIn(bool li) {
    setState(() {
      isLoggedIn = li;
    });
  }

//  void initGuest(String s) {
//    setState(() {
//      showGuest = true;
//      boardingPassList.add(s);
//    });
//  }


//  void returnBoardingPassList(List<dynamic> bp) {
//    setState(() {
//      boardingPassList = bp;
//    });
//    boardingPassQueryResult();
//  }

  void boardingPassQueryResult() {
//    setState(() {
//      hasBoardingPass = true;
//    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isLoggedIn
            ? ScreenEvents()
            : (hasBoardingPass
                ? SizedBox()
//                ? SizedBox(boardingPassList)
                : (showGuest
                    ? GuestProfile(onFinished: boardingPassQueryResult)
                    : ScreenLogin(
                        onLogIn: loggedIn,
//                        hasBoardingPass: returnBoardingPassList,
//                        initGuest: initGuest,
                        hasOfflineLogin: loggedIn,
                      ))));
  }
}
