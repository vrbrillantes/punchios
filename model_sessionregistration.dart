class ItemSessionRegistration {
  final String slot;
  String email;
  String sessionID;
  bool status;

  ItemSessionRegistration.fromJson(this.slot, Map data) {

    email = data['Email'];
    sessionID = data['SessionID'];
    status = data['Status'];
  }
}

class ListSessionRegistrations {
  final String eventid;
  List<ItemSessionRegistration> sessionList = <ItemSessionRegistration>[];
  Map<String, String> attendeelist = {};

  ListSessionRegistrations.fromJson(this.eventid, Map data) {
    void iterateMapEntry(key, value) {
      attendeelist[key] = value;
    }
    data.forEach(iterateMapEntry);
  }
}