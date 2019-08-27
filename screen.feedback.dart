import 'package:flutter/material.dart';
import 'ui.util.dart';
import 'ui.buttons.dart';
import 'ui.backdrop.dart';
import 'model.participation.dart';
import 'model.feedback.dart';
import 'ui_starrating.dart';

class ScreenFeedback extends StatelessWidget {
  ScreenFeedback({this.eventKey, this.eventName, this.editable, this.session = false, this.workshop = false, this.registration = false});

  final String eventKey;
  final String eventName;
  final bool workshop;
  final bool session;
  final bool editable;
  final bool registration;

  @override
  Widget build(BuildContext context) {
    return ScreenTextDialogState(eventKey: eventKey, eventName: eventName, editable: editable, workshop: workshop, session: session, registration: registration);
  }
}

class ScreenTextDialogState extends StatefulWidget {
  ScreenTextDialogState({this.eventKey, this.eventName, this.editable, this.session, this.workshop, this.registration});

  final String eventKey;
  final String eventName;
  final bool editable;
  final bool workshop;
  final bool session;
  final bool registration;

  @override
  _ScreenTextDialogBuild createState() => _ScreenTextDialogBuild(eventKey: eventKey, eventName: eventName, editable: editable, workshop: workshop, session: session, registration: registration);
}

class _ScreenTextDialogBuild extends State<ScreenTextDialogState> {
  _ScreenTextDialogBuild({this.eventKey, this.eventName, this.editable, this.session, this.workshop, this.registration});

  final String eventKey;
  final String eventName;

  final bool session;
  final bool workshop;
  final bool registration;

  List<FeedbackQuestion> questionList;
  List<FeedbackQuestion> editList;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final bool editable;
  bool editing = false;

  @override
  void initState() {
    super.initState();
    session
        ? FeedbackQuestions.forSessionsfromFirebase(eventKey, refreshLists)
        : workshop
            ? FeedbackQuestions.forWorkshopsFromFirebase(eventKey, refreshLists)
            : registration ? FeedbackQuestions.forRegistration(eventKey, refreshLists) : FeedbackQuestions.fromFirebase(eventKey, refreshLists);
  }

  void refreshLists(List<FeedbackQuestion> ll) {
    setState(() {
      editList = <FeedbackQuestion>[];
      questionList = <FeedbackQuestion>[];
      editList.addAll(ll);
      questionList.addAll(ll);
      questionList.add(FeedbackQuestion.submitButton("Z"));
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final FeedbackQuestion item = editList.removeAt(oldIndex);
      editList.insert(newIndex, item);
    });
  }

  Widget buildListTile(FeedbackQuestion item) {
    return ListTile(
      key: Key(item.key),
      title: Text(item.question),
      subtitle: Text(item.longType),
      leading: Icon(Icons.drag_handle),
    );
  }

  void onChangeEdit() {
    setState(() {
      editing = !editing;
      if (editing == false) refreshLists(editList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          unselectedWidgetColor: AppColors.appGreyscalePlus,
        ),
        child: Stack(
          children: <Widget>[
            Backdrop2(),
            Scaffold(
              backgroundColor: const Color(0x00000000),
              appBar: AppBar(
                leading: IconButton(icon: Icon(Icons.keyboard_arrow_left), onPressed: () => Navigator.pop(context)),
                backgroundColor: AppColors.appColorBackground,
                title: Text(eventName, style: AppTextStyles.appbarTitle),
                actions: <Widget>[
                  editable ? IconButton(icon: Icon(editing ? Icons.save : Icons.edit), onPressed: onChangeEdit) : SizedBox(),
                ],
              ),
              body: questionList == null
                  ? SizedBox()
                  : (editing ? ReorderableListView(children: editList.map<Widget>(buildListTile).toList(), onReorder: _onReorder) : ScreenFeedbackList(questionList: questionList)),
            ),
          ],
        ));
  }
}

class ScreenFeedbackList extends StatelessWidget {
  ScreenFeedbackList({this.questionList});

  final List<FeedbackQuestion> questionList;

  @override
  Widget build(BuildContext context) {
    return ScreenFeedbackListState(questionList: questionList);
  }
}

class ScreenFeedbackListState extends StatefulWidget {
  ScreenFeedbackListState({this.questionList});

  final List<FeedbackQuestion> questionList;

  @override
  _ScreenFeedbackBuild createState() => _ScreenFeedbackBuild(questionList: questionList);
}

class _ScreenFeedbackBuild extends State<ScreenFeedbackListState> {
  _ScreenFeedbackBuild({this.questionList});

