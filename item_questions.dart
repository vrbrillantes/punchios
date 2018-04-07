class Question {
  final String key;
  String question;
  bool status;
  String type;

  Question.fromJson(this.key, Map data) {
    question = data['Q'];
    status = data['S'];
    type = data['T'];
  }
}