import 'package:flutter/material.dart';
import 'model_session.dart';

class ScreenNewSession extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ScreenNewSessionState();
  }
}

class ScreenNewSessionState extends StatefulWidget {
  @override
  _ScreenNewSessionBuild createState() => new _ScreenNewSessionBuild();
}

class _ScreenNewSessionBuild extends State<ScreenNewSessionState> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  ItemSession newSession;

  void _validateSession() {
    final FormState form = _formKey.currentState;
    form.save();
//    newSession = ItemSession.newSession("HELLO");
    Navigator.of(context).pop(newSession);
  }

  @override
  void initState() {
    newSession = ItemSession.newSession("HELLO", "HELLO");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(),
      child: new Scaffold(
        appBar: new AppBar(
          title: const Text("Create a new session"),
        ),
        body: new Form(
          key: _formKey,
          child: new SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: new Column(
              children: <Widget>[
                new Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(top: 32.0, bottom: 4.0),
                  child: new Text(
                    "Session title",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Input the name of the session here',
                    border: const OutlineInputBorder(),
                  ),
                  onSaved: (String value) {
                    newSession.name = value;
                  },
                ),
                new Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(top: 16.0, bottom: 64.0),
                  child: new Row(children: <Widget>[
                    new Expanded(
                        child: new RaisedButton(
                      color: Colors.blue.shade600,
                      textColor: Colors.white,
                      child: const Text('Create new session'),
                      onPressed: _validateSession,
                    )),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
