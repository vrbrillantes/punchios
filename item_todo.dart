import 'item_questions.dart';
class Todo {
  final String key;
  String name;
  String venue;
  String startdate;
  String enddate;
  String banner;
  List<Question> questionlist = <Question>[];

  Todo.fromJJ(this.key, Map data) {
    void iterateQuestions(key, value) {
      print('$key:$value');//string interpolation in action
      questionlist.insert(questionlist.length, new Question.fromJson(key, value));
    }
    name = data['Name'];
    venue = data['Venue'];
    startdate = data['StartDate'];
    enddate = data['EndDate'];
    banner = data['Banner'];
    if(data['Questions'] != null) data['Questions'].forEach(iterateQuestions);
  }
}

class Todos {
  final String key;
  List<Todo> todolist = <Todo>[];

  Todos.fromJson(this.key, Map data) {
    void iterateMapEntry(key, value) {
      print('$key:$value');//string interpolation in action
      todolist.insert(todolist.length, new Todo.fromJJ(key, value));
    }
    data.forEach(iterateMapEntry);
  }
}