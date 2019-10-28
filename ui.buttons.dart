import 'package:flutter/material.dart';
import 'ui.util.dart';

class AdminActionButtons extends StatelessWidget {
  AdminActionButtons(this.label, this.icon, {this.onPressed});

  final IconData icon;

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
//      padding: EdgeInsets.symmetric(vertical: 8.0,horizontal: 0),
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 24.0, color: AppColors.appColorSecondary),
            Text(label, style: AppTextStyles.adminActionsIcons),
          ],
        ),
      ),
    );
  }
}

class SessionNavigationFlatButton extends StatelessWidget {
  SessionNavigationFlatButton({this.changeView, this.buttons, this.selected});

  final Function(String) changeView;
  final List<String> buttons;
  final String selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18, 30, 18, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: buttons
            .map((String s) => Expanded(
                child: selected == s
                    ? Column(
                        children: <Widget>[
                          FlatButton(
                            child: Text(s, style: AppTextStyles.styleWhiteBold(14)),
                            onPressed: () {},
                          ),
                          Container(
                            color: AppColors.appAccentPurple,
                            height: 4,
                          )
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          FlatButton(
                            child: Text(s, style: AppTextStyles.styleWhite(14)),
                            onPressed: () => changeView(s),
                          ),
                          Container(
                            color: AppColors.appColorWhite,
                            height: 1,
                          )
                        ],
                      )))
            .toList(),
      ),
    );
  }
}

class PunchFilledFlatButton extends StatelessWidget {
  PunchFilledFlatButton({this.action, this.label, this.expanded = true, this.padded = true});

  final VoidCallback action;
  final String label;
  final bool padded;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : null,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: padded ? 8 : 0, horizontal: padded ? 18 : 0),
        child: FlatButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
          color: AppColors.appAccentPurple,
          child: Text(label, style: AppTextStyles.styleWhiteBold(18)),
          onPressed: action,
        ),
      ),
    );
  }
}

class PunchOSFlatButton extends StatelessWidget {
  PunchOSFlatButton({this.onPressed, this.label, this.expanded = true, this.bold = false});

  final bool bold;
  final String label;
  final VoidCallback onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return FlatButton(child: Text(label, style: bold ? AppTextStyles.eventDetailsOrangeBold : AppTextStyles.eventLinks), onPressed: onPressed);
  }
}

class PunchRaisedButton extends StatelessWidget {
  PunchRaisedButton({this.action, this.label, this.expanded = true});

  final VoidCallback action;
  final String label;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : null,
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
          child: RaisedButton(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
            padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
            color: AppColors.appAccentPurple,
            child: Text(label, style: AppTextStyles.styleWhiteBold(18)),
            onPressed: action,
          )),
    );
  }
}

class PunchOutlineButton extends StatelessWidget {
  PunchOutlineButton({this.action, this.label, this.expanded = true, this.padded = true, this.againstWhite = false});

  final VoidCallback action;
  final String label;
  final bool againstWhite;
  final bool padded;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expanded ? double.infinity : null,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: padded ? 8 : 1, horizontal: padded ? 18 : 1),
        child: OutlineButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 0.0),
          color: AppColors.appAccentPurple,
          borderSide: BorderSide(color: AppColors.appAccentPurple, width: 2),
          child: Text(label, style: againstWhite ? AppTextStyles.stylePurpleBold(18) : AppTextStyles.styleWhiteBold(18)),
          onPressed: action,
        ),
      ),
    );
  }
}
