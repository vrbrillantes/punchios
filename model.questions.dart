

//class Question {
//  String name;
//  String question;
//  String userID;
//  String key;
//  int votes = 0;
//
//  Question.retrieveQuestion(this.key, Map data) {
//    name = data['Name'];
//    userID = data['UserID'];
//    question = data['Question'] != null ? data['Question'] : "";
//  }
//}

//class EventQuestions {
//  final Profile profile;
//  final String eventID;
//  final String sessionID;
//  Map<String, Question> eventQuestions = {};
//
//  EventQuestions({this.profile, this.eventID, this.sessionID});
//
//  void voteQuestion(String questionid, String userid, void done()) {
//    QuestionPresenter.setVote(eventID, sessionID, questionid, userid, done);
//  }
//
//  void getQuestions(void onData(Map<String, Question> questions), void returnSS(StreamSubscription s)) {
//    QuestionPresenter.getQuestions(eventID, sessionID, (Map data) {
//      readQuestions(data);
//      onData(eventQuestions);
//    }, returnSS);
//  }
//
//  void readQuestions(Map data) {
//    if (data != null) {
//      data.forEach((k, v) {
//        eventQuestions[k] = Question.retrieveQuestion(k, v);
//        eventQuestions[k].votes = v['Votes'] == null ? 0 : readVotes(v['Votes']);
//      });
//    }
//  }
//
//  int readVotes(Map data) {
//    List<String> votes = <String>[];
//    data.forEach((s, ss) {
//      votes.add(s);
//    });
//    return votes.length;
//  }
//
//  void askQuestion({String question, String sessionID, void questionSubmitted()}) {
//    QuestionPresenter.setEventQuestion(eventID, sessionID, profile.profileLogin.userKey, profile.name, question, questionSubmitted);
//  }
//}
