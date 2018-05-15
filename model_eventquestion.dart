class ItemEventQuestion {
  final String key;
  String name;
  String question;
  String photo;

  ItemEventQuestion.fromJson(this.key, Map value) {
    name = value['Name'];
    question = value['Message'] + "";
    photo = value['Photo'];
  }
}

class ListEventQuestion {
  final String key;
  List<ItemEventQuestion> eventQuestionList = <ItemEventQuestion>[];

  ListEventQuestion.fromJson(this.key, Map data) {
    void iterateMapEntry(key, value) {
      if (value['Message'] != null) eventQuestionList.insert(eventQuestionList.length, new ItemEventQuestion.fromJson(key, value));
    }
    data.forEach(iterateMapEntry);
  }
}