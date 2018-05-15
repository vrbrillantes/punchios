import 'model_question.dart';
import 'model_date.dart';

class ItemSession {
  final String key;
  String name;
  ItemDate starttime;
  ItemDate endtime;
  String slot;
  String eventID;
  List<Question> questionlist = <Question>[];

  ItemSession.fromJson(this.key, Map data) {
    void iterateQuestions(key, value) {
      questionlist.insert(questionlist.length, new Question.fromJson(key, value));
    }

    name = data['Name'];
    starttime = ItemDate.initDate(data['TimeStart']);
    endtime = ItemDate.initDate(data['TimeEnd']);
    eventID = data['EventID'];
    slot = data['Slot'];

    if(data['Questions'] != null) data['Questions'].forEach(iterateQuestions);
  }
  ItemSession.newSession(this.key, String name) {
    this.name = name;
  }
}

class ListSession {
  final String key;
  List<ItemSession> sessionList = <ItemSession>[];

  ListSession.fromJson(this.key, Map data) {
    void iterateMapEntry(key, value) {
      sessionList.insert(sessionList.length, new ItemSession.fromJson(key, value));
    }
    data.forEach(iterateMapEntry);
  }
}