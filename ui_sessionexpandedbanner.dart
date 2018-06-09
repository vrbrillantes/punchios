import 'package:flutter/material.dart';
import 'model_session.dart';
import 'model_sessionregistration.dart';

class SessionExpandedBanner extends StatelessWidget {
  SessionExpandedBanner({this.snapshot, this.attendanceList, this.onPressed, this.onCancelled}); // modified
  final ItemSession snapshot; // modified
  final VoidCallback onPressed;
  final VoidCallback onCancelled;
  final Map<String, ItemSessionRegistration> attendanceList;

  @override
  Widget build(BuildContext context) {
    VoidCallback onCancelledAction;
    VoidCallback onPressedAction;
    if (new DateTime.now().isBefore(snapshot.session.end.datetime)) onPressedAction = onPressed;
    if (new DateTime.now().isBefore(snapshot.session.end.datetime)) onCancelledAction = onCancelled;

    RaisedButton join = new RaisedButton(
      child: new Text("Register"),
      color: Colors.blue.shade500,
      textColor: Colors.white,
      onPressed: onPressedAction,
    );
    RaisedButton leave = new RaisedButton(
      child: new Text("Cancel"),
      color: Colors.red.shade300,
      textColor: Colors.white,
      onPressed: onCancelledAction,
    );

    //TODO done actions

    if (attendanceList != null) if (attendanceList[snapshot.slot].sessionID == snapshot.key) join = leave;

    return new Container(
      child: new Column(
        children: <Widget>[
          new ListTile(
            title: new Text(snapshot.session.name, style: Theme.of(context).textTheme.title),
            subtitle: new Text(snapshot.session.start.longdate + " | " + snapshot.session.start.time + " - " + snapshot.session.end.time, style: new TextStyle(color: Colors.grey)),
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
