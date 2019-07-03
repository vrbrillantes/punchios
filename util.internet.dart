import 'dart:io';
import 'dart:async';
import 'package:connectivity/connectivity.dart';

class PunchInternetUtils {
//  static String _connectionStatus = 'Unknown';
//  static Connectivity _connectivity = Connectivity();
//  static StreamSubscription<ConnectivityResult> _connectivitySubscription;

  static StreamSubscription sss;

  PunchInternetUtils(void connectionCheckCB(bool s), void setStatusCB(bool s)) {
    sss = connectionListener(setStatusCB);
    connectionCheck(connectionCheckCB);
  }

  void disposeSubscriptions() {
    if (sss != null) sss.cancel();
  }

  void connectionCheck(void isOnline(bool s)) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isOnline(true);
      }
    } on SocketException catch (_) {
      isOnline(false);
    }
  }

  StreamSubscription<ConnectivityResult> connectionListener(void onChange(bool s)) {
    Connectivity thisCon = Connectivity();
    return thisCon.onConnectivityChanged.listen((ConnectivityResult cr) {
      onChange(cr == ConnectivityResult.none ? false : true);
    });
  }
}
