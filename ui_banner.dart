import 'package:flutter/material.dart';
import 'item_todo.dart';
import 'screen_responses.dart';
class EventBanner extends StatelessWidget {
  EventBanner({this.snapshot}); // modified
  final Todo snapshot; // modified
//  final Animation animation;

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Card(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Image.network(snapshot.banner),
              new Text(snapshot.name,
                  style: Theme.of(context).textTheme.subhead),
            ],
          ),
        ),
        new ListTile(
          leading: new Icon(Icons.date_range),
          // ignore: const_eval_throws_exception
          title: new Text(snapshot.startdate,
              style: Theme.of(context).textTheme.subhead),
          subtitle: new Text(snapshot.venue),
        ),
        new ButtonTheme.bar(
          child: new ButtonBar(
            alignment: MainAxisAlignment.start,
            children: <Widget>[
              new FlatButton(
                child: const Text('SHARE'),
                textColor: Colors.amber.shade500,
                onPressed: () {
                  /* do nothing */
                  Navigator.push(
                    context,
                    new MaterialPageRoute(builder: (context) => new ExpasionPanelsDemo(questionlist: snapshot.questionlist)),
                  );
                },
              ),
              new FlatButton(
                child: const Text('EXPLORE'),
                textColor: Colors.amber.shade500,
                onPressed: () {
                  /* do nothing */
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}