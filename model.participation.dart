class Question {
  String name;
  String question;
  String userID;
  String key;
  int votes = 0;
  bool answered;

  Question.retrieveQuestion(this.key, Map data) {
    name = data['Name'];
    userID = data['UserID'];
    question = data['Question'] != null ? data['Question'] : "";
    answered = data['Answered'] != null ? true : false;
  }
}

class Response {
  String question;
  String response;
  Map<String, String> responseMap = {};

  Response.newResponse(this.question, this.response) {
    responseMap = {'Q': question, 'R': response};
  }
}
