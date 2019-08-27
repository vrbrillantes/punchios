import 'model.date.dart';

class Events {
  Map<String, Event> parseEvents(Map data) {
    Map<String, Event> allEvents = {};
    data.forEach((k, v) {
      allEvents[k] = Event.fromFirebase(k, v);
    });
    return allEvents;
  }

  static List<EventInvitation> readPermittedUsers(Map data) {
    List<EventInvitation> permittedUsers = <EventInvitation>[];
    if (data['Invitations'] != null)
      data['Invitations'].forEach((k, v) {
        permittedUsers.add(EventInvitation(invitationKey: v));
      });

    return permittedUsers;
  }

  List<String> readCollaborators(Map data) {
    List<String> collaboratorList = <String>[];
    if (data != null) {
      data.forEach((k, v) {
        collaboratorList.add(v);
      });
    }
    return collaboratorList;
  }

  List<EventLink> readLinks(Map data) {
    List<EventLink> eventLinks = <EventLink>[];
    if (data != null) {
      data.forEach((k, v) {
        eventLinks.add(EventLink.newLink(k, v));
      });
    }
    return eventLinks;
  }

  List<String> getActiveEvents(List<Event> le) {
    List<String> activeEvents = <String>[];
    le.forEach((Event e) {
      if (!activeEvents.contains(e.eventID) && DateTime.now().isBefore(e.end.datetime.add(Duration(days: 3)))) activeEvents.add(e.eventID);
    });
    return activeEvents;
  }
}

class EventLink {
  String linkID;
  String link;
  String name;

  EventLink.newLink(this.linkID, Map data) {
    link = data['Link'];
    name = data['Name'];
  }
}

class EventInvitation {
  final String invitationKey;

  EventInvitation({this.invitationKey});
}

class Event {
  final String eventID;

  bool isToday = false;
  bool regQuestions = false;
  EventDetails eventDetails;
  PunchDate start;
  PunchDate end;
  Map eventMap;
  List<EventInvitation> permittedUsers;

  Event.fromFirebase(this.eventID, data) {
    eventMap = data;
    regQuestions = data['RegQuestions'] != null ? data['RegQuestions'] : false;
    start = PunchDate.initDBTime(data['Details']['StartDate']);
    end = PunchDate.initDBTime(data['Details']['EndDate']);
    eventDetails = EventDetails.fromFirebase(data['Details']);
    permittedUsers = Events.readPermittedUsers(data);
    isToday = (-12 < DateTime.now().difference(start.datetime).inHours && DateTime.now().difference(start.datetime).inHours < 12);
  }
}

class EventDetails {
  String name;
  String shortDescription;
  String venue;
  String venueSpec = "HH";
  String banner;
  String longDescription;

  EventDetails.fromFirebase(Map data) {
    name = data['Name'];
    venue = data['Venue'];
    banner = data['Banner'];
    shortDescription = data['Brief'] != null ? data['Brief'] : "";
    longDescription = data['Description'] != null ? data['Description'] : "";
  }
}
