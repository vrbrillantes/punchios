import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'model_session.dart';
import 'screen_newSession.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:io';
import 'ui_datetimepicker.dart';
import 'package:intl/intl.dart';
import 'model_events.dart';
import 'package:image/image.dart' as Im;

class ScreenNewEvent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ScreenNewEventState();
  }
}

class ScreenNewEventState extends StatefulWidget {
  @override
  _ScreenNewEventBuild createState() => new _ScreenNewEventBuild();
}

class _ScreenNewEventBuild extends State<ScreenNewEventState> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  List<ItemSession> sessionList = <ItemSession>[];
  List<Widget> sessionRows = <Widget>[];
  String _imagesource;
  ItemEvent newEvent = new ItemEvent.newEvent("event");
  DateTime _fromDate = new DateTime.now();
  DateTime _toDate = new DateTime.now();
  TimeOfDay _fromTime = const TimeOfDay(hour: 8, minute: 00);
  TimeOfDay _toTime = const TimeOfDay(hour: 9, minute: 00);

//  TimeOfDay _fromTime = const TimeOfDay(hour: 7, minute: 28);

//  String _validatePhoneNumber(String value) {
////    _formWasEdited = true;
//    final RegExp phoneExp = new RegExp(r'^\d\d\-\d\d\-\d\d\d\d\d$');
//    if (!phoneExp.hasMatch(value))
//      return '(###) ###-#### - Enter a US phone number.';
//    return null;
//  }

  bool radioPrivacy = false;
  bool radioMultipleEvent = false;

  void showLoading() {}

  Future _uploadImage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
