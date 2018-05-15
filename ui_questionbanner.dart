import 'package:flutter/material.dart';
import 'model_eventquestion.dart';

class QuestionBanner extends StatelessWidget {
  QuestionBanner({this.snapshot}); // modified
  final ItemEventQuestion snapshot; // modified

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Padding(
          padding: new EdgeInsets.only(right: 16.0),
          child: new ListTile(
            isThreeLine: true,
            leading: new ClipOval(child: new Image.network(snapshot.photo)),
//            leading: new Image.network(snapshot.photo),
            title: new Text(snapshot.name,
                style: Theme.of(context).textTheme.title),
            subtitle: new Text(snapshot.question,
                style: Theme.of(context).textTheme.body2),
          ),
        ),
      ],
    );
  }
}
