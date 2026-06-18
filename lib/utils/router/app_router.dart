import 'package:flutter/material.dart';
import 'package:smedge/utils/router/app_routes.dart';
import 'package:smedge/view/auth/forgot_password/forgot_password_screen.dart';
import 'package:smedge/view/auth/screens/emirates_id_verifiation_screen.dart';
import 'package:smedge/view/auth/screens/identity_otp_screen.dart';
import 'package:smedge/view/auth/screens/identity_screen.dart';
import 'package:smedge/view/auth/screens/number_email_verify_screen.dart';
import 'package:smedge/view/auth/screens/on_boarding_screen_a.dart';
import 'package:smedge/view/auth/screens/otp_screen.dart';
import 'package:smedge/view/auth/screens/set_password_screen.dart';
import 'package:smedge/view/auth/screens/sign_in_otp_verification_screen.dart';
import 'package:smedge/view/auth/screens/sign_in_screen.dart';
import 'package:smedge/view/auth/screens/sign_up_screen.dart';
import 'package:smedge/view/auth/screens/splash_screen.dart';
import 'package:smedge/view/auth/screens/welcome_back_screen.dart';
import 'package:smedge/view/auth/sign_up_with_uae_pass/personal_details_screen.dart';
import 'package:smedge/view/auth/sign_up_with_uae_pass/sign_up_with_uae_pass.dart';
import 'package:smedge/view/dash_board/screens/business_details_screen.dart';
import 'package:smedge/view/dash_board/screens/dashboard_screen.dart';
import 'package:smedge/view/products/product_details_screen.dart';

import '../../view/auth/screens/company_details_screen.dart';
import '../../view/dash_board/screens/notification_screen.dart';
import '../../view/dash_board/screens/personal_details_screen_dashboard.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.intro:
        return MaterialPageRoute(builder: (_) => const OnBoardingScreen());
        case AppRoutes.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
        case AppRoutes.numberEmailVerify:
        return MaterialPageRoute(builder: (_) => const NumberEmailVerifyScreen());
      case AppRoutes.otp:
        final args = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) =>  OtpScreen(enteredValue: args??"",));
      case AppRoutes.setPassword:
        final args = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) =>  SetPasswordScreen(previousScreen: args??"",));
        case AppRoutes.identity:
          final args = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) =>  IdentityScreen(password: args??""));
      case AppRoutes.identityOtp:
        return MaterialPageRoute(builder: (_) => const IdentityOtpScreen());
      case AppRoutes.idVerification:
        return MaterialPageRoute(builder: (_) => const EmiratesIdVerificationScreen());
      case AppRoutes.companyDetails:
        return MaterialPageRoute(builder: (_) => const CompanyDetailsScreen());
      case AppRoutes.signIn:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
        case AppRoutes.welcomeBack:
        return MaterialPageRoute(builder: (_) => const WelcomeBackScreen());
      case AppRoutes.signInOTPVerification:
        final args = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) =>  SignInOtpVerificationScreen(email: args??""));
      case AppRoutes.forgotPassword:
        final args = settings.arguments as String?;
        return MaterialPageRoute(builder: (_) =>  ForgotPasswordScreen(email: args??""));
      case AppRoutes.signUpWithUaePass:
        return MaterialPageRoute(builder: (_) => SignUpWithUaePass());
      case AppRoutes.personalDetails:
        return MaterialPageRoute(builder: (_) => PersonalDetailsScreen());
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => DashboardScreen());
      case AppRoutes.personalDetailsScreen:
        return MaterialPageRoute(builder: (_) => PersonalDetailsScreenDashboard());
      case AppRoutes.businessDetails:
        return MaterialPageRoute(builder: (_) => BusinessDetailsScreen());
      case AppRoutes.productDetails:
        return MaterialPageRoute(builder: (_) => MyProductDetailScreen());
      case AppRoutes.notification:
        return MaterialPageRoute(builder: (_) => NotificationScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Page not found")),
          ),
        );
    }
  }
}
