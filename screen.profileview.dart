import 'package:flutter/material.dart';
import 'model.profile.dart';
import 'ui.backdrop.dart';
import 'ui.util.dart';
import 'util.dialog.dart';
import 'ui.buttons.dart';

class GuestProfile extends StatelessWidget {
  GuestProfile({this.onFinished});

  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context) {
    return GuestProfileState(onFinished: onFinished);
  }
}

class GuestProfileState extends StatefulWidget {
  GuestProfileState({this.onFinished});

  final VoidCallback onFinished;

  @override
  _GuestProfileBuild createState() => _GuestProfileBuild(onFinished: onFinished);
}

class _GuestProfileBuild extends State<GuestProfileState> {
  _GuestProfileBuild({this.onFinished});

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  Map<String, String> updatedProfile;

  final VoidCallback onFinished;

  void onError() {}

  void saveGuest(Map<String, String> mss) {
    Profile.saveGuest(mss);
    onFinished();
  }

  void saveDetails() {
    final FormState form = _formKey.currentState;
    updatedProfile = {};
    form.save();
    updatedProfile.length == 3 ? saveGuest(updatedProfile) : onError();
  }

  void saveValue(String key, String value) {
    if (value != "" && value != " " && !RegExp(r'[^0-9A-Za-z,.\/-\s]').hasMatch(value)) updatedProfile[key] = value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appColorBackground,
        title: Image.asset(
          'images/logo_punch-main.png',
          height: 40,
        ),
      ),
      body: Stack(
        children: <Widget>[
          Backdrop(),
          Positioned.fill(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  StyledTextFormField(editingController: firstNameController, field: "first", action: saveValue, label: "First name"),
                  StyledTextFormField(editingController: lastNameController, field: "last", action: saveValue, label: "Last name"),
                  StyledTextFormField(editingController: emailController, field: "email", action: saveValue, label: "Email address"),
                  SizedBox(height: 36),
                  PunchRaisedButton(action: () => saveDetails(), label: "Save"),
                  SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  ProfileAvatar(this.profile);

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 127,
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            Positioned(
                left: 16,
                top: 16,
                child: ClipOval(
                    child: Hero(
                  tag: "Avatar",
                  child: profile.photo == null ? Icon(Icons.person) : Image.network(profile.photo, height: 95),
                ))),
            Positioned.fill(
                left: 132,
                right: 16,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(profile.name, style: AppTextStyles.styleWhiteBold(16)),
                    SizedBox(height: 5),
                    Text(profile.email, style: AppTextStyles.styleWhiteBold(14)),
                  ],
                )),
          ],
        ));
  }
}

TextEditingController lastNameController = TextEditingController();
TextEditingController emailController = TextEditingController();
TextEditingController groupController = TextEditingController();
TextEditingController divisionController = TextEditingController();
TextEditingController companyController = TextEditingController();
TextEditingController positionController = TextEditingController();
TextEditingController deptController = TextEditingController();
TextEditingController idNumberController = TextEditingController();
TextEditingController firstNameController = TextEditingController();

class ProfileForm extends StatefulWidget {
  ProfileForm({this.profile, this.dialog, this.profileSet});

  final Profile profile;
  final GenericDialogGenerator dialog;
  final Function(bool) profileSet;

  @override
  _ProfileFormBuild createState() => new _ProfileFormBuild(profile: profile, dialog: dialog, profileSet: profileSet);
}

class _ProfileFormBuild extends State<ProfileForm> {
  _ProfileFormBuild({this.profile, this.dialog, this.profileSet});

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final Profile profile;
  final Function(bool) profileSet;

  bool isEditing = false;
  final GenericDialogGenerator dialog;

  FocusNode myFocusNode = FocusNode();
  bool groupInFocus = false;
  bool built = false;

  void saveDetails() {
    final FormState form = _formKey.currentState;
    profile.clear();
    form.save();
    profile.saveDetails((bool s) {
      if (s) {
        startEditing(s: false);
        dialog.confirmDialog(dialog.profileUpdatedString);
        profileSet(true);
      } else {
        dialog.confirmDialog(dialog.profileCheckDetailsString);
      }
    });
  }

  void setGroup(String s) {
    Navigator.pop(context);
    setState(() {
      built = false;
    });
    groupController.text = s;
    myFocusNode.addListener(inFocus);
  }

