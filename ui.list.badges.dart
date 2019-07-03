import 'package:flutter/material.dart';
import 'model.badges.dart';
import 'controller.events.dart';
import 'ui.util.dart';

class ListBadges extends StatefulWidget {
  ListBadges(this.badgesHolder, this.height);

  final double height;
  final BadgesHolder badgesHolder;

  @override
  ListBadgesBuild createState() => ListBadgesBuild(badgesHolder, height.floorToDouble(), height.floorToDouble() * 3);
}

class ListBadgesBuild extends State<ListBadges> with TickerProviderStateMixin {
  ListBadgesBuild(this.badgesHolder, this.originalMargin, this.largerMargin);

  final double originalMargin;
  final double largerMargin;
  double fanMargin;
  final BadgesHolder badgesHolder;

  AnimationController _controller2;
  CurvedAnimation _curvedController2;
  Animation<double> animation2;

  @override
  void initState() {
    _controller2 = AnimationController(vsync: this, duration: Duration(seconds: 2));
    _curvedController2 = CurvedAnimation(parent: _controller2, curve: Curves.easeOutSine);
    animation2 = Tween<double>(end: 1, begin: 0).animate(_curvedController2);
    fanMargin = originalMargin;
    badgesHolder.getEventBadges(() => setState(() {}));
    badgesHolder.getEarnedBadges(() => setState(() {}));
    super.initState();
  }

  void fanColors() {
    setState(() {
      fanMargin = fanMargin == largerMargin ? originalMargin : largerMargin;
    });
  }

  Widget animPos(int index, bool show, {Badge cc}) {
    return AnimatedPositioned(
        curve: Curves.easeInOutSine,
        duration: Duration(milliseconds: 400),
        left: (index.toDouble() % (fanMargin / originalMargin) * fanMargin) + (index.toDouble() * fanMargin % originalMargin) + (originalMargin / 2),
        top: ((index.toDouble() - index.toDouble() % 3) * (fanMargin - originalMargin)) / 1.6,
        child: Column(
          children: <Widget>[
            Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                index == 0
                    ? Positioned(
                        top: -10,
                        left: -10,
                        child: SizedBox(
                          height: 80,
                          width: 80,
                          child: fanMargin == originalMargin
                              ? AnimatedBuilder(
                                  builder: (context, anim) {
                                    return CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(badgesHolder.eventBadges.length == badgesHolder.earnedBadges.length
                                          ? AppColors.appAccentGreen
                                          : AppColors.appAccentOrange),
                                      strokeWidth: 5,
                                      value: animation2.value * badgesHolder.earnedBadges.length / badgesHolder.eventBadges.length,
                                    );
                                  },
                                  animation: _controller2,
                                )
                              : SizedBox(),
                        ),
                      )
                    : SizedBox(),
                InkWell(
                  onTap: cc == null ? fanColors : () => badgesHolder.scanBadge(cc, () => setState(() {})),
                  child: ClipOval(
                    clipBehavior: Clip.antiAlias,
                    child: cc == null
                        ? Container(
                            height: 60,
                            child: badgesHolder.earnedBadges.length == badgesHolder.eventBadges.length
                                ? Image.asset(
                                    'images/badges-complete@2x.png',
                                    width: 60,
                                    fit: BoxFit.fitWidth,
                                  )
                                : Image.asset(
                                    'images/show-badges@2x.png',
                                    width: 60,
                                    fit: BoxFit.fitWidth,
                                  ),
                            width: 60,
                          )
                        : Container(
                            height: 60,
                            child: show
                                ? Image.network(
                                    cc.icon,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'images/booth-locked@3x.png',
                                    width: 60,
                                    fit: BoxFit.fitWidth,
                                  ),
                            width: 60,
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14),
            cc == null
                ? Container(
                    width: 100,
                    child: Text(
                      fanMargin == originalMargin ? "Show badges" : "Hide badges",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.styleWhiteBold(14),
                    ),
                  )
                : AnimatedOpacity(
                    curve: Curves.easeOutSine,
                    duration: Duration(milliseconds: 400),
                    opacity: fanMargin == originalMargin ? 0 : 1,
                    child: Container(
                      width: 100,
                      child: Text(
                        cc.title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.styleWhiteBold(14),
                      ),
                    ),
                  ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    _controller2.forward(from: 0);

    double tiers = ((badgesHolder.eventBadges.length + 2) / 3).floorToDouble();
    List<Widget> appWids = badgesHolder.eventBadges
        .map<Widget>((Badge cc) => animPos(badgesHolder.eventBadges.indexOf(cc), badgesHolder.earnedBadges.contains(cc.id), cc: cc))
        .toList();

    appWids.add(animPos(badgesHolder.eventBadges.length, false));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        badgesHolder.eventBadges.length > 0
            ? Container(
                margin: EdgeInsets.fromLTRB(18, 20, 18, 0),
                child: Text("Booths", style: AppTextStyles.styleWhiteBold(16)),
              )
            : SizedBox(),
        badgesHolder.eventBadges.length == 0
            ? SizedBox()
            : AnimatedContainer(
                duration: Duration(milliseconds: 400),
                curve: Curves.easeOutSine,
                height:
                    32 + ((fanMargin / largerMargin).floor() * tiers * largerMargin * 1.3) + largerMargin * (largerMargin / fanMargin / 3).floor(),
                padding: EdgeInsets.all(18),
                child: Stack(overflow: Overflow.visible, children: appWids)),
      ],
    );
  }
}

//class ColorHolder {
//  final Color color;
//  final String name;
//  final String cmyk;
//  final String rgbval;
//  final String hex;
//
//  const ColorHolder({this.color, this.name, this.cmyk, this.rgbval, this.hex});
//}
//
//class LikeCircle extends StatefulWidget {
//  LikeCircle({this.cc, this.onTap});
//
//  final VoidCallback onTap;
//  final ColorHolder cc;
//
//  @override
//  _CircleBuild createState() => _CircleBuild(cc: cc, onTap: onTap);
//}
//
//class _CircleBuild extends State<LikeCircle> with TickerProviderStateMixin {
//  _CircleBuild({this.cc, this.onTap});
//
//  final VoidCallback onTap;
//  final ColorHolder cc;
//
//  double widgetSize = 80;
//  AnimationController _controller;
//  CurvedAnimation _curvedController;
//  Animation<double> animation;
//
//  @override
//  void initState() {
//    super.initState();
//    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 600));
//    _curvedController = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
//    animation = Tween<double>(end: 1, begin: 0).animate(_curvedController);
//    _controller.forward(from: 0);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Stack(
//      overflow: Overflow.visible,
//      children: <Widget>[
//        SizedBox(
//          height: widgetSize,
//          width: widgetSize,
//        ),
//        AnimatedBuilder(
//          animation: _controller,
//          builder: (context, anim) {
//            return Positioned(
//              left: (widgetSize / 2) - animation.value * (widgetSize / 2),
//              top: (widgetSize / 2) - animation.value * (widgetSize / 2),
//              child: Transform(
//                alignment: Alignment.center,
//                transform: Matrix4.diagonal3Values(1, 1, 1),
//                child: InkWell(
//                  onTap: onTap,
//                  child: ClipOval(
//                    clipBehavior: Clip.antiAlias,
//                    child: Container(
//                      color: cc.color,
//                      height: animation.value * widgetSize,
//                      width: animation.value * widgetSize,
//                    ),
//                  ),
//                ),
//              ),
//            );
//          },
//        )
//      ],
//    );
//  }
//}
