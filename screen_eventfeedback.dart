import 'package:flutter/material.dart';
import 'model_events.dart';
import 'model_question.dart';
import 'model_feedback.dart';

class ScreenEventFeedback extends StatelessWidget {
  ScreenEventFeedback({this.loadEvent, this.questionlist});

  final List<Question> questionlist;
  final ItemEvent loadEvent;

  @override
  Widget build(BuildContext context) {
    return new ScreenEventFeedbackState(loadEvent: loadEvent, questionlist: questionlist,);
  }
}

class ScreenEventFeedbackState extends StatefulWidget {
  ScreenEventFeedbackState({this.loadEvent, this.questionlist});

  final List<Question> questionlist;
  final ItemEvent loadEvent;

  @override
  _ScreenEventFeedbackBuild createState() => new _ScreenEventFeedbackBuild(loadEvent: loadEvent, questionlist: questionlist);
}

class _ScreenEventFeedbackBuild extends State<ScreenEventFeedbackState> {
  _ScreenEventFeedbackBuild({this.loadEvent, this.questionlist});

  final List<Question> questionlist;
  final ItemEvent loadEvent;
  ListView formContents;
  static List<ItemFeedback> answers = <ItemFeedback>[];

  @override
  void initState() {
    formContents = new ListView.builder(
      itemCount: questionlist.length,
      itemBuilder: (BuildContext context, int index) {
        int questionIndex = index;
        return new Column(
          children: <Widget>[
            new Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 4.0),
              child: new Text(
                questionlist[questionIndex].question,
                style: Theme.of(context).textTheme.title,
              ),
            ),
            new Container(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: new TextFormField(
                  decoration: new InputDecoration(
                    border: const OutlineInputBorder(),
                  ),
                  onSaved: (String value) {
                    print(value);
                    addme(questionlist[questionIndex].question, value);
                  }),
            ),
          ],
        );
      },

    );
    super.initState();
  }

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  void _validateSession() {
    final FormState form = _formKey.currentState;
    form.save();
    Navigator.of(context).pop(answers);
  }

  static void addme(String q, String v) {
    answers.add(ItemFeedback.create(q, v));
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(
      data: new ThemeData(),
      child: new Scaffold(
        bottomNavigationBar: new BottomAppBar(
          color: Colors.white,
          child: new Container(
            padding: const EdgeInsets.all(16.0),
            child: new RaisedButton(
              color: Colors.blue.shade600,
              textColor: Colors.white,
              child: const Text('Submit feedback'),
              onPressed: _validateSession,
            ),
          ),
        ),
        appBar: new AppBar(
          title: new Text(loadEvent.name),
        ),
        body: new Form(
          key: _formKey,
          child: formContents,
        ),
      ),
    );
  }
}
