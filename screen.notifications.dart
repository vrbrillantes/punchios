import 'package:flutter/material.dart';
import 'ui.util.dart';
import 'ui.backdrop.dart';
import 'model.notification.dart';
import 'dart:async';
import 'controller.notifications.dart';



class ScreenNotifications extends StatelessWidget {
  ScreenNotifications();

  @override
  Widget build(BuildContext context) {
    final ScreenNotificationsArguments args = ModalRoute.of(context).settings.arguments;
    return ScreenNotificationsState(allNotifications: args.allNotifications);
  }
}

class ScreenNotificationsState extends StatefulWidget {
  ScreenNotificationsState({this.allNotifications});

  final NotificationHolder allNotifications;

  @override
  _ScreenNotificationsBuild createState() => _ScreenNotificationsBuild(allNotifications: allNotifications);
}

class _ScreenNotificationsBuild extends State<ScreenNotificationsState> {
  _ScreenNotificationsBuild({this.allNotifications});

  StreamSubscription _subscriptionTodo;
  final NotificationHolder allNotifications;

  List<String> unreadNotifications = <String>[];

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  ListModel<dynamic> _list;

  @override
  void dispose() {
    if (_subscriptionTodo != null) {
      _subscriptionTodo.cancel();
    }
    super.dispose();
  }

  void readNotification(PunchNotification pn) {
    allNotifications.readNotification(pn);
  }

  @override
  void initState() {
    super.initState();
    allNotifications.getNotifications(
      () {
        setState(() {
          unreadNotifications = allNotifications.unreadNotifications;
          if (_list.length == 0)
            unreadNotifications.forEach((String s) {
              _list.insert(_list.length, allNotifications.allNotifications[s]);
            });
        });
      },
      (PunchNotification nn) {
        _list.insert(_list.length, nn);
      },
      (List<PunchNotification> lpn) {},
      (StreamSubscription ss) {
        _subscriptionTodo = ss;
      },
    );
    _list = ListModel<dynamic>(
      listKey: _listKey,
      initialItems: <dynamic>[],
      removedItemBuilder: _buildRemovedItem,
    );
  }

  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    CardItem insert = CardItem(animation: animation, notif: _list[index], onTap: () => {});
    return index == _list.length - 1 ? Column(children: <Widget>[insert, SizedBox(height: 80)]) : insert;
  }

  Widget _buildRemovedItem(dynamic item, BuildContext context, Animation<double> animation) {
    return CardItem(
      animation: animation,
      notif: item,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<PunchNotification> notificationsMap = unreadNotifications.map<PunchNotification>((String s) {
      return allNotifications.allNotifications[s];
    }).toList();

    notificationsMap.sort((b, a) => a.time.compareTo(b.time));
    return Theme(
        data: ThemeData(
          unselectedWidgetColor: AppColors.appGreyscalePlus,
        ),
        child: Stack(
          children: <Widget>[
            Backdrop2(),
            Scaffold(
              backgroundColor: const Color(0x00000000),
              appBar: AppBar(
                leading: IconButton(icon: Icon(Icons.keyboard_arrow_left), onPressed: () => Navigator.pop(context)),
                backgroundColor: AppColors.appColorBackground,
                title: Text('Notifications', style: AppTextStyles.appbarTitle),
              ),
              body: AnimatedList(
                key: _listKey,
                initialItemCount: 0,
                itemBuilder: _buildItem,
              ),
            ),
          ],
        ));
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
    @required this.notif,
  })  : assert(animation != null),
        super(key: key);

  final Animation<double> animation;
  final VoidCallback onTap;
  final PunchNotification notif;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: <Widget>[Expanded(child: Text(notif.message, style: AppTextStyles.eventDetailsGrey))],
            ),
          ),
        ),
      ),
    );
  }
}
