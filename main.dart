import 'package:flutter/material.dart';
import 'screen.home.dart';
import 'screen.notifications.dart';
import 'screen.eventview.dart';
import 'screen.questions.dart';

void main() {
  runApp(MaterialApp(
    title: 'Punch',
    initialRoute: '/',
    routes: {
      '/': (context) => ScreenHome(),
//      '/eventList': (context) => ScreenEvents(),
      '/notifs': (context) => ScreenNotifications(),
      '/eventView': (context) => ScreenEventView(),
      '/questions': (context) => ScreenQuestions(),
    },
  ));
}


//class FlightExample extends StatefulWidget {
//  @override
//  FlightExampleState createState() {
//    return new FlightExampleState();
//  }
//}
//
//class FlightExampleState extends State<FlightExample> {
//  var _alignment = Alignment.bottomCenter;
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: AnimatedContainer(
//        padding: EdgeInsets.all(10.0),
//        duration: Duration(seconds: 1, milliseconds: 500),
//        curve: Curves.easeInOutCubic,
//        alignment: _alignment,
//        child: Container(
//          height: 50.0,
//          child: Icon(
//            Icons.airplanemode_active,
//            size: 50.0,
//            color: Colors.blueAccent,
//          ),
//        ),
//      ),
//      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//      floatingActionButton: FloatingActionButton.extended(
//          backgroundColor: Colors.blueAccent,
//          onPressed: () {
//            setState(() {
//              _alignment = Alignment.center;
//            });
//          },
//          icon: Icon(Icons.airplanemode_active),
//          label: Text("Take Flight")),
//    );
//  }
//}
