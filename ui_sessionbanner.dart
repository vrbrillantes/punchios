import 'package:flutter/material.dart';
import 'model_session.dart';

class SessionBanner extends StatelessWidget {
  SessionBanner({this.snapshot, this.attendanceList, this.onAsk, this.onFeedback}); // modified
  final ItemSession snapshot; // modified
  final Map<String, String> attendanceList;
  final VoidCallback onAsk;
  final VoidCallback onFeedback;


  @override
  Widget build(BuildContext context) {
    FlatButton toshow;
    FlatButton ask = new FlatButton(
      child: new Text("Ask a question"),
      textColor: Colors.blue,
      onPressed: onAsk,
    );
    FlatButton attending = new FlatButton(
      child: new Text("Attending"),
      disabledTextColor: Colors.blue,
      onPressed: null,
    );
    FlatButton feedback = new FlatButton(
      child: new Text("Submit feedback"),
      textColor: Colors.blue,
      onPressed: onFeedback,
    );

    if (attendanceList != null) {
      if (attendanceList[snapshot.slot] == snapshot.key) {
        if (new DateTime.now().isBefore(snapshot.starttime.datetime)) {
          toshow = attending;
        } else if (new DateTime.now().isAfter(snapshot.endtime.datetime)) {
          toshow = feedback;
        } else {
          toshow = ask;
        }
      }
    }

    return new Container(
      color: Colors.grey.shade200,
      child: new Column(
        children: <Widget>[
          new ListTile(
            trailing: toshow,
            title: new Text(snapshot.name, style: Theme.of(context).textTheme.title),
            subtitle: new Text(snapshot.starttime.longdate + " | " + snapshot.starttime.time + " - " + snapshot.endtime.time, style: new TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
