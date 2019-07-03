import 'util.firebase.dart';
import 'dart:async';
import 'model.profile.dart';
import 'model.participation.dart';

class ParticipationPresenter {
  static void setEventAttendeeFeedback(String eventID, String userID, String name, List<dynamic> responseMap, void feedbackSubmitted()) {
    Map data = {'Feedback': responseMap, 'UserID': userID, 'FeedbackKey': eventID, 'Name': name, 'Time': DateTime.now().toString()};
    if (userID != null) FirebaseMethods.setFeedbackAnswers(eventID, userID, data, feedbackSubmitted);
  }

  static void setSessionAttendeeFeedback(String eventID, String sessionID, String userID, String name, List<dynamic> responseMap, void feedbackSubmitted()) {
    Map data = {'Feedback': responseMap, 'UserID': userID, 'FeedbackKey': eventID, 'Name': name, 'Time': DateTime.now().toString()};
    if (userID != null) FirebaseMethods.setSessionFeedbackAnswers(eventID, sessionID, userID, data, feedbackSubmitted);
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
  Map<String, Question> eventQuestions = {};

  EventParticipation({this.profile, this.eventID, this.sessionID});

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