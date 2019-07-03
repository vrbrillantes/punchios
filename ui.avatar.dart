import 'package:flutter/material.dart';
import 'model.profile.dart';

class Avatar extends StatelessWidget {
  Avatar({this.profile, this.onPressed});

  final Profile profile;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: ClipOval(
          child: Hero(
            tag: "Avatar",
            child: profile.photo == null ? Icon(Icons.person) : Image.network(profile.photo),
          ),
        ),
      ),
    );
  }
}
