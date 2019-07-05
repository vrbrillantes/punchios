import 'package:flutter/material.dart';

class LabelText extends StatelessWidget {
  LabelText({this.label, this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(18, 13, 0, 6),
          child: Text(
            label,
            style: AppTextStyles.styleWhiteBold(15),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(18, 6, 0, 13),
          child: Text(
            value,
            style: AppTextStyles.styleWhite(16),
          ),
        ),
      ],
    );
  }
}

class StyledTextFormField extends StatelessWidget {
  StyledTextFormField({
    this.field,
    this.editingController,
    this.value,
    this.action,
    this.label,
    this.maxLines,
    this.autoval,
    this.numbersOnly = false,
    this.myFocusNode,
  });

  final FocusNode myFocusNode;
  final void Function(String, String) action;
  final String field;
  final String label;
  final bool numbersOnly;
  final List<String> autoval;
  final int maxLines;
  final String value;

  final TextEditingController editingController;

  void onSavedAction(String s) {
    action(field, s);
  }

  @override
  Widget build(BuildContext context) {
    if (editingController != null) editingController.text = value;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTextStyles.styleWhiteBold(15)),
          SizedBox(height: 10),
          TextFormField(
            autovalidate: autoval != null,
            keyboardType: numbersOnly ? TextInputType.phone : TextInputType.text,
            maxLines: maxLines == null ? 1 : maxLines,
            controller: editingController,
            style: AppTextStyles.textForm,
            focusNode: myFocusNode != null ? myFocusNode : null,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(16.0),
              hintText: label,
              hintStyle: AppTextStyles.bannerDate,
              filled: true,
              fillColor: AppColors.appColorWhite,
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appAccentPurple, width: 1)),
              border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appAccentPurple, width: 1)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appAccentPurple, width: 2)),
            ),
            onSaved: onSavedAction,
            validator: (String value) {
              int matches = 0;
              if (value != " " && value != null && value != "") {
                autoval.forEach((String s) {
                  if (s.contains(value)) matches++;
                });
              } else {
                return null;
              }
              return matches > 0 ? matches.toString() : 'Invalid value';
            },
          )
        ],
      ),
    );
  }
}

class StyledTextFormFieldField extends StatelessWidget {
  StyledTextFormFieldField({
    this.action,
    this.label,
    this.maxLines,
  });

  final void Function(String) action;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines == null ? 1 : maxLines,
      style: AppTextStyles.textForm,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(16.0),
        hintText: label,
        hintStyle: AppTextStyles.bannerDate,
        filled: true,
        fillColor: AppColors.appColorWhite,
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appAccentPurple, width: 1)),
        border: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appAccentPurple, width: 1)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appAccentPurple, width: 2)),
      ),
      onSaved: action,
    );
  }
}

class TabBarItem {
  Image icon;
  Image inactive;
  String label;

  int index;

  TabBarItem.newItem(this.icon, this.inactive, this.label, this.index);
}

List<TabBarItem> punchItems = <TabBarItem>[
  TabBarItem.newItem(
    Image.asset('images/all-events_active@2x.png', height: 18),
    Image.asset('images/all-events@2x.png', height: 18),
    "All events",
    0,
  ),
  TabBarItem.newItem(
    Image.asset('images/my-events_inactive@2x.png', height: 18),
    Image.asset('images/my-events_active@2x.png', height: 18),
    "My events",
    1,
  ),
  TabBarItem.newItem(
    Image.asset('images/my-profile_inactive@2x.png', height: 18),
    Image.asset('images/my-profile_active@2x.png', height: 18),
    "My profile",
    2,
  )
];

List<Widget> punchActions = <Widget>[];

class TabBarPadding extends StatelessWidget {
  TabBarPadding({this.tbItem, this.selected});

  final TabBarItem tbItem;
  final int selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      child: Row(
        children: <Widget>[
          selected == tbItem.index ? tbItem.icon : tbItem.inactive,
          SizedBox(width: 10),
          Text(
            tbItem.label,
            style: selected == tbItem.index ? AppTextStyles.styleWhiteBold(16) : AppTextStyles.styleWhite(16),
          ),
        ],
      ),
    );
  }
}

class LabelListTile extends StatelessWidget {
  LabelListTile({this.label, this.trailing});

  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      color: AppColors.appAccentYellow,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyles.bannerTitle,
      ),
    );
  }
}

//class PunchEventNav extends StatelessWidget {
//  PunchEventNav({this.selectedIndex, this.onItemTapped});
//
//  final Function(int) onItemTapped;
//  final int selectedIndex;
//
//  @override
//  Widget build(BuildContext context) {
//    return BottomNavigationBar(items: <BottomNavigationBarItem>[
//      BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
//      BottomNavigationBarItem(icon: Icon(Icons.event_available), title: Text('Attending')),
//      BottomNavigationBarItem(icon: Icon(Icons.offline_pin), title: Text('Offline')),
//    ], currentIndex: selectedIndex, fixedColor: Colors.deepPurple, onTap: onItemTapped);
//  }
//}

