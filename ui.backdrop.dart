import 'package:flutter/material.dart';

class Backdrop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Color.fromARGB(255, 240, 243, 246),
      body: Image.asset(
        'images/landing-page-bg.png',
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
class Backdrop2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
//      backgroundColor: Color.fromARGB(255, 240, 243, 246),
      body: Image.asset(
        'images/inner-page bg@3x.png',
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}
