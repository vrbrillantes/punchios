class Badge {
  final String id;
  String description;
  String icon;
  String title;

  Badge.fromFirebase(this.id, Map data) {
    title = data['Title'];
    icon = data['Icon'];
    description = data['Description'];
  }
}

class EventBadges {
  static List<String> readEarnedBadges(Map data) {
    List<String> earnedBadges = <String>[];
    if (data != null)
      data.forEach((k, v) {
        earnedBadges.add(k);
      });
    return earnedBadges;
  }

  static List<Badge> readBadges(Map data) {
    List<Badge> eventBadges = <Badge>[];
    if (data != null)
      data.forEach((k, v) {
        print(v.toString());
        eventBadges.add(Badge.fromFirebase(k, v));
      });
    return eventBadges;
  }
}