class UIUtils {
  static List<DropdownMenuItem<String>> createDropdownItems(List<String> choices) {
    return choices.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

//  static List<PopupMenuItem<String>> createNotificationsItems(ListNotification notifs) {
//    List<PopupMenuItem<String>> popupList = <PopupMenuItem<String>>[];
//    notifs.notificationList.forEach((ItemNotification inot) {
//      popupList.add(PopupMenuItem<String>(
//        value: inot.key,
//        child: Text(inot.message, style: AppTextStyles.labelRegularLight),
//      ));
//    });
//    return popupList;
//  }
}

//class StyledTextFormField extends StatelessWidget {
//  StyledTextFormField({this.field, this.editingController, this.value, this.action, this.label, this.maxLines, this.numbersOnly = false});
//
//  final void Function(String, String) action;
//  final String field;
//  final String label;
//  final bool numbersOnly;
//  final int maxLines;
//  final String value;
//
//  final TextEditingController editingController;
//
//  void onSavedAction(String s) {
//    action(field, s);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    editingController.text = value;
//    return Padding(
//      padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//      child: TextFormField(
//        keyboardType: numbersOnly ? TextInputType.phone : TextInputType.text,
//        maxLines: maxLines == null ? 1 : maxLines,
//        controller: editingController,
//        decoration: InputDecoration(
//          contentPadding: EdgeInsets.all(12.0),
//          hintText: label,
//          border: OutlineInputBorder(),
//        ),
//        onSaved: onSavedAction,
//      ),
//    );
//  }
//}

class AppColors {
  static Color appColorMain = Color.fromARGB(255, 21, 26, 83);
  static Color appColorMainTransparent = Color.fromARGB(178, 21, 26, 83);
  static Color appColorBackground = Color.fromARGB(255, 20, 25, 82);
  static Color appColorSecondary = Color.fromARGB(255, 51, 161, 253);
  static Color appAccentYellow = Color.fromARGB(255, 253, 218, 73);
  static Color appAccentPurple = Color.fromARGB(255, 140, 82, 255);
  static Color appAccentPurple2 = Color.fromARGB(255, 59, 53, 97);
  static Color appAccentOrange = Color.fromARGB(255, 248, 147, 31);
  static Color appAccentGreen = Color.fromARGB(255, 5, 190, 132);
  static Color appBlue = Color.fromARGB(255, 4, 150, 255);
  static Color appGreyBlue = Color.fromARGB(255, 116, 122, 155);
  static Color appGreyscalePlus = Color.fromARGB(255, 175, 175, 175);
  static Color appGreyscaleBaseline = Color.fromARGB(255, 152, 152, 152);
  static Color appGreyscaleMinus = Color.fromARGB(255, 93, 93, 93);
  static Color appGreyscaleMinus2 = Color.fromARGB(255, 60, 60, 60);
  static Color appGreyscaleMinus3 = Color.fromARGB(255, 54, 53, 55);

  static Color appColorRed = Color.fromARGB(255, 208, 0, 0);
  static Color appColorWhite = Colors.white;

//  static Color appColorLight = Color.fromARGB(255, 154, 154, 154);
//  static Color appColorBlue = Color.fromARGB(255, 59, 138, 233);
//  static Color appColorLightMinus = Color.fromARGB(255, 119, 119, 119);
//  static Color appColorDark = Color.fromARGB(255, 70, 70, 70);
//  static Color appColorLightPlus = Color.fromARGB(255, 172, 172, 172);
//  static Color appColorThinkBlue = Color.fromARGB(255, 59, 138, 233);
//  static Color appColorBlueAccent = Color.fromARGB(255, 33, 194, 210);
}

class AppTextStyles {
//  static TextStyle titleBig = TextStyle(
//    fontSize: 22.0,
//    fontWeight: FontWeight.bold,
//    color: AppColors.appColorBlue,
//  );
//  static TextStyle titleStyleBlue = TextStyle(
//    fontSize: 16.0,
//    fontWeight: FontWeight.bold,
//    color: AppColors.appColorBlue,
//  );
//  static TextStyle titleLarge = TextStyle(
//    fontSize: 18.0,
//    color: AppColors.appColorLight,
//  );
//  static TextStyle titleStyle = TextStyle(
//    fontSize: 16.0,
//    fontWeight: FontWeight.bold,
//    color: AppColors.appColorLight,
//  );
//  static TextStyle titleStyleDark = TextStyle(
//    fontSize: 16.0,
//    fontWeight: FontWeight.bold,
//    color: AppColors.appColorDark,
//  );
//  static TextStyle titleStyleLight = TextStyle(
//    fontSize: 16.0,
//    color: AppColors.appColorLight,
//  );
//  static TextStyle priceRegular = TextStyle(
//    fontWeight: FontWeight.bold,
//    fontSize: 16.0,
//    color: AppColors.appColorRed,
//  );
//  static TextStyle priceMini = TextStyle(
//    fontWeight: FontWeight.bold,
//    fontSize: 12.0,
//    color: AppColors.appColorRed,
//  );
//  static TextStyle priceMiniLight = TextStyle(
//    fontSize: 12.0,
//    color: AppColors.appColorRed,
//  );
//  static TextStyle labelMiniBold = TextStyle(
//    fontWeight: FontWeight.bold,
//    fontSize: 12.0,
//    color: AppColors.appColorLightMinus,
//  );
//  static TextStyle labelMiniDarkBold = TextStyle(
//    fontWeight: FontWeight.bold,
//    fontSize: 12.0,
//    color: AppColors.appColorLight,
//  );
//  static TextStyle labelMini = TextStyle(
//    fontSize: 12.0,
//    color: AppColors.appColorLightPlus,
//  );
//  static TextStyle labelMiniDark = TextStyle(
//    fontSize: 12.0,
//    color: AppColors.appColorLightMinus,
//  );
//  static TextStyle labelDark = TextStyle(
//    fontSize: 16.0,
//    fontWeight: FontWeight.bold,
//    color: AppColors.appColorLightMinus,
//  );
//  static TextStyle labelRegular = TextStyle(
//    fontSize: 14.0,
//    fontWeight: FontWeight.bold,
//    color: AppColors.appGreyscaleBaseline,
//  );
//  static TextStyle labelRegularLight = TextStyle(
//    fontSize: 14.0,
//    color: AppColors.appGreyscaleBaseline,
//  );
//  static TextStyle labelWhite = TextStyle(
//    fontSize: 18.0,
//    fontWeight: FontWeight.bold,
//    color: AppColors.appColorWhite,
//  );
//  static TextStyle labelWhiteMini = TextStyle(
//    fontSize: 12.0,
//    fontWeight: FontWeight.bold,
//    color: AppColors.appColorWhite,
//  );
//  static TextStyle styleWhiteBold16 = TextStyle(
//    fontSize: 16,
//    fontWeight: FontWeight.bold,
//    color: AppColors.appColorWhite,
//  );

