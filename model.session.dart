import 'model.date.dart';

class Session {
  final String ID;
  final String eventID;
  int maxAttendees;
  String name;
  String slotID;
  String description;
  String venue;

  Session.fromFirebase(this.ID, this.eventID, data) {
    name = data['Name'];
    slotID = data['Slot'];
    maxAttendees = data['Max'] == null ? 0 : data['Max'];
    description = data['Description'];
    venue = data['Venue'];
  }
}

class Day {
  final String ID;
  String name;
  PunchDate start;
  PunchDate end;
  List<String> daySlots = <String>[];

  Day.fromFirebase(this.ID) {
    name = ID;
  }

  void addSlot(Slot s) {
    if (start == null) {
      start = s.start;
      end = s.end;
    } else {
      if (s.start.datetime.isBefore(start.datetime)) start = s.start;
      if (s.end.datetime.isAfter(end.datetime)) end = s.end;
    }
    daySlots.add(s.ID);
  }
}

class Slot {
  final String ID;
  String name;
  PunchDate start;
  PunchDate end;
  List<Session> slotSessions = <Session>[];

  Slot.fromFirebase(this.ID, data) {
    name = data['Name'];
    start = PunchDate.initDBTime(data['TimeStart']);
    end = PunchDate.initDBTime(data['TimeEnd']);
  }

  void addSession(Session ss) {
    slotSessions.add(ss);
  }
}

class EventSessions {
  Map<String, Session> getFirebaseSessions(Map data, String eventID) {
    Map<String, Session> eventSessions = {};
    if (data != null) {
      data['Sessions'].forEach((kk, vv) {
        Session newSession = Session.fromFirebase(kk, eventID, vv);
        eventSessions[newSession.ID] = newSession;
      });
    }
    return eventSessions;
  }

  Map<String, Day> getEventDays(List<Slot> slots) {
    Map<String, Day> eventDays = {};
    slots.forEach((Slot s) {
      if (!eventDays.containsKey(s.start.simpleDate)) {
        eventDays[s.start.simpleDate] = Day.fromFirebase(s.start.simpleDate);
      }
      eventDays[s.start.simpleDate].addSlot(s);
    });
    return eventDays;
  }

  Map<String, Slot> getEventSlots(Map data) {
    Map<String, Slot> eventSlots = {};
    if (data != null) {
      data['Slots'].forEach((k, v) {
        Slot newSlot = Slot.fromFirebase(k, v);
        eventSlots[k] = newSlot;
      });
    }
    return eventSlots;
  }
}
