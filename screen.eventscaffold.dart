import 'package:flutter/material.dart';
import 'model.events.dart';

import 'ui.eventWidgets.dart';
import 'ui.util.dart';

class ScaffoldEvent extends StatelessWidget {
  ScaffoldEvent({this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return new ScaffoldEventState(event: event);
  }
}

class ScaffoldEventState extends StatefulWidget {
  ScaffoldEventState({this.event});

  final Event event;

  @override
  _ScaffoldEventBuild createState() => new _ScaffoldEventBuild(loadEvent: event);
}

class _ScaffoldEventBuild extends State<ScaffoldEventState> {
  _ScaffoldEventBuild({this.loadEvent});

  final Event loadEvent;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> checkOverlay() {
    Navigator.pop(context);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
//      appBar: AppBar(
//        leading: IconButton(icon: Icon(Icons.keyboard_arrow_left), onPressed: checkOverlay),
//        backgroundColor: AppColors.appColorBackground,
//        title: Text(loadEvent.eventDetails.name, style: AppTextStyles.appbarTitle),
//      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            flexibleSpace: StaticBanner(loadEvent: loadEvent),
            expandedHeight: 200,
            automaticallyImplyLeading: false,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index == 0)
                  return Container(
                    color: AppColors.appColorWhite,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(18),
                            child: Text(loadEvent.eventDetails.name, style: AppTextStyles.eventTitle),
                          ),
                          EventDetailsBar(loadEvent: loadEvent),
                        ],
                      ),
                    ),
                  );
              },
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}
