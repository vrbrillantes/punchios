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
class ClickCounter extends StatefulWidget {
  const ClickCounter({Key key}) : super(key: key);

  @override
  _ClickCounterState createState() => _ClickCounterState();
}

class _ClickCounterState extends State<ClickCounter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(child: child, scale: animation);
              },
              child: Text(
                '$_count',
                // This key causes the AnimatedSwitcher to interpret this as a "new"
                // child each time the count changes, so that it will begin its animation
                // when the count changes.
                key: ValueKey<int>(_count),
                style: Theme.of(context).textTheme.display1,
              ),
            ),
            RaisedButton(
              child: const Text('Increment'),
              onPressed: () {
                setState(() {
                  _count += 1;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}