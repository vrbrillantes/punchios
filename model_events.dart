import 'model_question.dart';
import 'model_date.dart';
class ItemEvent {
  final String key;
  String name;
  String creator;
  String venue;
  String venueSpec;
  String brief;
  String description;
  ItemDate start;
  ItemDate end;
  String banner;
  bool public;
  List<Question> questionlist = <Question>[];
  Map<String, bool> attendeelist = {};

  ItemEvent.fromJson(this.key, Map data) {
    void iterateQuestions(key, value) {
      questionlist.insert(questionlist.length, new Question.fromJson(key, value));
    }
    void iterateAttendees(key, value) {
      if (value) attendeelist[key] = value;
      print(attendeelist);
    }

    name = data['Name'];
    creator = data['Creator'];
    venue = data['Venue'];
    venueSpec = data['VenueSpec'] + " ";
    brief = data['Brief'] + " ";
    description = data['Description'] + " ";
    start = ItemDate.initDate(data['StartDate']);
    end = ItemDate.initDate(data['EndDate']);
    banner = data['Banner'];

    if(data['Questions'] != null) data['Questions'].forEach(iterateQuestions);
    if(data['Registrants'] != null) data['Registrants'].forEach(iterateAttendees);
  }
  ItemEvent.newEvent(this.key);
}
class ListEvent {
  final String key;
  List<ItemEvent> eventList = <ItemEvent>[];

  ListEvent.fromJson(this.key, Map data) {
    void iterateMapEntry(key, value) {
      eventList.insert(eventList.length, new ItemEvent.fromJson(key, value));
    }
    data.forEach(iterateMapEntry);
  }

  ListEvent.appendFromJson(this.eventList, this.key, Map data) {
    void iterateMapEntry(key, value) {
      eventList.insert(eventList.length, new ItemEvent.fromJson(key, value));
    }
    data.forEach(iterateMapEntry);
  }
}