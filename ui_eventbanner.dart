import 'package:flutter/material.dart';
import 'model_events.dart';

class EventBanner extends StatelessWidget {
  EventBanner({this.snapshot, this.onPressed}); // modified
  final ItemEvent snapshot; // modified
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Padding(
          child: new InkWell(
            child: new Card(
              child: new Column(
                children: <Widget>[
                  new Hero(
                    tag: snapshot.key,
                    child: new Image.network(snapshot.banner,
                        height: 160.0, width: 1000.0, fit: BoxFit.cover),
                  ),
                  new ListTile(
                    leading: new Column(children: <Widget>[
                      new Text(snapshot.event.start.shortmonth,
                          textAlign: TextAlign.center,
                          style: new TextStyle(color: Colors.red)),
                      new Text(snapshot.event.start.day,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headline),
                    ]),
                    title: new Text(snapshot.event.name,
                        style: Theme.of(context).textTheme.title),
                    subtitle: new Text(snapshot.brief,
                        style: new TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
            onTap: onPressed,
          ),
          padding: new EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        ),
      ],
    );
  }
}
