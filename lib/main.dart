import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/utils/router/app_router.dart';
import 'package:smedge/utils/router/app_routes.dart';
import 'package:smedge/utils/shared_preference_utils.dart';
import 'package:smedge/utils/theme/app_theme.dart';
import 'package:smedge/utils/theme/them_provider.dart';
import 'package:smedge/view/auth/screens/welcome_back_screen.dart';

import 'common_files/firebase_utils.dart';


void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError =
      FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true,);
    return true;
  };
  await SharedPreferenceUtils.init();
 await Utils.getSignUpSession();
  await FirebaseUtils.getDeviceToken();
  FirebaseUtils.listenForTokenRefresh();
 await Utils.getAllData();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute:  AppRouter.generateRoute,
      // home: WelcomeBackScreen(),
    );
  }
}
