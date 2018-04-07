import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
//import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:event-banner.dart';
import 'dart:async';
import 'event-banner.dart';
import 'package:firebase_database/firebase_database.dart';         //new
import 'package:firebase_database/ui/firebase_animated_list.dart';

final googleSignIn = new GoogleSignIn();
//final analytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;

class FriendlychatApp extends StatefulWidget {
  const FriendlychatApp();
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<StatefulWidget> {
  final reference = FirebaseDatabase.instance.reference().child('HELLO').child('Events');
  bool _isComposing = false;
  final TextEditingController _textController = new TextEditingController();                 //new
  @override                                                      //new
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Friendlychat",
      home: new Scaffold(
        appBar: new AppBar(title: new Text("Friendlychat")),
        body: new Column(children: <Widget>[
          new Flexible(
              child: new FirebaseAnimatedList(
                  query: reference.orderByChild("Attendees/vcbrillantesglobecomph").equalTo(true),                                     //new
                  sort: (a, b) => b.key.compareTo(a.key),                 //new
                  padding: new EdgeInsets.all(8.0),                       //new
                  reverse: true,
                  itemBuilder: (context, DataSnapshot snapshot, Animation<double> animation, _) {
                    return new EventBanner(snapshot: snapshot, animation: animation);
                  })
          ),
          new Divider(height: 1.0),
          new Container(
            decoration: new BoxDecoration(
                color: Theme.of(context).cardColor
            ),
            child: _buildTextComposer(),
          ),
        ]),
      ),
    );
  }
  Future<Null> _handleSubmitted(String text) async {         //modified
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    await _ensureLoggedIn();                                       //new
    _sendMessage(text: text);                                      //new
  }
  void _sendMessage({ String text }) {
    reference.push().set({                                         //new
      'text': text,                                                //new
      'senderName': googleSignIn.currentUser.displayName,          //new
      'senderPhotoUrl': googleSignIn.currentUser.photoUrl,         //new
    });                                                            //new
//    analytics.logEvent(name: 'send_message');
  }

  Widget _buildTextComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onChanged: (String text) {          //new
                  setState(() {                     //new
                    _isComposing = text.length > 0; //new
                  });                               //new
                },                                  //new
                onSubmitted: _handleSubmitted,
                decoration: new InputDecoration.collapsed(
                    hintText: "Send a message"
                ),
              ),
            ),
            new Container(         //new
              margin: new EdgeInsets.symmetric(horizontal: 4.0),           //new
              child: new IconButton(                                       //new
                icon: new Icon(Icons.send),                                //new
                onPressed: _isComposing ? () => _handleSubmitted(_textController.text) : null,                                           //modified
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<Null> _ensureLoggedIn() async {
    GoogleSignInAccount user = googleSignIn.currentUser;
    if (user == null)
      user = await googleSignIn.signInSilently();
    if (user == null) {
      await googleSignIn.signIn();
//      analytics.logLogin();
    }
    if (await auth.currentUser() == null) {                          //new
      GoogleSignInAuthentication credentials =                       //new
      await googleSignIn.currentUser.authentication;                 //new
      await auth.signInWithGoogle(                                   //new
        idToken: credentials.idToken,                                //new
        accessToken: credentials.accessToken,                        //new
      );                                                             //new
    }
  }
}
