import 'package:qr_reader/qr_reader.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

class QRGenerator {
  static Widget attendeeEventQR(
      {String eventID, String userKey, String direction}) {
    return QRBuild("CA|$userKey|$eventID|$direction");
  }

  static Widget attendeeSessionQR(
      {String userKey, String sessionID, String direction}) {
    return QRBuild("SA|$userKey|$sessionID|$direction");
  }
}

class QRActions {
  static void scanBoardingPass(void returnCode(String s), void wrongQR()) {
    scanQR(
      qrType: "BP",
      returnCode: (List<String> s) {
        returnCode(s[1]);
      },
      wrongQR: wrongQR,
    );
  }

  static void scanCheckInSelf(
      {String eventID, void returnCode(String s), void wrongQR()}) {
    scanQR(
      qrType: "CS",
      returnCode: (List<String> s) {
        eventID != s[1] ? wrongQR() : returnCode(s[1]);
      },
      wrongQR: wrongQR,
    );
  }

  static void scanCheckOutSelf(
      {String eventID, void returnCode(String s), void wrongQR()}) {
    scanQR(
      qrType: "CO",
      returnCode: (List<String> s) {
        eventID != s[1] ? wrongQR() : returnCode(s[1]);
      },
      wrongQR: wrongQR,
    );
  }

  static void scanCheckInSessionSelf(
      {String direction,
      String sessionID,
      void returnCode(String s),
      void wrongQR()}) {
    scanQR(
      qrType: "SS",
      returnCode: (List<String> s) {
        sessionID != s[1]
            ? wrongQR()
            : direction != s[2] ? wrongQR() : returnCode(s[1]);
      },
      wrongQR: wrongQR,
    );
  }

  static void scanCheckOutSessionSelf(
      {String sessionID, void returnCode(String s), void wrongQR()}) {
    scanQR(
      qrType: "SO",
      returnCode: (List<String> s) {
        sessionID != s[1] ? wrongQR() : returnCode(s[1]);
      },
      wrongQR: wrongQR,
    );
  }

  static void scanBooth(
      {String boothID, void returnCode(String s), void wrongQR()}) {
    scanQR(
      qrType: "BS",
      returnCode: (List<String> s) {
        boothID != s[1] ? wrongQR() : returnCode(s[1]);
      },
      wrongQR: wrongQR,
    );
  }

  static void scanCheckInAttendee(
      {String eventID,
      void returnCode(String session, String dir),
      void wrongQR()}) {
    scanQR(
      qrType: "CA",
      returnCode: (List<String> s) {
        eventID != s[2] ? wrongQR() : returnCode(s[1], s[3]);
      },
      wrongQR: wrongQR,
    );
  }

  static void scanCheckInAttendeeSession(
      {void returnCode(String user, String session, String dir),
      void wrongQR()}) {
    scanQR(
      qrType: "SA",
      returnCode: (List<String> s) {
        returnCode(s[1], s[2], s[3]);
      },
      wrongQR: wrongQR,
    );
  }

  static void scanCheckInSessionAttendee(
      {String sessionID,
      void returnCode(String s, String dir),
      void wrongQR()}) {
    scanQR(
      qrType: "SA",
      returnCode: (List<String> s) {
        sessionID != s[2] ? wrongQR() : returnCode(s[1], s[3]);
      },
      wrongQR: wrongQR,
    );
  }

  static void scanQR(
      {String qrType, void returnCode(List<String> s), void wrongQR()}) {
    scanEventQr((String qrCode) {
      List<String> qrCodeArray = qrCode.split("|");
      qrCodeArray[0] == qrType ? returnCode(qrCodeArray) : wrongQR();
    });
  }

  static void scanEventQr(void returnCode(String s)) async {
    String barcode = await QRCodeReader()
        .setAutoFocusIntervalInMs(200) // default 5000
        .setForceAutoFocus(true) // default false
        .setTorchEnabled(true) // default false
        .setHandlePermissions(true) // default true
        .setExecuteAfterPermissionGranted(true) // default true
        .scan();
    returnCode(barcode != null ? barcode : "");
  }
}

class QRBuild extends StatelessWidget {
  QRBuild(this.payload);

  final String payload;

  @override
  Widget build(BuildContext context) {
    return QrImage(data: payload, size: 175);
  }
}