  bool complete = true;
  final List<FeedbackQuestion> questionList;
  List<Response> responseList;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void saveResponse(Response s) {
    responseList.add(s);
  }

  void saveForm() {
    complete = true;
    final FormState form = _formKey.currentState;
    responseList = <Response>[];
    form.save();
    if (complete) Navigator.pop(context, responseList);
  }

  Widget buildFeedbackWidget(FeedbackQuestion qq) {
    void onResponse(String s) {
      if (s != null && s != "" && s != " ")
        saveResponse(Response.newResponse(qq.question, s));
      else
        complete = false;
    }

    void processMultiResponse(Map<String, bool> ss) {
      ss.forEach((k, v) {
        if (v) onResponse(k);
      });
    }

    switch (qq.type) {
      case "R":
        return RatingFeedback(qq.question, onResponse);
      case "F":
        return TextFeedback(qq.question, onResponse);
      case "P":
        return PollFeedback(qq, onResponse);
      case "YN":
        return PollFeedback(qq, onResponse);
      case "AS":
        return PollFeedback(qq, onResponse);
      case "RS":
        return PollFeedback(qq, onResponse);
      case "UYS":
        return PollFeedback(qq, onResponse);
      case "MS":
        return MultipleFeedback(qq, processMultiResponse);
      case "SB":
        return Column(children: <Widget>[SizedBox(height: 80), PunchRaisedButton(label: "Submit", action: saveForm), SizedBox(height: 20)]);
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: questionList.map<Widget>(buildFeedbackWidget).toList(),
        ),
      ),
    );
  }
}

class RatingFeedback extends StatelessWidget {
  RatingFeedback(this.question, this.onResponse);

  final String question;
  final Function(String) onResponse;

  void onAnswer(double s) {
    onResponse(s.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FeedbackLabel(question),
        FormField<double>(
          initialValue: 0,
          onSaved: onAnswer,
          builder: (FormFieldState<double> field) {
            return StarRating(
              rating: field.value,
              onRatingChanged: field.didChange,
            );
          },
        ),
      ],
    );
  }
}

class TextFeedback extends StatelessWidget {
  TextFeedback(this.question, this.onResponse);

  final String question;
  final Function(String) onResponse;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FeedbackLabel(question),
        Padding(
          child: StyledTextFormFieldField(action: onResponse, label: "", maxLines: 3),
          padding: EdgeInsets.symmetric(horizontal: 18),
        ),
      ],
    );
  }
}

class MultipleFeedback extends StatefulWidget {
  MultipleFeedback(this.question, this.onResponse);

  final Function(Map<String, bool>) onResponse;
  final FeedbackQuestion question;

  @override
  MultipleFeedbackState createState() => MultipleFeedbackState(question, onResponse);
}

class MultipleFeedbackState extends State<MultipleFeedback> {
  MultipleFeedbackState(this.question, this.onResponse);

  final Function(Map<String, bool>) onResponse;
  final FeedbackQuestion question;

  @override
  Widget build(BuildContext context) {
    return FormField(
      onSaved: (Map<String, bool> ss) {
        onResponse(question.boolChoices);
      },
      builder: (FormFieldState<Map<String, bool>> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FeedbackLabel(question.question),
            Padding(
              child: Column(
                children: question.boolChoices.keys.map((String key) {
                  return CheckboxListTile(
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: AppColors.appAccentYellow,
                      title: Text(key, style: AppTextStyles.styleWhite(14)),
                      value: question.boolChoices[key],
                      onChanged: (bool value) {
                        setState(() {
                          question.boolChoices[key] = value;
                        });
                      });
                }).toList(),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
            )
          ],
        );
      },
    );
  }
}

class PollFeedback extends StatelessWidget {
  PollFeedback(this.question, this.onResponse);

  final FeedbackQuestion question;
  final Function(String) onResponse;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      onSaved: onResponse,
      builder: (FormFieldState<String> field) {
        List<Widget> choiceWidgets = <Widget>[];
        choiceWidgets.add(FeedbackLabel(question.question));
        question.choices.forEach((String s) {
          choiceWidgets.add(ListTile(
            title: Text(s, style: AppTextStyles.styleWhite(14)),
            leading: Radio<String>(
              activeColor: AppColors.appAccentYellow,
              value: s,
              groupValue: field.value,
              onChanged: field.didChange,
            ),
          ));
        });
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: choiceWidgets,
        );
      },
    );
  }
}

class FeedbackLabel extends StatelessWidget {
  FeedbackLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Text(label, textAlign: TextAlign.start, style: AppTextStyles.styleWhiteBold(14)),
      padding: EdgeInsets.fromLTRB(36, 54, 36, 18),
    );
  }
}
