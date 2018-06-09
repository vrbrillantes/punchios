import 'model_feedback.dart';
import 'model_date.dart';
import 'model_eventdetail.dart';

class ItemSession {
  final String key;
  ItemEventDetails session;

  List<ItemFeedback> questionlist = <ItemFeedback>[];
  String slot;
  String eventID;
  String maxPax;

  ItemSession.fromJson(this.key, Map data) {
    void iterateQuestions(key, value) {
      questionlist.insert(questionlist.length, new ItemFeedback.fromJson(key, value));
//      questionlist.insert(questionlist.length, new ItemFeedback.fromJson(key, value));
      //TODO return key
    }

    session = ItemEventDetails.newItem(
        this.key, data['Name'], ItemDate.initDate(data['TimeStart']), ItemDate.initDate(data['TimeEnd']), data['Description'], data['Venue']);
    eventID = data['EventID'];
    slot = data['Slot'];

    if (data['Questions'] != null) data['Questions'].forEach(iterateQuestions);
  }

  ItemSession.newSession(this.key);
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
