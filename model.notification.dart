class PunchNotification {
  String message;
  String eventID;
  String notificationID;
  int time;
  bool read;

  PunchNotification.readNew(this.notificationID, this.eventID, Map data) {
    message = data['message'];
    time = data['time'];
    read = data['read'];
  }
}
