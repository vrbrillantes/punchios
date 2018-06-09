import 'model_feedback.dart';
import 'model_date.dart';
import 'model_eventdetail.dart';
import 'util_account.dart';
import 'package:googleapis/calendar/v3.dart';

class ItemEvent {
  final String key;
  String gCalID;
  ItemEventDetails event;

  List<ItemFeedback> questionlist = <ItemFeedback>[];
  Map<String, String> collaborators = {};
  List<String> collabList = <String>[];
  Map<String, Map<String, String>> feedbackQuestions = {};
  Event gCal;

  String venueSpec;
  String brief;
  String creator;
  String banner;
  bool public;

  ItemEvent.fromJson(this.key, Map data) {
    void iterateQuestions(key, value) {
      questionlist.insert(questionlist.length, new ItemFeedback.fromJson(key, value));
      //TODO return key
    }
    void addCollab(key, value) {
      collaborators[key] = value;
      collabList.add(value);
    }

    event = ItemEventDetails.newItem(
        this.key, data['Name'], ItemDate.initDate(data['StartDate']), ItemDate.initDate(data['EndDate']), data['Description'], data['Venue']);

    creator = data['Creator'];
    venueSpec = data['VenueSpec'] + " ";
    brief = data['Brief'] + " ";
    public = data['Public'];
    banner = data['Banner'];
    gCalID = data['GCalID'];

    if(data['Questions'] != null) data['Questions'].forEach(iterateQuestions);
    if(data['Collaborators'] != null) data['Collaborators'].forEach(addCollab);
  }

  ItemEvent.newEvent(this.key);
//  ItemEvent.createEvent(this.key, Event e) {
//    event = ItemEventDetails.newItem(
//        this.key, e.summary, new ItemDate.initDT(e.start.dateTime), new ItemDate.initDT(e.end.dateTime), e.description, e.location);
//
//    creator = 'vcbrillantesglobecomph';
//    venueSpec = '';
//    brief = 'br';
//    public = false;
//    banner = "https://firebasestorage.googleapis.com/v0/b/globe-isg-punch.appspot.com/o/image_97311.jpg?alt=media&token=85b0deff-7d7a-4fd7-9d7b-a50e2f7ebbfd";
//
//  }
}
class Collaborators {
  Map<String, String> collaborators = {};
  Collaborators.fromList(List<String> data) {
    void getList(s) {
      collaborators[AccountUtils.getUserKey(s)] = s;
    }
    data.forEach(getList);
  }
}class FeedbackQuestions {
  Map<String, Map<String, String>> feedbackQuestions = {};
  FeedbackQuestions.fromList(List<ItemFeedback> data) {
    void getList(s) {
//      Map<String, String> feedback = ;
      feedbackQuestions[s.key] = {'Q': s.question, 'T': s.type};
    }
    data.forEach(getList);
  }
}
class ListEvent {
  final String key;
  List<ItemEvent> eventList = <ItemEvent>[];

  ListEvent.fromJson(this.key, Map data) {
    void iterateMapEntry(key, value) {
      ItemEvent thisEvent = new ItemEvent.fromJson(key, value);
      eventList.insert(eventList.length, thisEvent);
    }
    data.forEach(iterateMapEntry);
    eventList.sort((x, y) => x.event.start.millis.compareTo(y.event.start.millis));

  }

  ListEvent.appendFromJson(this.eventList, this.key, Map data) {
    void iterateMapEntry(key, value) {
      eventList.insert(eventList.length, new ItemEvent.fromJson(key, value));
    }
    data.forEach(iterateMapEntry);
  }
}
class ListEventAttendees {
  final String eventID;
  List<String> attendeeList = <String>[];
  List<String> confirmedAttendees = <String>[];
  ListEventAttendees.fromJson(this.eventID, Map data) {
    void iterateMapEntry(key, value) {
      if (value['Status'] != null && value['Status']) confirmedAttendees.insert(confirmedAttendees.length, key);
      attendeeList.insert(attendeeList.length, key);
    }
    data.forEach(iterateMapEntry);
  }


}