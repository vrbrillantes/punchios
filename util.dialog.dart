import 'package:flutter/material.dart';
import 'ui.util.dart';
import 'ui.buttons.dart';
import 'util.customdialog.dart';
import 'model.notification.dart';

class DialogParameters {
  Widget image;
  String imageNet;
  String description;
  String message;
  String buttonLabel;
  String buttonLabel2;

  DialogParameters.newDialog(
      {this.message,
      this.description,
      String img = "images/success@2x.png",
      this.imageNet,
      this.buttonLabel = "Done"}) {
    image = imageNet == null
        ? Image.asset(img, height: 60)
        : ClipOval(
            clipBehavior: Clip.antiAlias,
            child: Container(
              height: 200,
              child: Image.network(
                imageNet,
                height: 200,
                fit: BoxFit.cover,
              ),
              width: 200,
            ),
          );
  }

  DialogParameters.choiceDialog(
      {this.message,
      this.description,
      this.buttonLabel = "Yes",
      this.buttonLabel2 = "No"});
}

class GenericDialogGenerator {
  GenericDialogGenerator.init(this.buildContext);

  final BuildContext buildContext;

  DialogParameters registeredString(String eventName) {
    return DialogParameters.newDialog(
        message: "Successfully registered to $eventName");
  }

  DialogParameters notificationString(String notif) {
    return DialogParameters.newDialog(message: notif);
  }

  DialogParameters checkedInString(String eventName) {
    return DialogParameters.newDialog(
        message: "Successfully checked-in to $eventName");
  }

  DialogParameters removeInterestString(String eventName) {
    return DialogParameters.choiceDialog(
        message: "Remove $eventName from interested events?");
  }

  DialogParameters sessionWaitingListString(int seq, int slot) {
    return DialogParameters.newDialog(
        message:
            "You are registered to this session but you are on the waiting list.");
  }
  DialogParameters workshopWaitingListString(int seq, int slot) {
    return DialogParameters.newDialog(
        message:
            "You are registered to this workshop but you are on the waiting list.");
  }
  DialogParameters sessionSuccessRegistration(String name) {
    return DialogParameters.newDialog(
        message:
            "You successfully registered to the session, $name");
  }

  DialogParameters workshopSuccessRegistration(String name) {
    return DialogParameters.newDialog(
        message:
            "You successfully registered to the workshop, $name");
  }

  String saveEventString = "Save event for offline?";
  String removeEventString = "Remove event for offline?";

  DialogParameters transferAttendanceString = DialogParameters.choiceDialog(
      message:
          "You are registered to another session. Cancel and register to this one instead?");
  DialogParameters attendanceCancelString = DialogParameters.choiceDialog(
      message: "Aww, are you sure you want to opt-out of this event?",
      buttonLabel: "Continue",
      buttonLabel2: "Back");
  DialogParameters attendSessionString = DialogParameters.choiceDialog(
      message: "Register to this session?", buttonLabel: "Register");
  DialogParameters collabAskRemoveString = DialogParameters.choiceDialog(
      message: "Remove collaborator?", buttonLabel: "Remove");
  DialogParameters interestedEventString =
      DialogParameters.choiceDialog(message: "Interested in this event?");

  DialogParameters currentSession = DialogParameters.newDialog(
      message: "This is the currently selected session");
  DialogParameters sessionNotAllowed = DialogParameters.newDialog(
      message: "You are already checked-in to a session on this time slot");
  DialogParameters attendanceCancelConfirmString = DialogParameters.newDialog(
      message: "You are no longer registered to this event");
  DialogParameters notifSubmittedString = DialogParameters.newDialog(
      message: "Your broadcast message has been sent");
  DialogParameters feedbackSubmittedString =
      DialogParameters.newDialog(message: "Thank you for your feedback");
  DialogParameters feedbackNotAvailable =
      DialogParameters.newDialog(message: "Feedback is not yet available");
  DialogParameters questionSubmittedString =
      DialogParameters.newDialog(message: "Your question has been submitted");
  DialogParameters wrongQRString = DialogParameters.newDialog(
      message: "QR is invalid", img: "images/check-in.png");

