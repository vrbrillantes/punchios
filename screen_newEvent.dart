import 'dart:async';
import 'package:flutter/material.dart';
import 'model_events.dart';
import 'model_session.dart';
import 'model_eventdetail.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'screen_newSession.dart';
import 'screen_newSlot.dart';
import 'dart:math';
import 'dart:io';
import 'ui_datetimepicker.dart';
import 'model_date.dart';
import 'alert_submitevent.dart';

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
  List<Widget> slotRows = <Widget>[];
  List<String> slots = <String>[];
  ItemEvent newEvent = new ItemEvent.newEvent("event");
  DateTime _fromDate = new DateTime.now();
  DateTime _toDate = new DateTime.now();
  TimeOfDay _fromTime = const TimeOfDay(hour: 8, minute: 00);
  TimeOfDay _toTime = const TimeOfDay(hour: 9, minute: 00);
  CircularProgressIndicator loader;
  final TextEditingController urlController = new TextEditingController();

  bool radioPrivacy = false;

  Future _uploadImage() async {
    setState(() {
      loader = new CircularProgressIndicator();
    });
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    int random = new Random().nextInt(100000);
    StorageReference ref = FirebaseStorage.instance.ref().child("image_$random.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    Uri downloadUrl = (await uploadTask.future).downloadUrl;
    setState(() {
      urlController.text = downloadUrl.toString();
      loader = null;
    });
  }

  Future _showNewSlotForm() async {
    String slot = await Navigator.push(context, new MaterialPageRoute(builder: (context) => new ScreenNewSlot()));
    if (slot != null && slot != "") {
      setState(() {
        slots.add(slot);
        slotRows.add(new Text(slot));
      });
    }
  }


  void handleRadioValueChanged(bool value) {
    setState(() {
      radioPrivacy = value;
    });
  }

  Future _validateEvent() async {
    final FormState form = _formKey.currentState;
    newEvent.event = new ItemEventDetails.init();
    newEvent.event.start = ItemDate.initDateTime(_fromDate.toString(), _fromTime);
    newEvent.event.end = ItemDate.initDateTime(_toDate.toString(), _toTime);
    newEvent.public = radioPrivacy;
    form.save();
    await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new AlertSubmitEvent(
                  newEvent: newEvent,
                  sessionList: sessionList,
                )));
    Navigator.pop(context);
  }

  Future _showNewSessionForm() async {
    if (slots.length > 0) {
      ItemSession newSession = await Navigator.push(
          context, new MaterialPageRoute(builder: (context) => new ScreenNewSession(from: _fromDate, to: _toDate, slots: slots)));
      refreshSession(newSession);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = <Widget>[];
    RaisedButton createEvent = new RaisedButton(
      color: Colors.blue.shade600,
      textColor: Colors.white,
      child: const Text('Publish event'),
      onPressed: _validateEvent,
    );

    buttons.add(new Expanded(child: createEvent));

    return new Theme(
      data: new ThemeData(),
      child: new Scaffold(
        bottomNavigationBar: new BottomAppBar(
          color: Colors.white,
          child: new Container(
            padding: const EdgeInsets.all(16.0),
            child: new Row(children: buttons),
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
                    newEvent.event.name = value;
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
                new Column(
                  children: slotRows,
                ),
                new Container(
                  alignment: Alignment.topRight,
                  child: new FlatButton(
                    child: const Text('Add slot'),
                    textColor: Colors.blue.shade400,
                    onPressed: _showNewSlotForm,
                  ),
                ),
                new Container(
                  padding: const EdgeInsets.only(top: 64.0, bottom: 4.0),
                  alignment: Alignment.topLeft,
                  child: new Text(
                    "Event audience",
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
                    newEvent.event.venue = value;
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
                    newEvent.event.description = value;
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
                  controller: urlController,
                  decoration: const InputDecoration(
                    hintText: 'image url',
                    border: const OutlineInputBorder(),
                  ),
                  onSaved: (String value) {
                    newEvent.banner = value;
                  },
                ),
                new Container(
                  alignment: Alignment.center,
                  child: loader,
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

  void refreshSession(session) {
    setState(() {
      sessionList.add(session);
      sessionRows.add(
        new ListTile(
          leading: new Column(children: <Widget>[
            new Text(session.session.start.shortmonth, textAlign: TextAlign.center, style: new TextStyle(color: Colors.red)),
            new Text(session.session.start.day, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline),
          ]),
          title: new Text(session.session.name, style: Theme.of(context).textTheme.subhead),
        ),
      );
    });
  }
}
