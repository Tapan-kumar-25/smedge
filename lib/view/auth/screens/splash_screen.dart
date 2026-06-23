import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:smedge/constants/strings.dart';
import 'package:smedge/utils/router/app_routes.dart';
import 'package:smedge/utils/shared_preference_utils.dart';

import '../../../common_files/utils.dart';
import '../auth_view_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    _getData();
    super.initState();
  }

  Future<void> _getData() async {
    await Utils.getSignUpSession();
    await Utils.getAllData();
    await Utils.getRefreshToken();
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        Utils.isLogin ? AppRoutes.welcomeBack : AppRoutes.intro,
      );
    });
    if (Utils.refreshToken.isNotEmpty) {
        ref.read(refreshTokenNotifier.future).then((_) async {
          await Utils.getAllData();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,bottom: true,left: true,right: true,
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Lottie.asset("assets/animation/splash_animation1.json"),
        ),
      ),
    );
  }
}