  DialogParameters showBadgeString(String message, String imageURL) {
    return DialogParameters.newDialog(message: message, imageNet: imageURL);
  }

  DialogParameters checkedInAttendeeString =
      DialogParameters.newDialog(message: "Successfully scanned attendee");
  DialogParameters checkOutAttendeeString =
      DialogParameters.newDialog(message: "Checked out attendee");
  DialogParameters profileUpdatedString =
      DialogParameters.newDialog(message: "Successfully saved profile");
  DialogParameters collabAddedString =
      DialogParameters.newDialog(message: "Event collaborator added");
  DialogParameters collabRemovedString =
      DialogParameters.newDialog(message: "Event collaborator removed");
  DialogParameters profileCheckDetailsString =
      DialogParameters.newDialog(message: "Check profile information");

  List<String> collabScreen(String eventName) {
    return <String>[
      eventName,
      'Email of collaborator',
      'Please limit to 1 email at a time',
      'Add collaborator',
    ];
  }

  List<String> askQuestionString = <String>[
    'Ask a question',
    'Do you have a question for our speaker?',
    'Enter your question here',
    'Submit',
  ];

  List<String> cancelString(String eventName) {
    return <String>[
      eventName,
      'Can you provide your reason for not attending?',
      'Please provide your reason',
      'Submit',
    ];
  }

  List<String> broadcastString(String eventName) {
    return <String>[
      eventName,
      'What is your message?',
      'Message',
      'Broadcast',
    ];
  }

  void notificationDialog(
      PunchNotification nn, void done(PunchNotification nn)) {
    confirmDialog(notificationString(nn.message), onYes: () => done(nn));
  }

  void notificationListDialog(List<PunchNotification> notList) {
    confirmDialog(
        notificationString("You have ${notList.length} new notifications"));
  }

  void confirmDialog(DialogParameters message, {void onYes()}) {
    void onPressed() {
      Navigator.pop(buildContext);
      onYes();
    }

    showDialog(
      barrierDismissible: false,
      context: buildContext,
      builder: (BuildContext context) {
        return GenericDialog(context, message, onPressed);
      },
    );
  }

  void choiceDialog(DialogParameters message,
      {VoidCallback onYes, VoidCallback onNo}) {
    void onPressed(bool b) {
      Navigator.pop(buildContext);
      b ? onYes() : onNo();
    }

    showDialog(
      barrierDismissible: false,
      context: buildContext,
      builder: (BuildContext context) {
        return GenericChoiceDialog(context, message, onPressed);
      },
    );
  }
}

class GenericDialog extends StatelessWidget {
  GenericDialog(this.context, this.message, this.onPressed);

  final BuildContext context;
  final DialogParameters message;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[message.image],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 26),
              child: Column(children: <Widget>[
                Text(message.message, style: AppTextStyles.eventTitle),
                message.description != null
                    ? SizedBox(height: 16, width: double.infinity)
                    : SizedBox(),
                message.description != null
                    ? Text(message.description,
                        style: AppTextStyles.dialogDescription)
                    : SizedBox(),
              ]),
            ),
            PunchFilledFlatButton(
                action: onPressed, label: message.buttonLabel, padded: false),
          ],
        ),
      ),
    );
  }
}

class GenericChoiceDialog extends StatelessWidget {
  GenericChoiceDialog(this.context, this.message, this.onPressed);

  final void Function(bool) onPressed;
  final BuildContext context;
  final DialogParameters message;

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 26),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(message.message, style: AppTextStyles.eventTitle),
                  ]),
            ),
            PunchFilledFlatButton(
                action: () => onPressed(true),
                label: message.buttonLabel,
                padded: false),
            SizedBox(height: 18),
            PunchOutlineButton(
                action: () => onPressed(false),
                label: message.buttonLabel2,
                padded: false,
                againstWhite: true),
          ],
        ),
      ),
    );
  }
}
