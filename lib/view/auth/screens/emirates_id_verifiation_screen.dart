import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/custom_elevated_button.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/provider/provider.dart';
import 'package:smedge/utils/global_utils.dart';
import 'package:smedge/utils/router/app_routes.dart';
import 'package:smedge/view/auth/auth_view_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common_files/network_checker.dart';
import '../../../constants/strings.dart';

class EmiratesIdVerificationScreen extends ConsumerStatefulWidget {
  const EmiratesIdVerificationScreen({super.key});

  @override
  ConsumerState<EmiratesIdVerificationScreen> createState() =>
      _EmiratesIdVerificationScreenState();
}

class _EmiratesIdVerificationScreenState
    extends ConsumerState<EmiratesIdVerificationScreen> {
 final AppLinks _appLinks = AppLinks();
 void _listenDeepLink(){
   _appLinks.uriLinkStream.listen((uri)async{
     if (uri.scheme == "smedge" &&
         uri.host == "uaepassstg" &&
         uri.path == "/done"){
       final status = uri.queryParameters['status'];
       final reason = uri.queryParameters['reason'];
       if(status =="approved"){
         if (!mounted) return;
         Utils.showSnackBar(
           context,
           "KYC completed successfully",
           Colors.green,
         );
         ref.read(resumeSignupNotifier.future);
         if (!mounted) return;
         Navigator.pushNamed(context, AppRoutes.companyDetails);
       }
       else if (status == "rejected") {
         if (!mounted) return;
         handleKycFailure(context,reason ?? "");
       }
     }
   });
 }

  @override
  void initState() {
   Utils.getSignUpSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).setContext(context);
    });
    super.initState();
    _listenDeepLink();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Numbers.DOUBLE_NUMBER_30),
              Text(
                "Emirates ID Verification",
                style: theme.textTheme.titleLarge,
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_6),
              Text(
                "Verify your identity to continue. You can fetch details using UAE Pass or upload your Emirates ID manually.",
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_10),
              InkWell(
                onTap: ()async {
                  await _startUaePassFlow();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        offset: Offset(2, 2),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fingerprint, size: 20, color: Colors.white),
                      SizedBox(width: Numbers.DOUBLE_NUMBER_10),
                      Text(
                        "Get Emirates ID from UAE PASS",
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_4),
              Row(
                children: [
                  Icon(Icons.keyboard_arrow_up, size: 20),
                  Text(
                    " Recommended for faster and secure verification",
                    style: theme.textTheme.titleSmall!.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: authState.isOtpVerifyLoading
                    ? Center(child: CircularProgressIndicator())
                    : CustomElevatedButton(
                        title: "I’ll do it later",
                        onPressed: () {
                          _skipKycFunction();
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _skipKycFunction() async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();
      if (hasInternet) {
        ref.read(authProvider).setOtpVerifyLoading(hasInternet);
        if (!mounted) return;
        FocusScope.of(context).unfocus();
        await ref.read(skipKycNotifier("").future);
      } else {
        if (!mounted) return;
        Utils.showSnackBar(context, Strings.NO_INTERNET, Colors.red);
      }
    } catch (e) {
      ref.read(authProvider).setOtpVerifyLoading(false);
    } finally {
      ref.read(authProvider).setOtpVerifyLoading(false);
    }
  }

 Future<void> _startUaePassFlow() async {
   try {
     final hasInternet = await NetworkChecker.hasInternet();

     if (!hasInternet) {
       Utils.showSnackBar(
         context,
         Strings.NO_INTERNET,
         Colors.red,
       );
       return;
     }

     final response = await ref.read(
       uaePassVerification(
         Utils.signUpSession,
       ).future,
     );

     final data = response["data"];
     final String appUrl = data["app_url"];
     final String appScheme = data["app_scheme"];
     final String androidPackage = data["android_package"];
     final String iosStoreUrl = data["ios_store_url"];
     final String playStoreUrl = data["play_store_url"];
     final String state = data['state'];
     bool isInstalled = false;
     if (Platform.isAndroid) {
       final apps = await FlutterDeviceApps.listApps(
         includeSystem: true,
         onlyLaunchable: false,
         includeIcons: false,
       );

       isInstalled = apps.any(
             (app) => app.packageName == androidPackage,
       );


     }
     else if (Platform.isIOS) {
       isInstalled = await canLaunchUrl(
         Uri.parse(appScheme),
       );
     }
     if (isInstalled) {
       await launchUrl(
         Uri.parse(appUrl),
         mode: LaunchMode.externalApplication,
       );
     }
     else {
       _showInstallDialog(
         Platform.isIOS
             ? iosStoreUrl
             : playStoreUrl,
       );
     }
   } catch (e) {
     Utils.showSnackBar(
       context,
       "Something went wrong",
       Colors.red,
     );
   }
 }
 void _showInstallDialog(String storeUrl) {
   showDialog(
     context: context,
     builder: (context) {
       return AlertDialog(
         title: const Text("UAE PASS Required"),
         content: const Text(
           "Install UAE PASS to continue",
         ),
         actions: [
           TextButton(
             onPressed: () {
               Navigator.pop(context);
             },
             child: const Text("Cancel"),
           ),

           ElevatedButton(
             onPressed: () async {
               Navigator.pop(context);

               await launchUrl(
                 Uri.parse(storeUrl),
                 mode: LaunchMode.externalApplication,
               );
             },
             child: const Text("Install UAE PASS"),
           ),
         ],
       );
     },
   );
 }
}
