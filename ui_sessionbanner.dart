import 'package:flutter/material.dart';
import 'model_session.dart';
import 'model_sessionregistration.dart';

class SessionBanner extends StatelessWidget {
  SessionBanner({this.snapshot, this.attendanceList, this.onAsk, this.onFeedback, this.addFeedback}); // modified
  final ItemSession snapshot; // modified
  final Map<String, ItemSessionRegistration> attendanceList;
  final VoidCallback onAsk;
  final VoidCallback onFeedback;
  final VoidCallback addFeedback;


  @override
  Widget build(BuildContext context) {
    FlatButton toshow;
    FlatButton ask = new FlatButton(
      child: new Text("Ask a question"),
      textColor: Colors.blue.shade600,
      onPressed: onAsk,
    );
    FlatButton attending = new FlatButton(
      child: new Text("Attending"),
      disabledTextColor: Colors.blue.shade300,
      onPressed: null,
    );
    FlatButton feedback = new FlatButton(
      child: new Text("Submit feedback"),
      textColor: Colors.blue.shade600,
      onPressed: onFeedback,
    );
    FlatButton _addFeedback = new FlatButton(
      child: new Text("Manage Feedback"),
      textColor: Colors.green.shade600,
      onPressed: addFeedback,
    );

    if (attendanceList != null) {
      if (attendanceList[snapshot.slot].sessionID == snapshot.key) {
        //TODO done actions
        if (new DateTime.now().isBefore(snapshot.session.start.datetime)) {
          toshow = attending;
        } else if (new DateTime.now().isAfter(snapshot.session.end.datetime)) {
          toshow = feedback;
        } else {
          toshow = ask;
        }
      }
    }

    if (addFeedback != null) toshow = _addFeedback;

    return new Container(
      color: Colors.grey.shade200,
      child: new Column(
        children: <Widget>[
          new ListTile(
            trailing: toshow,
            title: new Text(snapshot.session.name, style: Theme.of(context).textTheme.title),
            subtitle: new Text(snapshot.session.start.longdate + " | " + snapshot.session.start.time + " - " + snapshot.session.end.time, style: new TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
