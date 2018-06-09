import 'package:flutter/material.dart';
import 'model_session.dart';
import 'ui_datetimepicker.dart';
import 'model_date.dart';

class ScreenNewSession extends StatelessWidget {
  ScreenNewSession({this.from, this.to, this.slots});

  final DateTime from;
  final DateTime to;
  final List<String> slots;

  @override
  Widget build(BuildContext context) {
    return new ScreenNewSessionState(
      from: from,
      to: to,
      slots: slots,
    );
  }
}

class ScreenNewSessionState extends StatefulWidget {
  ScreenNewSessionState({this.from, this.to, this.slots});

  final DateTime from;
  final DateTime to;
  final List<String> slots;

  @override
  _ScreenNewSessionBuild createState() => new _ScreenNewSessionBuild(from: from, to: to, slots: slots);
}

class _ScreenNewSessionBuild extends State<ScreenNewSessionState> {
  _ScreenNewSessionBuild({this.from, this.to, this.slots});

  final DateTime from;
  final DateTime to;
  String chosenSlot;
  final List<String> slots;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  ItemSession newSession;
  DateTime _eventDay = new DateTime.now();
  TimeOfDay _fromTime = const TimeOfDay(hour: 8, minute: 00);
  TimeOfDay _toTime = const TimeOfDay(hour: 9, minute: 00);

  void _validateSession() {
    final FormState form = _formKey.currentState;
    form.save();
    newSession.slot = chosenSlot;
    newSession.session.start = ItemDate.initDateTime(_eventDay.toString(), _fromTime);
    newSession.session.end = ItemDate.initDateTime(_eventDay.toString(), _toTime);
    Navigator.of(context).pop(newSession);
  }

  @override
  void initState() {
    newSession = ItemSession.newSession("NEW");
    super.initState();
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
              child: const Text('Create new session'),
              onPressed: _validateSession,
            ),
          ),
        ),
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
                    newSession.session.name = value;
                  },
                ),
                new DropdownButton(
                  value: chosenSlot,
                  onChanged: (String newValue) {
                    setState(() {
                      chosenSlot = newValue;
                    });
                  },
                  items: slots.map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
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
                    newSession.session.description = value;
                  },
                ),
                new Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(top: 32.0, bottom: 4.0),
                  child: new Text(
                    "Venue",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                new TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'i.e. B1 Dance',
                    border: const OutlineInputBorder(),
                  ),
                  onSaved: (String value) {
                    newSession.session.venue = value;
                  },
                ),
                new Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(top: 32.0, bottom: 4.0),
                  child: new Text(
                    "Max Attendees",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                new TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '0 if unlimited',
                    border: const OutlineInputBorder(),
                  ),
                  onSaved: (String value) {
                    newSession.maxPax = value;
                  },
                ),
                new Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(top: 64.0, bottom: 4.0),
                  child: new Text(
                    "Date of session",
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                new DateTimePicker(
                  labelText: 'From',
                  firstDate: from,
                  lastDate: to,
                  selectedDate: _eventDay,
                  selectedTime: _fromTime,
                  selectDate: (DateTime date) {
                    setState(() {
                      _eventDay = date;
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
                  firstDate: from,
                  lastDate: to,
                  selectedDate: _eventDay,
                  selectedTime: _toTime,
                  selectDate: (DateTime date) {
                    setState(() {
                      _eventDay = date;
                    });
                  },
                  selectTime: (TimeOfDay time) {
                    setState(() {
                      _toTime = time;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
