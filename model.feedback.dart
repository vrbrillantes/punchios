import 'controller.participation.dart';
class FeedbackQuestions {
  FeedbackQuestions.fromFirebase(String eventID, void feedbackRetrieved(List<FeedbackQuestion> qq)) {
    FeedbackPresenter.getFeedback(eventID, (Map data) {
      parseFeedback(data);
      feedbackRetrieved(parseFeedback(data));
    });
  }

  FeedbackQuestions.forSessionsfromFirebase(String eventID, void feedbackRetrieved(List<FeedbackQuestion> qq)) {
    FeedbackPresenter.getFeedbackSessions(eventID, (Map data) {
      parseFeedback(data);
      feedbackRetrieved(parseFeedback(data));
    });
  }
  FeedbackQuestions.forWorkshopsFromFirebase(String eventID, void feedbackRetrieved(List<FeedbackQuestion> qq)) {
    FeedbackPresenter.getFeedbackWorkshops(eventID, (Map data) {
      parseFeedback(data);
      feedbackRetrieved(parseFeedback(data));
    });
  }

  List<FeedbackQuestion> parseFeedback(Map data) {
    List<FeedbackQuestion> questionList = <FeedbackQuestion>[];
    int questionOrder = 0;
    data.forEach((k, v) {
      questionList.add(FeedbackQuestion.fromFirebase(k, v, questionOrder));
      questionOrder++;
    });
    return questionList;
  }
}

class FeedbackQuestion {
  int questionOrder;
  final String key;
  String question;
  String type;
  String longType;
  List<String> choices = <String>[];
  Map<String, bool> boolChoices = {};

  FeedbackQuestion.submitButton(this.key) {
    type = "SB";
  }

  FeedbackQuestion.fromFirebase(this.key, Map data, int qo) {
    question = data['Q'];
    type = data['T'];
    questionOrder = data['I'] != null ? data['I'] : qo;
    switch (type) {
      case "R":
        longType = "Rating";
        break;
      case "F":
        longType = "Feedback";
        break;
      case "YN":
        choices = [
          "Yes",
          "No",
        ];
        longType = "Yes/No";
        break;
      case "AS":
        choices = [
          "Strongly Agree",
          "Agree",
          "Neutral",
          "Disagree",
          "Strongly Disagree",
        ];
        longType = "Agree Scale";
        break;
      case "RS":
        choices = [
          "Will recommend",
          "Likely to recommended",
          "Will neither recommend nor discourage",
          "Likely to discourage",
          "Will discourage",
        ];
        longType = "Recommend Scale";
        break;
      case "UYS":
        choices = [
          "Wonderful",
          "Surprising",
          "Desired",
          "Expected",
          "Basic",
          "Criminal",
        ];
        longType = "UYS";
        break;
      case "P":
        longType = "Poll";
        parseChoices(data['Choices']);
        break;
      case "MS":
        longType = "Multiple Selection";
        parseChoices(data['Choices']);
        break;
//      case "RK":
//        longType = "Ranking";
//        break;
    }
  }

  void parseChoices(List<dynamic> choiceList) {
    choiceList.forEach((dynamic s) {
      choices.add(s.toString());
    });

    choices.forEach((String s) {
      boolChoices[s] = false;
    });
  }
}
