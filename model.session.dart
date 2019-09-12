import 'dart:convert';

import 'model.date.dart';
import 'package:flutter/material.dart';

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

class Workshop {
  final String ID;
  final String eventID;
  int maxAttendees;
  String name;
  String trackID;
  String description;
  int weight;
  String venue;
  PunchDate start;
  PunchDate end;

  Workshop.fromFirebase(this.ID, this.eventID, data) {
    name = data['Name'];
    trackID = data['Track'];
    weight = data['Weight'] == null ? 1 : data['Weight'];
    maxAttendees = data['Max'] == null ? 0 : data['Max'];
    description = data['Description'];
    venue = data['Venue'];
    start = PunchDate.initDBTime(data['TimeStart']);
    end = PunchDate.initDBTime(data['TimeEnd']);
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

class Track {
  final String ID;
  String name;
  List<Workshop> trackWorkshops = <Workshop>[];
  Image image;
  int minCompletion;

  Track.fromFirebase(this.ID, data) {
    name = data['Name'];
    minCompletion = data['MinCompletion'] == null ? 10 : data['MinCompletion'];
    image = data['Image'] == null
        ? Image.asset(
            'images/badges-complete@2x.png',
            width: 60,
            fit: BoxFit.fitWidth,
          )
//        : Image.memory(
//            base64Decode(data['Image64']),
//            width: 60,
//            fit: BoxFit.fitWidth,
//          );
        : Image.network(
            data['Image'],
            width: 60,
            fit: BoxFit.fitWidth,
          );
  }

  void addWorkshop(Workshop ss) {
    trackWorkshops.add(ss);
  }
}

class EventSessions {
  Map<String, Session> getFirebaseSessions(Map data, String eventID) {
    Map<String, Session> eventSessions = {};
    if (data != null && data['Sessions'] != null) {
      data['Sessions'].forEach((kk, vv) {
        Session newSession = Session.fromFirebase(kk, eventID, vv);
        eventSessions[newSession.ID] = newSession;
      });
    }
    return eventSessions;
  }

  Map<String, Workshop> getFirebaseWorkshops(Map data, String eventID) {
    Map<String, Workshop> eventWorkshops = {};
    if (data['Workshops'] != null) {
      data['Workshops'].forEach((kk, vv) {
        Workshop newWorkshop = Workshop.fromFirebase(kk, eventID, vv);
        eventWorkshops[newWorkshop.ID] = newWorkshop;
      });
    }
    return eventWorkshops;
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
    if (data != null && data['Slots'] != null) {
      data['Slots'].forEach((k, v) {
        Slot newSlot = Slot.fromFirebase(k, v);
        eventSlots[k] = newSlot;
      });
    }
    return eventSlots;
  }

  Map<String, Track> getEventTracks(Map data) {
    Map<String, Track> eventTracks = {};
    if (data['Tracks'] != null) {
      data['Tracks'].forEach((k, v) {
        Track newSlot = Track.fromFirebase(k, v);
        eventTracks[k] = newSlot;
      });
    }
    return eventTracks;
  }
}
