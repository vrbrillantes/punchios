import 'util.firebase.dart';
import 'dart:async';
import 'model.events.dart';
import 'model.session.dart';
import 'model.profile.dart';
import 'model.participation.dart';
import 'package:flutter/material.dart';
import 'util.dialog.dart';
import 'screen.feedback.dart';
import 'screen.questions.dart';
class QuestionPresenter {
  static void getQuestions(String eid, String sid, void done(Map data), void returnSS(StreamSubscription s)) {
    FirebaseMethods.getEventQuestionsByEventIDRefresh(eid, sid, done).then(returnSS);
  }

  static void setEventQuestion(String eventID, String sessionID, String userID, String name, String question, void questionSubmitted()) {
    FirebaseMethods.setEventQuestion(
      eventID,
      sessionID,
      {
        'Name': name,
        'UserID': userID,
        'Photo': "",
        "Question": question,
        "QuestionKey": eventID,
        "Time": DateTime.now().toString(),
      },
      questionSubmitted,
    );
  }

  static void setVote(String eventID, String sessionID, String questionID, String userID, void done()) {
    FirebaseMethods.setQuestionVoteByUserKey(eventID, sessionID, questionID, userID, done);
  }
}
class FeedbackPresenter {
  static void getFeedback(String eventID, void feedbackRetrieved(Map data)) {
    FirebaseMethods.getFeedbackQuestionsByEventID(eventID, (Map data) {
      if (data != null) feedbackRetrieved(data);
    });
  }

  static void getFeedbackSessions(String eventID, void feedbackRetrieved(Map data)) {
    FirebaseMethods.getSessionFeedbackQuestionsByEventID(eventID, (Map data) {
      if (data != null) feedbackRetrieved(data);
    });
  }
  static void getFeedbackWorkshops(String eventID, void feedbackRetrieved(Map data)) {
    FirebaseMethods.getWorkshopFeedbackQuestionsByEventID(eventID, (Map data) {
      if (data != null) feedbackRetrieved(data);
    });
  }
}
class ParticipationPresenter {
  static void setEventAttendeeFeedback(String eventID, String userID, String name, List<dynamic> responseMap, void feedbackSubmitted()) {
    Map data = {'Feedback': responseMap, 'UserID': userID, 'FeedbackKey': eventID, 'Name': name, 'Time': DateTime.now().toString()};
    if (userID != null) FirebaseMethods.setFeedbackAnswers(eventID, userID, data, feedbackSubmitted);
  }

  static void setSessionAttendeeFeedback(String eventID, String sessionID, String userID, String name, List<dynamic> responseMap, void feedbackSubmitted()) {
    Map data = {'Feedback': responseMap, 'UserID': userID, 'FeedbackKey': eventID, 'Name': name, 'Time': DateTime.now().toString()};
    if (userID != null) FirebaseMethods.setSessionFeedbackAnswers(eventID, sessionID, userID, data, feedbackSubmitted);
  }
  static void setWorkshopAttendeeFeedback(String eventID, String workshopID, String userID, String name, List<dynamic> responseMap, void feedbackSubmitted()) {
    Map data = {'Feedback': responseMap, 'UserID': userID, 'FeedbackKey': eventID, 'Name': name, 'Time': DateTime.now().toString()};
    if (userID != null) FirebaseMethods.setWorkshopFeedbackAnswers(eventID, workshopID, userID, data, feedbackSubmitted);
  }

  static void setKioskQuestion(String refID, String name, String question) {
    FirebaseMethods.setKioskQuestion(refID, {'Question': question, 'Name': name});
  }

  static void getQuestions(String eid, String sid, void done(Map data), void returnSS(StreamSubscription s)) {
    FirebaseMethods.getEventQuestionsByEventIDRefresh(eid, sid, done).then(returnSS);
  }

  static void setEventQuestion(String eventID, String sessionID, String userID, String name, String question, void questionSubmitted()) {
    Map data = {'Name': name, 'UserID': userID, 'Photo': "", "Question": question, "QuestionKey": eventID, "Time": DateTime.now().toString()};
    FirebaseMethods.setEventQuestion(eventID, sessionID, data, questionSubmitted);
  }

  static void setVote(String eventID, String sessionID, String questionID, String userID, void done()) {
    if (userID != null) FirebaseMethods.setQuestionVoteByUserKey(eventID, sessionID, questionID, userID, done);
  }
}

class EventParticipation {
  final Profile profile;
  final String eventID;
  final String sessionID;
  final String workshopID;
  Map<String, Question> eventQuestions = {};

  EventParticipation({this.profile, this.eventID, this.sessionID, this.workshopID});

  void voteQuestion(String questionid, String userid, void done()) {
    ParticipationPresenter.setVote(eventID, sessionID, questionid, userid, done);
  }

