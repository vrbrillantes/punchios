class ItemSessionRegistration {
//  String email;
  String sessionID;
  bool confirmed;
  bool done;
  String slot;

  ItemSessionRegistration.fromJson(this.slot, Map data) {

//    email = data['Email'];
    sessionID = data['Session'];
    confirmed = data['Confirmed'];
    done = data['Done'];
  }
}

class ListSessionRegistrations {
  final String eventid;
  List<ItemSessionRegistration> sessionList = <ItemSessionRegistration>[];
  Map<String, ItemSessionRegistration> attendeelist = {};

  ListSessionRegistrations.fromJson(this.eventid, Map data) {
    void iterateMapEntry(key, value) {
      if (value['Session'] != null) attendeelist[key] = ItemSessionRegistration.fromJson(key, value);
//      if (value['Session'] != null) attendeelist[key] = value['Session'];
    }
    data.forEach(iterateMapEntry);
  }
}