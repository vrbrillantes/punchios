import 'model_date.dart';
class ItemFeedbackResponse {
  String question;
  String answer;

  ItemFeedbackResponse.create(this.question, this.answer);
}
class ItemFeedback {
  String key;
  String question;
  String type;
  List<Choice> choiceList = <Choice>[];

  ItemFeedback.fromJson(this.key, Map data) {
    void iterateChoices(kk, value) {
      choiceList.insert(choiceList.length, new Choice.fromJson(kk, value));
    }
    question = data['Q'];
    type = data['T'];
    if(data['Choices'] != null) data['Choices'].forEach(iterateChoices);
  }
  ItemFeedback.create(this.question, this.type);
}
class Choice {
  final String key;
  String choice;

  Choice.fromJson(this.key, String data) {
    choice = data;
  }
}
class ItemEventFeedback {
  final String key;
  String name;
  ItemDate time;
  List<ItemFeedbackResponse> feedbackList = <ItemFeedbackResponse>[];

  ItemEventFeedback.fromJson(this.key, Map value) {
    void iterateFeedback(v) {
      feedbackList.add(ItemFeedbackResponse.create(v['Q'], v['A']));
    }
    name = value['Name'];
    time = ItemDate.initDate(value['Time']);
    value['Feedback'].forEach(iterateFeedback);
  }
}

class ListEventFeedback {
  final String key;
  List<ItemEventFeedback> eventFeedbackList = <ItemEventFeedback>[];

  ListEventFeedback.fromJson(this.key, Map data) {
    void iterateMapEntry(k, v) {
      eventFeedbackList.insert(eventFeedbackList.length, new ItemEventFeedback.fromJson(k, v));
    }
    data.forEach(iterateMapEntry);
//    eventFeedbackList.sort((x, y) => x.time.millis.compareTo(y.time.millis));
  }
}