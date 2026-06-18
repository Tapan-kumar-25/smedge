import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceUtils {
  static Future<String> getDeviceFingerprint() async {
    final deviceInfo = DeviceInfoPlugin();

    String rawData = '';

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;

      rawData =
      '${androidInfo.brand}_${androidInfo.model}_${androidInfo.id}_${androidInfo.device}';
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;

      rawData =
      '${iosInfo.name}_${iosInfo.model}_${iosInfo.systemVersion}_${iosInfo.identifierForVendor}';
    }

    return sha256.convert(utf8.encode(rawData)).toString();
  }
}