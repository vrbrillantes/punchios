import 'package:flutter/material.dart';
import 'ui.util.dart';
import 'ui.buttons.dart';
import 'ui.backdrop.dart';

class ScreenTextInit {
  static void doThis(
      BuildContext c, List<String> labels, void done(String s)) async {
    String reason = await Navigator.push(
        c,
        MaterialPageRoute(
            builder: (context) => ScreenTextDialog(label: labels)));
    if (reason != null) done(reason);
  }
}

class ScreenTextDialog extends StatelessWidget {
  ScreenTextDialog({this.label});

  final List<String> label;

  @override
  Widget build(BuildContext context) {
    return ScreenTextDialogState(label: label);
  }
}

class ScreenTextDialogState extends StatefulWidget {
  ScreenTextDialogState({this.label});

  final List<String> label;

  @override
  _ScreenTextDialogBuild createState() => _ScreenTextDialogBuild(label: label);
}

class _ScreenTextDialogBuild extends State<ScreenTextDialogState> {
  _ScreenTextDialogBuild({this.label});

  void submitText(String s) {
    if (s != "") Navigator.pop(context, s);
  }

  final List<String> label;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final FormState form = _formKey.currentState;
    return Theme(
      data: ThemeData(),
      child: Stack(
        children: <Widget>[
          Backdrop2(),
          Scaffold(
            backgroundColor: const Color(0x00000000),
            appBar: AppBar(
              leading: IconButton(
                  icon: Icon(Icons.keyboard_arrow_left),
                  onPressed: () => Navigator.pop(context)),
              backgroundColor: AppColors.appColorBackground,
              title: Text(label[0], style: AppTextStyles.appbarTitle),
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(18, 42, 18, 0),
                      child: Text(label[1],
                          style: AppTextStyles.styleWhiteBold(15)),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(18, 15, 18, 42),
                      child: StyledTextFormFieldField(
                          action: submitText, label: label[2], maxLines: 5),
                    ),
                    PunchRaisedButton(
                      action: () => form.save(),
                      label: label[3],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
