import 'model.date.dart';
import 'model.profile.dart';

class AttendanceStatus {
  bool checkedIn;
  bool feedback;
  bool checkedOut;
  String textStatus = "Check-in";

  AttendanceStatus.newStatus(Map data) {
    checkedIn = data.containsKey('CheckedIn') ? true : false;
    feedback = data.containsKey('Feedback') ? true : false;
    checkedOut = data.containsKey('CheckedOut') ? true : false;


    if (checkedIn) textStatus = "Checked-in";
    if (feedback) textStatus = "Ready to checkout";
    if (checkedOut) textStatus = "Checked out";
  }
}

class SlotAttendance {
  final String sessionID;
  final AttendanceStatus attendance;

  SlotAttendance(this.sessionID, this.attendance);
}

class WorkshopAttendance {
  final String key;
  String workshopID;
  AttendanceStatus attendance;

  WorkshopAttendance.parseData(this.key, Map data) {
    attendance = AttendanceStatus.newStatus(data);
    workshopID = data['WorkshopID'];
  }
}

class WorkshopsAttendance {
  final String eventID;
  final String userKey;

  WorkshopsAttendance(this.eventID, this.userKey);

  Map<String, int> sortedAttendees(String workshopID, Map data) {
    Map<String, int> attMap = {};
    List<SessionAttendee> attendees = <SessionAttendee>[];

    data.forEach((k, v) {
      attendees.add(SessionAttendee.newAttendee(v['UserID'], v['Registered']));
    });
    attendees.sort((a, b) => a.regTime.datetime.compareTo(b.regTime.datetime));
    attendees.forEach((SessionAttendee ss) {
      attMap[ss.attendee] = attendees.indexOf(ss) + 1;
    });
    return attMap;
  }
  Map<String, WorkshopAttendance> parseAttendance(Map data) {
    Map<String, WorkshopAttendance> attendance = {};
    if (data != null) {
      data.forEach((k, v) {
        WorkshopAttendance newAtt = WorkshopAttendance.parseData(k, v);
        attendance[newAtt.workshopID] = newAtt;
      });
    }
    return attendance;
  }
}

class SessionAttendance {
  final String eventID;
  final String userKey;
  Map<String, AttendanceStatus> attendance = {};
  Map<String, String> mySlots = {};

  SessionAttendance(this.eventID, this.userKey);

  Map<String, int> sortedAttendees(String slotID, Map data) {
    List<SessionAttendee> attendees = <SessionAttendee>[];
    Map<String, int> attMap = {};
    data.forEach((k, v) {
      attendees.add(SessionAttendee.newAttendee(k, v[slotID]['Registered']));
    });
    attendees.sort((a, b) => a.regTime.datetime.compareTo(b.regTime.datetime));
    attendees.forEach((SessionAttendee ss) {
      attMap[ss.attendee] = attendees.indexOf(ss) + 1;
    });
    return attMap;
  }

  Map<String, SlotAttendance> parseAttendance(Map data) {
    Map<String, SlotAttendance> sessionAttendance = {};
    attendance = {};
    if (data != null) {
      data.forEach((k, v) {
        if (v['SessionID'] != null) {
          String sessionID = v['SessionID'];
          sessionAttendance[k] = SlotAttendance(sessionID, AttendanceStatus.newStatus(v));
          mySlots[k] = sessionID;
          attendance[sessionID] = AttendanceStatus.newStatus(v);
        }
      });
    }
    return sessionAttendance;
  }
}

class SessionAttendee {
  final String attendee;
  PunchDate regTime;

  SessionAttendee.newAttendee(this.attendee, String time) {
    regTime = PunchDate.initDBTime(time);
  }
}

class Attendance {
  final String eventID;
  final Profile profile;
  String userKey;
  bool hasFeedback = false;
  bool registered = false;
  bool checkedIn = false;
  bool checkedOut = false;
  bool cancelled = false;

  bool isOngoing = false;
  bool isFinished = false;
  bool isQuestionTime = false;
  bool isFeedbackTime = false;

  bool canAskQuestions = false;
  String cancelledReason;

  Attendance.newAttendance(this.eventID, this.profile) {
    userKey = profile.profileLogin.userKey;
  }

  void readAttendance(Map data) {
    if (data != null) if (data.containsKey('Reason')) {
      cancelled = true;
      cancelledReason = data['Reason'];
    } else {
      checkedIn = data['Status'] == null ? false : data['Status'];
      hasFeedback = data['Feedback'] == null ? false : data['Feedback'];
      checkedOut = data['Checkout'] == null ? false : data['Checkout'];
      registered = true;
    }
  }

  void setTime(PunchDate start, PunchDate end) {
    if (DateTime.now().isAfter(start.datetime) && DateTime.now().isBefore(end.datetime)) {
      isOngoing = true;
    }
    if (DateTime.now().isAfter(end.datetime.subtract(Duration(minutes: 30)))) {
      isFeedbackTime = true;
    }
    if (DateTime.now().isAfter(end.datetime)) {
      isFinished = true;
    }
    if (DateTime.now().isAfter(start.datetime) && DateTime.now().isBefore(end.datetime.add(Duration(minutes: 30)))) {
      isQuestionTime = true;
    }
  }
}
