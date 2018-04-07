import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class EventBanner extends StatelessWidget {
  EventBanner({this.snapshot, this.animation}); // modified
  final DataSnapshot snapshot; // modified
  final Animation animation;

  @override
  Widget build(BuildContext context) {
//    return new Card(
//      child: new Column(
//        crossAxisAlignment: CrossAxisAlignment.start,
//        children: <Widget>[
//          // photo and title
//          // description and share/expore buttons
//          new Expanded(
//            child: new Padding(
//              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
//              child: new DefaultTextStyle(
//                softWrap: false,
//                overflow: TextOverflow.ellipsis,
////                style: descriptionStyle,
//                child: new Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
//                  children: <Widget>[
//                    // three line description
//                    new Padding(
//                      padding: const EdgeInsets.only(bottom: 8.0),
//                      child: new Text(snapshot.value['senderName']),
//                    ),
//                    new Text(snapshot.value['senderName']),
//                    new Text(snapshot.value['senderName']),
//                  ],
//                ),
//              ),
//            ),
//          ),
//          // share, explore buttons
//        ],
//      ),
//    );
    return new Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Card(
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Image.network(snapshot.value['Banner']),
              new Text(snapshot.value['Name'],
                  style: Theme.of(context).textTheme.subhead),
//              new SizedBox(
//                height: 184.0,
//                child: new Stack(
//                  children: <Widget>[
////                    new Positioned.fill(
////                      child: new Image.network(snapshot.value['Banner']),
////                    ),
//                    new Positioned(
//                      bottom: 16.0,
//                      left: 16.0,
//                      right: 16.0,
//                      child: new FittedBox(
//                        fit: BoxFit.scaleDown,
//                        alignment: Alignment.centerLeft,
//                        child: new Text(snapshot.value['Name'],
//                            style: Theme.of(context).textTheme.subhead),
//                      ),
//                    ),
//                  ],
//                ),
//              ),
            ],
          ),
        ),
        new ListTile(
          leading: new Icon(Icons.date_range),
          // ignore: const_eval_throws_exception
          title: new Text(snapshot.value['StartDate'],
              style: Theme.of(context).textTheme.subhead),
          subtitle: new Text(snapshot.value['Venue']),
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
