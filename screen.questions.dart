import 'package:flutter/material.dart';
import 'ui.util.dart';
import 'ui.buttons.dart';
import 'ui.backdrop.dart';
import 'dart:async';
import 'screen.textDialog.dart';
import 'util.dialog.dart';
import 'model.participation.dart';
import 'model.profile.dart';
import 'controller.participation.dart';

class ScreenQuestionAruments {
  ScreenQuestionAruments({this.profile, this.eventID, this.sessionID, this.isAdmin});

  final String eventID;
  final Profile profile;
  final String sessionID;
  final bool isAdmin;
}

class ScreenQuestions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ScreenQuestionAruments args = ModalRoute.of(context).settings.arguments;
    return ScreenQuestionsState(profile: args.profile, sessionID: args.sessionID, eventID: args.eventID, isAdmin: args.isAdmin);
  }
}

class ScreenQuestionsState extends StatefulWidget {
  ScreenQuestionsState({this.profile, this.sessionID, this.eventID, this.isAdmin});

  final bool isAdmin;
  final String eventID;
  final String sessionID;
  final Profile profile;

  @override
  _ScreenQuestionsBuild createState() => _ScreenQuestionsBuild(profile: profile, eventID: eventID, sessionID: sessionID, isAdmin: isAdmin);
}

class _ScreenQuestionsBuild extends State<ScreenQuestionsState> {
  _ScreenQuestionsBuild({this.profile, this.eventID, this.sessionID, this.isAdmin = false});

  GenericDialogGenerator dialog;
  StreamSubscription _subscriptionTodo;
  final String eventID;
  final String sessionID;
  final Profile profile;
  final bool isAdmin;
  EventParticipation eq;

  List<String> questionKeys = <String>[];
  final myListKey = GlobalKey<AnimatedListState>();

  List<String> sortedList = <String>[];
  Map<String, int> voteIndex = {};

  @override
  void initState() {
    super.initState();
    dialog = GenericDialogGenerator.init(context);
    eq = EventParticipation(eventID: eventID, sessionID: sessionID, profile: profile);
    eq.getQuestions(processQuestions, (StreamSubscription s) {
      _subscriptionTodo = s;
    });

    _list = ListModel<dynamic>(
      listKey: _listKey,
      initialItems: <dynamic>[],
      removedItemBuilder: _buildRemovedItem,
    );
  }

  void processQuestions(Map<String, Question> eq) {
    List<Question> tempQuestions = eq.values.toList();
    tempQuestions.sort((b, a) => a.votes.compareTo(b.votes));

    tempQuestions.forEach((Question s) {
      if (!questionKeys.contains(s.key)) {
        questionKeys.add(s.key);
        setState(() {
          _list.insert(_list.length, s);
        });
      } else if (voteIndex[s.key] != s.votes) {
        setState(() {
          _list.removeAt(questionKeys.indexOf(s.key));
          _list.insert(tempQuestions.indexOf(s), s);
        });
      }
      voteIndex[s.key] = s.votes;
    });

    questionKeys = tempQuestions.map<String>((Question s) {
      return s.key;
    }).toList();
  }

  Widget _buildRemovedItem(dynamic item, BuildContext context, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: item,
      isAdmin: isAdmin,
    );
  }

  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    CardItem insert = CardItem(
      animation: animation,
      item: _list[index],
      onTap: () => vote(_list[index].key),
      isAdmin: isAdmin,
      onAnswer: () => answered(_list[index].key),
      onProject: () => projectQuestion(_list[index].key),
    );
    return index == _list.length - 1 ? Column(children: <Widget>[insert, SizedBox(height: 80)]) : insert;
  }
  @override
  void dispose() {
    if (_subscriptionTodo != null) {
      _subscriptionTodo.cancel();
    }
    super.dispose();
  }

  void vote(String questionid) {
    eq.voteQuestion(questionid, profile.profileLogin.userKey, () {
      setState(() {});
    });
  }

  void projectQuestion(String questionid) {
    eq.setKioskQuestion(questionid);
  }

  void answered(String questionID) {
    eq.setQuestionAsAnswered(questionID, () {
      setState(() {});
    });
  }

  void askQuestion() {
    ScreenTextInit.doThis(
        context, dialog.askQuestionString, (String s) => eq.askQuestion(question: s, sessionID: sessionID, questionSubmitted: () => dialog.confirmDialog(dialog.questionSubmittedString)));
  }

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  ListModel<dynamic> _list;


  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(),
      child: Stack(
        children: <Widget>[
          Backdrop2(),
          Scaffold(
            backgroundColor: const Color(0x00000000),
            appBar: AppBar(
              leading: IconButton(icon: Icon(Icons.keyboard_arrow_left), onPressed: () => Navigator.pop(context)),
              backgroundColor: AppColors.appColorBackground,
              title: Text('Questions', style: AppTextStyles.appbarTitle),
            ),
//            floatingActionButton: FloatingActionButton(
//              child: Icon(Icons.message),
//              onPressed: askQuestion,
//            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: PunchRaisedButton(label: 'Ask question', action: askQuestion),
            body: Stack(
              children: <Widget>[
                AnimatedList(
                  key: _listKey,
                  initialItemCount: 0,
                  itemBuilder: _buildItem,
                ),
//                Positioned(
//                  left: 0,
//                  right: 0,
//                  bottom: 0,
//                  child: Card(
//                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.0)),
//                    margin: EdgeInsets.all(10),
//                    child: Container(child: Text("HELLO"), height: 200),
//                  ),
//                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListModel<E> {
  ListModel({
    @required this.listKey,
    @required this.removedItemBuilder,
    Iterable<E> initialItems,
  })  : assert(listKey != null),
        assert(removedItemBuilder != null),
        _items = initialItems?.toList() ?? <E>[];

  final GlobalKey<AnimatedListState> listKey;
  final dynamic removedItemBuilder;
  final List<E> _items;

  AnimatedListState get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    if (removedItem != null) {
      _animatedList.removeItem(index, (BuildContext context, Animation<double> animation) {
        return removedItemBuilder(removedItem, context, animation);
      });
    }
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}

class CardItem extends StatelessWidget {
  const CardItem({
    Key key,
    @required this.animation,
    this.onTap,
    this.onAnswer,
    this.onProject,
    @required this.item,
    this.isAdmin,
  })  : assert(animation != null),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback onTap;
  final VoidCallback onAnswer;
  final VoidCallback onProject;
  final Question item;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(item.question, style: AppTextStyles.eventDetailsGrey),
              ),
            ),
            isAdmin
                ? InkWell(
                    onTap: onAnswer,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Padding(padding: EdgeInsets.all(4), child: Icon(Icons.beenhere, color: item.answered ? AppColors.appAccentYellow : AppColors.appGreyscaleBaseline)),
//                      child: Padding(padding: EdgeInsets.all(4), child: Image.asset('images/vote-up@3x.png', height: 24)),
                    ),
                  )
                : SizedBox(),
            isAdmin
                ? InkWell(
                    onTap: onProject,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Padding(padding: EdgeInsets.all(4), child: Icon(Icons.cast, color: AppColors.appGreyscaleBaseline)),
//                      child: Padding(padding: EdgeInsets.all(4), child: Image.asset('images/vote-up@3x.png', height: 24)),
                    ),
                  )
                : SizedBox(),
            InkWell(
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(4), child: Image.asset('images/vote-up@3x.png', height: 24)),
                    item.votes > 0 ? Text("+ ${item.votes.toString()}", style: AppTextStyles.eventDetailsBold) : SizedBox(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
