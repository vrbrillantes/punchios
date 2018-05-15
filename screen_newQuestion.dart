import 'package:flutter/material.dart';
import 'model_session.dart';

class ScreenNewQuestion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ScreenNewQuestionState();
  }
}

class ScreenNewQuestionState extends StatefulWidget {
  @override
  _ScreenNewQuestionBuild createState() => new _ScreenNewQuestionBuild();
}

class _ScreenNewQuestionBuild extends State<ScreenNewQuestionState> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String newQuestion;

  void _validateSession() {
    final FormState form = _formKey.currentState;
    form.save();
    Navigator.of(context).pop(newQuestion);
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
                    "What is your question?",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Ask your question here',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  onSaved: (String value) {
                    newQuestion = value;
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
                      child: const Text('Submit your question'),
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
