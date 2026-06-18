import 'package:flutter/cupertino.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';

class UaePassUtils {
  static Future<bool> isUaePassInstalled() async {
    try {
      final apps = await FlutterDeviceApps.listApps(
        includeSystem: true,
        onlyLaunchable: true,
      );

      return apps.any(
            (app) =>
        app.packageName ==
            "ae.uaepass.mainapp" ||
            app.packageName ==
                "ae.uaepass.mainapp.stg",
      );
    } catch (e) {
      debugPrint("Check UAE PASS Error => $e");
      return false;
    }
  }
}