  void setKioskQuestion(String questionID) {
    Question thisQuestion = eventQuestions[questionID];
    ParticipationPresenter.setKioskQuestion(sessionID == null ? eventID : sessionID, thisQuestion.name, thisQuestion.question);
  }

  void getQuestions(void onData(Map<String, Question> questions), void returnSS(StreamSubscription s)) {
    ParticipationPresenter.getQuestions(eventID, sessionID, (Map data) {
      readQuestions(data);
      onData(eventQuestions);
    }, returnSS);
  }

  void sendFeedback(List<Response> feedback, void feedbackSubmitted()) {
    List<dynamic> responseMap = <dynamic>[];
    feedback.forEach((Response r) => responseMap.add(r.responseMap));
    ParticipationPresenter.setEventAttendeeFeedback(eventID, profile.profileLogin.userKey, profile.name, feedback, feedbackSubmitted);
  }

  void sendSessionFeedback(List<Response> feedback, void feedbackSubmitted()) {
    List<dynamic> responseMap = <dynamic>[];
    feedback.forEach((Response r) => responseMap.add(r.responseMap));
    ParticipationPresenter.setSessionAttendeeFeedback(eventID, sessionID, profile.profileLogin.userKey, profile.name, feedback, feedbackSubmitted);
  }
  void sendWorkshopFeedback(List<Response> feedback, void feedbackSubmitted()) {
    List<dynamic> responseMap = <dynamic>[];
    feedback.forEach((Response r) => responseMap.add(r.responseMap));
    ParticipationPresenter.setWorkshopAttendeeFeedback(eventID, workshopID, profile.profileLogin.userKey, profile.name, feedback, feedbackSubmitted);
  }

  void readQuestions(Map data) {
    if (data != null) {
      data.forEach((k, v) {
        eventQuestions[k] = Question.retrieveQuestion(k, v);
        eventQuestions[k].votes = v['Votes'] == null ? 0 : readVotes(v['Votes']);
      });
    }
  }

  int readVotes(Map data) {
    List<String> votes = <String>[];
    data.forEach((s, ss) {
      votes.add(s);
    });
    return votes.length;
  }

  void askQuestion({String question, String sessionID, void questionSubmitted()}) {
    ParticipationPresenter.setEventQuestion(eventID, sessionID, profile.profileLogin.userKey, profile.name, question, questionSubmitted);
  }
}

class ParticipationHolder {
  final BuildContext context;
  final Event event;
  Session session;
  Workshop workshop;
  final Profile profile;
  GenericDialogGenerator dialog;

  EventParticipation participation;

  ParticipationHolder(this.context, this.event, this.profile) {
    dialog = GenericDialogGenerator.init(context);

    participation = EventParticipation(eventID: event.eventID, profile: profile);
  }

  ParticipationHolder.session(this.context, this.event, this.session, this.profile) {
    dialog = GenericDialogGenerator.init(context);

    participation = EventParticipation(eventID: event.eventID, sessionID: session.ID, profile: profile);
  }
  ParticipationHolder.workshop(this.context, this.event, this.workshop, this.profile) {
    dialog = GenericDialogGenerator.init(context);

    participation = EventParticipation(eventID: event.eventID, workshopID: workshop.ID, profile: profile);
  }

  void gotoQuestions() {
    Navigator.pushNamed(
      context,
      '/questions',
      arguments: ScreenQuestionAruments(
        profile: profile,
        eventID: event.eventID,
      ),
    );
  }

  void sendFeedbackSession(bool isCollaborator, void feedbackSent()) async {
    List<Response> responseList = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ScreenFeedback(
              editable: isCollaborator,
              eventKey: event.eventID,
              eventName: event.eventDetails.name,
              session: true,
            )));
    if (responseList != null)
      participation.sendSessionFeedback(responseList, () {
        feedbackSent();
        dialog.confirmDialog(dialog.feedbackSubmittedString);
      });
  }

  void sendFeedbackWorkshop(bool isCollaborator, void feedbackSent()) async {
    List<Response> responseList = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ScreenFeedback(
              editable: isCollaborator,
              eventKey: event.eventID,
              eventName: event.eventDetails.name,
              workshop: true,
            )));
    if (responseList != null)
      participation.sendWorkshopFeedback(responseList, () {
        feedbackSent();
        dialog.confirmDialog(dialog.feedbackSubmittedString);
      });
  }

  void sendFeedback(bool isCollaborator, void feedbackSent()) async {
    List<Response> responseList = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ScreenFeedback(
              editable: isCollaborator,
              eventKey: event.eventID,
              eventName: event.eventDetails.name,
            )));
    if (responseList != null)
      participation.sendFeedback(responseList, () {
        feedbackSent();
        dialog.confirmDialog(dialog.feedbackSubmittedString);
      });
  }

}