  void inFocus() {
    myFocusNode.unfocus();
    if (built)
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return GroupList(
              onDelete: setGroup,
            );
          });
    setState(() {
      built = true;
    });
  }

  void startEditing({bool s = true}) {
    setState(() {
      isEditing = s;
      if (s) {
        firstNameController.text = profile.firstName;
        lastNameController.text = profile.lastName;
        groupController.text = profile.group;
        divisionController.text = profile.division;
        deptController.text = profile.department;
        companyController.text = profile.company;
        positionController.text = profile.position;
        idNumberController.text = profile.idNumber;
        myFocusNode.addListener(inFocus);
      }
    });
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: <Widget>[
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            switch (index) {
              case 0:
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                  child: Text('My profile', style: AppTextStyles.styleWhiteBold(22)),
                );
              case 1:
                return ProfileAvatar(profile);
                break;
              case 2:
                return profile.email.endsWith("@globe.com.ph")
                    ? (isEditing
                        ? Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                StyledTextFormField(editingController: firstNameController, field: "First", action: profile.updateProfileDetails, label: "First name"),
                                StyledTextFormField(editingController: lastNameController, field: "Last", action: profile.updateProfileDetails, label: "Last name"),
                                SizedBox(height: 36),
                                StyledTextFormField(editingController: idNumberController, field: "ID", action: profile.updateProfileDetails, label: "ID number"),
                                StyledTextFormField(editingController: groupController, field: "Group", myFocusNode: myFocusNode, action: profile.updateProfileDetails, label: "Group"),
                                StyledTextFormField(editingController: divisionController, field: "Division", action: profile.updateProfileDetails, label: "Division"),
                                StyledTextFormField(editingController: deptController, field: "Department", action: profile.updateProfileDetails, label: "Department"),
                                SizedBox(height: 36),
                              ],
                            ),
                          )
                        : ViewProfile(profile: profile))
                    : (isEditing
                        ? Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                StyledTextFormField(editingController: firstNameController, field: "First", action: profile.updateProfileDetails, label: "First name"),
                                StyledTextFormField(editingController: lastNameController, field: "Last", action: profile.updateProfileDetails, label: "Last name"),
                                SizedBox(height: 36),
                                StyledTextFormField(editingController: companyController, field: "Company", action: profile.updateProfileDetails, label: "Company"),
                                StyledTextFormField(editingController: positionController, field: "Position", action: profile.updateProfileDetails, label: "Position/Title"),
                                SizedBox(height: 36),
                              ],
                            ),
                          )
                        : OutsiderProfile(profile: profile));
                break;
              case 3:
                return isEditing
                    ? PunchRaisedButton(action: () => saveDetails(), label: "Save")
                    : Row(children: <Widget>[PunchOSFlatButton(label: 'Edit my information', onPressed: startEditing, bold: true)]);
                break;
            }
          },
          childCount: 4,
        ),
      )
    ]);
  }
}

class ViewProfile extends StatelessWidget {
  ViewProfile({this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LabelText(label: 'ID no.', value: profile.idNumber),
        LabelText(label: 'Group', value: profile.group),
        LabelText(label: 'Division', value: profile.division),
        LabelText(label: 'Department', value: profile.department),
      ],
    );
  }
}

class OutsiderProfile extends StatelessWidget {
  OutsiderProfile({this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LabelText(label: 'Company', value: profile.company),
        LabelText(label: 'Position/Title', value: profile.position),
      ],
    );
  }
}

class GroupList extends StatelessWidget {
  GroupList({this.onDelete});

  final Function(String) onDelete;

  final List<String> groups = <String>[
    'Broadband Business',
    'Channel Management',
    'Corporate and Legal Services',
    'Creative Marketing and Multimedia Business',
    'Enterprise',
    'Finance and Administration',
    'Human Resources',
    'Information Systems',
    'Mobile Business',
    'Network Technical',
    'New Business',
    'Office of the CTIO',
    'OSMCE',
    'Office of the CCO',
    'Office of the President',
    'Pipeline Management',
    'Small and Medium Business',
    'Others'
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: groups.map<Widget>((String s) {
        return FlatButton(
          child: Text(s, style: AppTextStyles.textForm),
          onPressed: () => onDelete(s),
        );
      }).toList(),
    );
  }
}
