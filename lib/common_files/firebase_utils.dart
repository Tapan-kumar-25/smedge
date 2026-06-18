import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smedge/common_files/utils.dart';

class FirebaseUtils {
  FirebaseUtils._();

  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static Future<void> getDeviceToken() async {
    try {
      await _messaging.requestPermission();

      String? token = await _messaging.getToken();
if(token != null){
  print('FCM Token: $token');
  Utils.deviceId = token;
}

    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  static void listenForTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) {
      Utils.deviceId = token;

      print('FCM Token Refreshed: $token');
    });
  }
}