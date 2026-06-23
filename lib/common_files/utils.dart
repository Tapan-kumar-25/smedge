import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:smedge/constants/strings.dart';
import 'package:smedge/utils/shared_preference_utils.dart';

import 'device_utils.dart';

class Utils {
  static String deviceId = "";
  static void showSnackBar(
      BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
  static void showErrorSnackBar(
      BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
 static Future<List<File>> uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'pdf'],
      );

      if (result == null || result.files.isEmpty) return [];

      return result.files
          .where((file) => file.path != null)
          .map((file) => File(file.path!))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static  openFile(File file){
    OpenFile.open(file.path);
  }
  static String signUpSession = "";


  static Future<void> getSignUpSession() async {
    // String expiry =
    // SharedPreferenceUtils.getString("SIGNUP_SESSION_EXPIRY");
    // if (expiry.isNotEmpty) {
    //   DateTime expiryDate = DateTime.parse(expiry);
    //   if (DateTime.now().isAfter(expiryDate)) {
    //     signUpSession = "";
    //     await SharedPreferenceUtils.remove(Strings.SIGNUP_SESSION);
    //     await SharedPreferenceUtils.remove("SIGNUP_SESSION_EXPIRY");
    //     return;
    //   }
    // }

    signUpSession =
        SharedPreferenceUtils.getString(Strings.SIGNUP_SESSION);

    print("signUpSession =============== $signUpSession");
  }

static String accessToken = "";
static Future<void> getAccessToken()async{
  accessToken = SharedPreferenceUtils.getString(Strings.ACCESS_TOKEN);
  print("accessToken    =======accessToken======== $accessToken");
}

static String refreshToken = "";
static Future<void> getRefreshToken()async{
  refreshToken = SharedPreferenceUtils.getString(Strings.REFRESH_TOKEN);
  print("refreshToken    =======refreshToken======== $refreshToken");
}

static int userId = 0;
static Future<void> getUserId()async{
  userId = SharedPreferenceUtils.getInt(Strings.USER_ID);
  print("userId    =======userId======== $userId");
}


static int businessId = 0;
static Future<void> getBusinessId()async{
  businessId = SharedPreferenceUtils.getInt(Strings.BUSINESS_ID);
  print("businessId    =======businessId======== $businessId");
}

static bool isLogin = false;
static Future<void> getIsLogin()async{
  isLogin = SharedPreferenceUtils.getBool(Strings.IS_LOGIN);
}
static String signInToken = "";
  static Future<void> getSignInToken()async{
    signInToken = SharedPreferenceUtils.getString(Strings.SIGN_IN_SESSION);
    print("signInToken    =======signInToken======== $signInToken");
  }

  static String fullName = "";
  static Future<void> getFullName()async{
    signInToken = SharedPreferenceUtils.getString(Strings.fullName);
    print("fullName    =======fullName======== $fullName");
  }

  static Future<void> getAllData() async {
    await Future.wait([
      getFingerPrint(),
      getSignInToken(),
      getIsLogin(),
      getAccessToken(),
      getRefreshToken(),
      getUserId(),
      getBusinessId(),
      getFullName(),
    ]);
  }
static String  fingerprint ="";
  static Future<void> getFingerPrint()async{
     fingerprint = await DeviceUtils.getDeviceFingerprint();
  }


}
