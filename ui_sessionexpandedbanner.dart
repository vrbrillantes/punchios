import 'package:flutter/material.dart';
import 'model_session.dart';
import 'model_sessionregistration.dart';

class SessionExpandedBanner extends StatelessWidget {
  SessionExpandedBanner({this.snapshot, this.attendanceList, this.onPressed, this.onCancelled}); // modified
  final ItemSession snapshot; // modified
  final VoidCallback onPressed;
  final VoidCallback onCancelled;
  final Map<String, String> attendanceList;

  @override
  Widget build(BuildContext context) {
    RaisedButton join = new RaisedButton(
      child: new Text("Register"),
      color: Colors.blue.shade500,
      textColor: Colors.white,
      onPressed: onPressed,
    );
    RaisedButton leave = new RaisedButton(
      child: new Text("Cancel"),
      color: Colors.red.shade300,
      textColor: Colors.white,
      onPressed: onCancelled,
    );

    if (attendanceList[snapshot.slot] == snapshot.key) join = leave;

    return new Container(
      child: new Column(
        children: <Widget>[
          new ListTile(
            title: new Text(snapshot.name, style: Theme.of(context).textTheme.title),
            subtitle: new Text(snapshot.starttime.longdate + " | " + snapshot.starttime.time + " - " + snapshot.endtime.time, style: new TextStyle(color: Colors.grey)),
          ),
          new Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.topRight,
            child: join
          ),
        ],
      ),
    );
  }
}
