import 'package:flutter/material.dart';
import 'model.attendance.dart';
import 'ui.util.dart';
import 'ui.buttons.dart';

class EventActions extends StatelessWidget {
  EventActions({
    this.myAttendance,
    this.isCollaborator,
    this.isUpdated = true,
    this.actionPressed,
    this.editing,
  });

  final Attendance myAttendance;
  final bool isUpdated;
  final bool isCollaborator;
  final bool editing;

  final Function(String) actionPressed;

  @override
  Widget build(BuildContext context) {
    PunchRaisedButton registerButton = PunchRaisedButton(label: 'Register to this event', action: () => actionPressed("register"));
    PunchRaisedButton adminButton = PunchRaisedButton(label: 'Admin actions', action: () => actionPressed("admin"));
    PunchRaisedButton editingButton = PunchRaisedButton(label: 'Save changes', action: () => actionPressed("doneEditing"));
    PunchRaisedButton checkoutButton = PunchRaisedButton(label: 'Checkout', action: () => actionPressed("checkout"));

    if (editing) {
      return editingButton;
    } else if (!isUpdated) {
      return SizedBox();
    } else if (isCollaborator) {
      return adminButton;
    } else if (myAttendance != null) {
      if (myAttendance.checkedOut) {
        return SizedBox();
      } else {
        if (myAttendance.hasFeedback) {
          return checkoutButton;
        } else if (myAttendance.checkedIn) {
          return SizedBox();
        } else if (!myAttendance.isFinished && !myAttendance.registered) {
          return registerButton;
        } else {
          return SizedBox();
        }
      }
    } else {
      return SizedBox();
    }
  }
}

class EventActions2 extends StatelessWidget {
  EventActions2({
    this.isOnline,
    this.myAttendance,
    this.actionPressed,
  });

  final Attendance myAttendance;
  final bool isOnline;

  final Function(String) actionPressed;

  @override
  Widget build(BuildContext context) {
    PunchRaisedButton feedbackButton = PunchRaisedButton(label: 'Send feedback', action: () => actionPressed("feedback"));
    PunchRaisedButton questionButton = PunchRaisedButton(label: 'Ask question', action: () => actionPressed("question"));
    PunchRaisedButton checkinButton = PunchRaisedButton(label: 'Check-in', action: () => actionPressed("checkin"));
    PunchOutlineButton cancelButton = PunchOutlineButton(label: "Opt-out of event", action: () => actionPressed("cancel"));

    Widget button1 = SizedBox();
    Widget button2 = SizedBox();

    if (myAttendance != null) {
      if (myAttendance.checkedIn) {
        if (myAttendance.isQuestionTime) button1 = questionButton;
        if (myAttendance.isFeedbackTime && !myAttendance.hasFeedback) button2 = feedbackButton;
      } else {
        if (!myAttendance.isFinished && myAttendance.registered) button1 = checkinButton;
        if (!myAttendance.isFinished && myAttendance.registered && isOnline) button2 = cancelButton;
      }
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          switch (index) {
            case 0:
              return button1;
            case 1:
              return button2;
            case 2:
              return SizedBox(height: 100);
          }
          return null;
        },
        childCount: 3,
      ),
    );
  }
}

class CollabList extends StatelessWidget {
  CollabList({this.collabs, this.onAdd, this.onDelete});

  final List<String> collabs;
  final VoidCallback onAdd;
  final Function(String) onDelete;

  final String submitString = "SUBMITBUTTONTRIGGER";

  @override
  Widget build(BuildContext context) {
    if (!collabs.contains(submitString)) collabs.add(submitString);
    return ListView(
      children: collabs.map<Widget>((String s) {
        return s == submitString
            ? PunchRaisedButton(
                label: "Add new",
                action: () {
                  Navigator.pop(context);
                  onAdd();
                })
            : ListTile(
                title: Text(s, style: AppTextStyles.textForm),
                trailing: IconButton(
                    icon: Icon(Icons.cancel, color: AppColors.appColorRed),
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete(s);
                    }),
              );
      }).toList(),
    );
  }
}