//    Im.Image img = Im.decodeImage(imageFile.readAsBytesSync());
    int random = new Random().nextInt(100000);
    StorageReference ref = FirebaseStorage.instance.ref().child("image_$random.jpg");
    StorageUploadTask uploadTask = ref.put(imageFile);
    Uri downloadUrl = (await uploadTask.future).downloadUrl;
    setState(() {
      _imagesource = downloadUrl.toString();
    });
  }

  Future _showNewSessionForm() async {
    ItemSession newSession = await Navigator.push(context, new MaterialPageRoute(builder: (context) => new ScreenNewSession()));
    refreshSession(newSession);
  }

  void refreshSession(session) {
    setState(() {
      sessionList.add(session);
      sessionRows.add(
        new ListTile(
          leading: new Column(children: <Widget>[
            new Text("APR", textAlign: TextAlign.center, style: new TextStyle(color: Colors.red)),
            new Text("10", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline),
          ]),
          title: new Text(session.name, style: Theme.of(context).textTheme.subhead),
          subtitle: new Text("Learn how to future-proof your savings through investing", style: new TextStyle(color: Colors.grey)),
        ),
      );
      print("sessions added" + session.name);
    });
  }

  void handleRadioValueChanged(bool value) {
    setState(() {
      radioPrivacy = value;
    });
  }

  void handleEventTypeChanged(bool value) {
    setState(() {
      radioMultipleEvent = value;
    });
  }

  void _validateEvent() {
    final FormState form = _formKey.currentState;
//    newEvent.fromdate = _fromDate;
//    newEvent.todate = _toDate;
    newEvent.public = radioPrivacy;
    newEvent.banner = _imagesource.toString();
    print(_toDate);
    form.save();
    Navigator.of(context).pop(newEvent);
  }

  @override
  Widget build(BuildContext context) {
    RaisedButton toshow = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Publish event'),
      onPressed: _validateEvent,
    );

    return new Theme(
      data: new ThemeData(),
      child: new Scaffold(
        bottomNavigationBar: new BottomAppBar(
          color: Colors.white,
          child: new Container(
            padding: const EdgeInsets.all(16.0),
            child: toshow,
          ),
        ),
        appBar: new AppBar(
          title: const Text("Create a new event"),
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
                    "Event title",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Input the name of the event here',
                    border: const OutlineInputBorder(),
                  ),
                  onSaved: (String value) {
                    newEvent.name = value;
                  },
                ),
                new Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(top: 64.0, bottom: 4.0),
                  child: new Text(
                    "Date of event",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                new DateTimePicker(
                  labelText: 'From',
                  selectedDate: _fromDate,
                  selectedTime: _fromTime,
                  selectDate: (DateTime date) {
                    setState(() {
                      _fromDate = date;
                    });
                  },
                  selectTime: (TimeOfDay time) {
                    setState(() {
                      _fromTime = time;
                    });
                  },
                ),
                new DateTimePicker(
                  labelText: 'From',
                  selectedDate: _toDate,
                  selectedTime: _toTime,
                  selectDate: (DateTime date) {
                    setState(() {
                      _toDate = date;
                    });
                  },
                  selectTime: (TimeOfDay time) {
                    setState(() {
                      _toTime = time;
                    });
                  },
                ),
                new Container(
                  padding: const EdgeInsets.only(top: 64.0, bottom: 4.0),
                  alignment: Alignment.topLeft,
                  child: new Text(
                    "Time of event",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                new Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                  new Radio<bool>(value: false, groupValue: radioMultipleEvent, onChanged: handleEventTypeChanged),
                  new Expanded(
                      child: new Text(
                    "Single session",
                    style: Theme.of(context).textTheme.subhead,
                  )),
                  new Radio<bool>(value: true, groupValue: radioMultipleEvent, onChanged: handleEventTypeChanged),
                  new Expanded(
                      child: new Text(
                    "Multiple sessions",
                    style: Theme.of(context).textTheme.subhead,
                  )),
                ]),
                new Column(
                  children: sessionRows,
                ),
                new Container(
                  alignment: Alignment.topRight,
                  child: new FlatButton(
                    child: const Text('Add more'),
                    textColor: Colors.blue.shade400,
                    onPressed: _showNewSessionForm,
                  ),
                ),
                new Container(
                  padding: const EdgeInsets.only(top: 64.0, bottom: 4.0),
                  alignment: Alignment.topLeft,
                  child: new Text(
                    "Event privacy",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                new Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                  new Radio<bool>(value: false, groupValue: radioPrivacy, onChanged: handleRadioValueChanged),
                  new Expanded(
                      child: new Text(
                    "Private",
                    style: Theme.of(context).textTheme.subhead,
                  )),
                  new Expanded(child: new Text("")),
                  new Radio<bool>(value: true, groupValue: radioPrivacy, onChanged: handleRadioValueChanged),
                  new Expanded(
                      child: new Text(
                    "Public",
                    style: Theme.of(context).textTheme.subhead,
                  )),
                ]),
                new Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(top: 64.0, bottom: 4.0),
                  child: new Text(
                    "Venue",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'i.e. The Globe Tower',
                    border: const OutlineInputBorder(),
                  ),
                  onSaved: (String value) {
                    newEvent.venue = value;
                  },
                ),
                new Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: new Text(
                    "",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'i.e. 16F',
                    border: const OutlineInputBorder(),
                  ),
                  onSaved: (String value) {
                    newEvent.venueSpec = value;
                  },
                ),
                new Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(top: 64.0, bottom: 4.0),
                  child: new Text(
                    "Short summary",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'A short event blurb',
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onSaved: (String value) {
                    newEvent.brief = value;
                  },
                ),
                new Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(top: 64.0, bottom: 4.0),
                  child: new Text(
                    "Full summary",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'The full description, write away',
                    border: const OutlineInputBorder(),
                  ),
                  onSaved: (String value) {
                    newEvent.description = value;
                  },
                  maxLines: 5,
                ),
                new Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(top: 64.0, bottom: 4.0),
                  child: new Text(
                    "Event photo",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                new TextFormField(
                  initialValue: _imagesource,
                  decoration: const InputDecoration(
                    hintText: 'URL of the banner or upload your own',
                    border: const OutlineInputBorder(),
                  ),
                ),
                new Container(
                  alignment: Alignment.topLeft,
                  child: new FlatButton(
                    child: const Text('Add event photo'),
                    textColor: Colors.blue.shade400,
                    onPressed: _uploadImage,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
