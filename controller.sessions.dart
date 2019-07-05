import 'package:flutter/material.dart';
import 'controller.attendance.dart';
import 'model.session.dart';
import 'screen.sessionview.dart';
import 'util.firebase.dart';

class SessionsHolder {
  final String eventID;
  final BuildContext context;

  Map<String, Session> map = {};
  Map<String, Workshop> wsMap = {};
  List<Session> daySession = <Session>[];
  List<Session> slotSession = <Session>[];
  Map<String, Slot> eventSlots = {};
  Map<String, Track> eventTracks = {};
  Map<String, Day> eventDays = {};

  EventSessions sessions;

  bool isOnline = false;

  SessionsHolder(this.context, this.eventID) {
    sessions = EventSessions();
  }

  List<Session> getDaySessions(Day d) {
    daySession = <Session>[];
    d.daySlots.forEach((String s) {
      eventSlots[s].slotSessions.forEach(daySession.add);
    });
    return daySession;
  }
  List<Session> getSlotSessions(Slot e) {
    slotSession = <Session>[];
    e.slotSessions.forEach(slotSession.add);
    return slotSession;
  }

  void setStatus(bool s) {
    isOnline = s;
  }

  void showSessionScreen(Session ss, AttendanceHolder attendance) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ScreenSessionView(
                  session: ss,
                  attendance: attendance,
                  slot: eventSlots[ss.slotID],
                )));
  }
  void showWorkshopScreen(Workshop ss, AttendanceHolder attendance) {
//    Navigator.push(
//        context,
//        MaterialPageRoute(
//            builder: (context) => ScreenSessionView(
//                  session: ss,
//                  attendance: attendance,
//                  slot: eventSlots[ss.slotID],
//                )));
  }

  void getSessions(void done()) {
    SessionPresenter.getSessions(eventID, (Map data) {
      map = sessions.getFirebaseSessions(data, eventID);
      wsMap = sessions.getFirebaseWorkshops(data, eventID);

      eventSlots = sessions.getEventSlots(data);
      eventTracks = sessions.getEventTracks(data);
      wsMap.values.toList().forEach((Workshop ww) => eventTracks[ww.trackID].addWorkshop(ww));
      map.values.toList().forEach((Session s) => eventSlots[s.slotID].addSession(s));
      eventDays = sessions.getEventDays(eventSlots.values.toList());
      done();
    });
  }

  bool hasSessions() {
    return sessions != null && map.length > 0;
  }
}

class SessionPresenter {
  static void getSessions(String eventID, void sessionsRetrieved(Map data)) {
    FirebaseMethods.getSessionsByEventID(eventID, sessionsRetrieved);
  }
}