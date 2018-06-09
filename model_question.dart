import 'model_events.dart';
import 'model_profile.dart';
import 'model_session.dart';
import 'model_date.dart';
//class ItemQuestionResponse {
//  String response;
//  ItemQuestion question;
//
//  ItemQuestionResponse.submitResponse(this.response, this.question);
//}
//class ItemQuestion {
//  ItemProfile profile;
//  ItemEvent event;
//  ItemSession session;
//
//  ItemQuestion.createEventQuestion(this.profile, this.event);
//  ItemQuestion.createSessionQuestion(this.profile, this.session);
//}
class ItemEventQuestion {
  final String key;
  String name;
  String eventKey;
  String question;
  String photo;
  ItemDate time;

  ItemEventQuestion.fromJson(this.key, Map value) {
    name = value['Name'];
    question = value['Question'] + "";
    photo = value['Photo'];
    eventKey = value['QuestionKey'];
    time = ItemDate.initDate(value['Time']);
  }
}

class ListEventQuestion {
  final String key;
  List<ItemEventQuestion> eventQuestionList = <ItemEventQuestion>[];

  ListEventQuestion.fromJson(this.key, Map data) {
    void iterateMapEntry(key, value) {
      if (value['Question'] != null) eventQuestionList.insert(eventQuestionList.length, new ItemEventQuestion.fromJson(key, value));
    }
    data.forEach(iterateMapEntry);
    eventQuestionList.sort((x, y) => x.key.compareTo(y.key));
  }
}