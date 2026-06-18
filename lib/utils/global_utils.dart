
import 'package:flutter/material.dart';

import '../common_files/utils.dart';

List<String> introImageList = [
  "assets/images/on_boarding2.png",
  "assets/images/on_boarding1.png",
];
List<Map<String, dynamic>> signUpOptions =[
  {"name":"call","icon":"assets/svg/call.svg"},
  {"name":"email","icon":"assets/svg/email.svg"},
  {"name":"whatsapp","icon":"assets/svg/whatsapp.svg"},
];
const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String fmtFullDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}

String fmtScheduleDate(DateTime date) {
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
String formatDate(DateTime date) {
  return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
}
void handleKycFailure(BuildContext context, String reason) {
  String message = "KYC failed";

  switch (reason) {
    case "KYC_EID_CONFLICT":
      message =
      "Your Emirates ID is already linked to another Smedge account.";
      break;

    case "KYC_UUID_CONFLICT":
      message =
      "Your UAE PASS profile is already linked to another Smedge account.";
      break;

    case "KYC_EMAIL_MISMATCH":
      message =
      "The email on your UAE PASS profile doesn't match your Smedge account.";
      break;

    case "KYC_PHONE_CONFLICT":
      message =
      "Your UAE PASS phone is already linked to another Smedge account.";
      break;

    case "INVALID_STATE_NONCE":
      message = "Session expired. Please try KYC again.";
      break;

    case "UAEPASS_EXCHANGE_FAILED":
      message = "Couldn't reach UAE PASS. Try again in a moment.";
      break;

    case "UAEPASS_INCOMPLETE_PROFILE":
      message =
      "Your UAE PASS profile is missing required information.";
      break;
  }

  Utils.showSnackBar(context, message, Colors.red);
}

String getGreeting() {
  final hour = DateTime.now().hour;

  if (hour < 12) {
    return "Good Morning";
  } else if (hour < 17) {
    return "Good Afternoon";
  } else {
    return "Good Evening";
  }
}