class CheckedInList extends StatelessWidget {
  CheckedInList({this.collabs});

  final List<String> collabs;

  final String submitString = "SUBMITBUTTONTRIGGER";

  @override
  Widget build(BuildContext context) {
    if (!collabs.contains(submitString)) collabs.add(submitString);
    return ListView(
      children: collabs.map<Widget>((String s) {
        return s == submitString
            ? SizedBox()
            : ListTile(
                title: Text(s, style: AppTextStyles.textForm),
              );
      }).toList(),
    );
  }
}

class AdminButtons extends StatelessWidget {
  AdminButtons({this.onPress, this.myAttendance});

  final Attendance myAttendance;

//  final bool isCreator;
  final Function(String) onPress;

  @override
  Widget build(BuildContext context) {
    List<TableRow> actions = <TableRow>[];
    actions.add(TableRow(children: <Widget>[
      AdminActionButtons('No action', Icons.do_not_disturb, onPressed: null),
      AdminActionButtons('Collab', Icons.people, onPressed: () => onPress('collab')),
      AdminActionButtons('Notif', Icons.notifications, onPressed: () => onPress('notif')),
    ]));
    actions.add(TableRow(children: <Widget>[
      AdminActionButtons('Scan', Icons.camera_enhance, onPressed: () => onPress('scan')),
      myAttendance != null
          ? (myAttendance.registered
              ? (myAttendance.checkedIn
                  ? AdminActionButtons('Ask', Icons.question_answer, onPressed: () => onPress('question'))
                  : AdminActionButtons('Check-in', Icons.event_available, onPressed: () => onPress('checkin')))
              : AdminActionButtons('Register', Icons.event_note, onPressed: () => onPress('register')))
          : AdminActionButtons('Loading', Icons.watch_later, onPressed: () {}),
      AdminActionButtons(myAttendance != null ? 'Feedback' : 'Loading', myAttendance != null ? Icons.chat_bubble : Icons.check,
          onPressed: () => onPress('feedback')),
//      isCreator
//          ? AdminActionButtons('Feedback', Icons.chat_bubble, onPressed: () => onPress('feedback'))
//          : AdminActionButtons(myAttendance != null ? 'Feedback' : 'Loading', myAttendance != null ? Icons.chat_bubble : Icons.check,
//              onPressed: () => myAttendance.isFeedbackTime ? onPress('feedback') : onPress('noFB')),
    ]));
    return Table(
      children: actions,
    );
  }
}

class EventStatus extends StatelessWidget {
  EventStatus({this.myAttendance, this.isUpdated = true});

  final Attendance myAttendance;

//  final bool editing;
  final bool isUpdated;

  @override
  Widget build(BuildContext context) {
    Widget attendanceLabel = SizedBox();

    LabelListTile updateLabel = LabelListTile(label: "Update App");
    LabelListTile concludedLabel = LabelListTile(label: "Event has ended");
    LabelListTile checkedinLabel = LabelListTile(label: "You're checked-in");
    LabelListTile registeredLabel = LabelListTile(label: "You're registered");

//    LabelListTile editingLabel = LabelListTile(label: "You're in edit mode");
//    if (editing) {
//      attendanceLabel = editingLabel;
//    } else if (!isUpdated) {

    if (!isUpdated) {
      attendanceLabel = updateLabel;
    } else if (myAttendance != null) {
      if (myAttendance.isFinished == true) {
        attendanceLabel = concludedLabel;
      } else if (myAttendance.checkedIn) {
        attendanceLabel = checkedinLabel;
      } else if (myAttendance.registered) {
        attendanceLabel = registeredLabel;
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              attendanceLabel,
            ],
          ),
        )
      ],
    );
  }
}