  static TextStyle appbarTitle = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 16,
    color: AppColors.appColorWhite,
  );
  static TextStyle textForm = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 14,
    color: AppColors.appGreyscaleMinus3,
  );
  static TextStyle dialogDescription = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 16,
    color: AppColors.appGreyscaleMinus3,
  );
  static TextStyle slotName = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.appColorMain,
  );
  static TextStyle slotTime = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 10,
    color: AppColors.appGreyscaleMinus3,
  );
  static TextStyle eventTitle = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.appColorMain,
  );
  static TextStyle eventDetails = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 14,
    color: AppColors.appColorMain,
  );
  static TextStyle eventDetailsBold = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.appGreyscaleBaseline,
  );
  static TextStyle sessionVenue = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.appGreyscaleBaseline,
  );
  static TextStyle eventLinks = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 14,
    decoration: TextDecoration.underline,
    color: AppColors.appAccentOrange,
  );
  static TextStyle sessionStatus = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.appAccentOrange,
  );
  static TextStyle eventDetailsOrangeBold = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.appAccentOrange,
  );
  static TextStyle eventDetailsGrey = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 14,
    color: AppColors.appGreyscaleMinus,
  );
  static TextStyle bannerTitle = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.appColorMain,
  );
  static TextStyle qrDialog = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 18,
    color: AppColors.appColorMain,
  );
  static TextStyle qrScanText = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.appAccentOrange,
  );
  static TextStyle bannerDateDay = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.appGreyscaleMinus2,
  );
  static TextStyle bannerDateMonth = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.appGreyscaleMinus2,
  );
  static TextStyle sessionTime = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.appGreyscaleMinus2,
  );
  static TextStyle bannerDate = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 12,
    color: AppColors.appGreyscaleBaseline,
  );
  static TextStyle bannerDescription = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 12,
    color: AppColors.appGreyscaleMinus,
  );
  static TextStyle bannerActions = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 12,
    color: AppColors.appGreyBlue,
  );
  static TextStyle bannerActionsClicked = TextStyle(
    fontFamily: 'FSElliotPro',
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.appGreyBlue,
  );

  static TextStyle styleWhite(double s) {
    return TextStyle(
      fontFamily: 'FSElliotPro',
      fontSize: s,
      color: AppColors.appColorWhite,
    );
  }

  static TextStyle styleWhiteBold(double s) {
    return TextStyle(
      fontFamily: 'FSElliotPro',
      fontSize: s,
      fontWeight: FontWeight.bold,
      color: AppColors.appColorWhite,
    );
  }

  static TextStyle stylePurpleBold(double s) {
    return TextStyle(
      fontFamily: 'FSElliotPro',
      fontSize: s,
      fontWeight: FontWeight.bold,
      color: AppColors.appAccentPurple,
    );
  }
  static TextStyle styleDarkPurpleBold(double s) {
    return TextStyle(
      fontFamily: 'FSElliotPro',
      fontSize: s,
      fontWeight: FontWeight.bold,
      color: AppColors.appAccentPurple2,
    );
  }

  static TextStyle styleBlueBold(double s) {
    return TextStyle(
      fontFamily: 'FSElliotPro',
      fontSize: s,
      fontWeight: FontWeight.bold,
      color: AppColors.appBlue,
    );
  }

  static TextStyle adminActionsIcons = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.bold,
    fontFamily: 'FSElliotPro',
    color: AppColors.appColorSecondary,
  );
}
