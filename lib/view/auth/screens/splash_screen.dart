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
    bool isLogin = SharedPreferenceUtils.getBool(Strings.IS_LOGIN);
    if (Utils.refreshToken.isNotEmpty) {
      print("splash =======");
      try {
        await ref.read(refreshTokenNotifier.future);
        await Utils.getAllData();
      } catch (e) {
        await SharedPreferenceUtils.clear();
      }
    }
    Future.delayed(Duration(seconds: 4)).then((value) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        isLogin == true ? AppRoutes.welcomeBack : AppRoutes.intro,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final h = size.height;
    final w = size.width;
    return Scaffold(
      body: SafeArea(
        top: true,bottom: true,
        child: SizedBox(
          height: h,
          width: w,
          child: Lottie.asset("assets/animation/splash_animation1.json"),
        ),
      ),
    );
  }
}
