import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';

import '../../../common_files/custom_container.dart';
import '../../../common_files/custom_elevated_button.dart';
import '../../../common_files/network_checker.dart';
import '../../../common_files/support_widget.dart';
import '../../../common_files/utils.dart';
import '../../../constants/numbers.dart';
import '../../../constants/strings.dart';
import '../../../provider/provider.dart';
import '../../../utils/router/app_routes.dart';
import '../auth_view_model.dart';

enum VerificationType { email, phone }

class NumberEmailVerifyScreen extends ConsumerStatefulWidget {
  const NumberEmailVerifyScreen({super.key});

  @override
  ConsumerState<NumberEmailVerifyScreen> createState() => _NumberEmailVerifyScreenState();
}

class _NumberEmailVerifyScreenState extends ConsumerState<NumberEmailVerifyScreen> {

  VerificationType currentStep = VerificationType.email;

  final emailOtpController = TextEditingController();
  final phoneOtpController = TextEditingController();

  Timer? _timer;

  int seconds = 60;
  bool isResendVisible = false;

  void startTimer() {
    seconds = 60;
    isResendVisible = false;

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (seconds > 0) {
          setState(() => seconds--);
        } else {
          timer.cancel();
          setState(() => isResendVisible = true);
        }
      },
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).setContext(context);
    });
    Utils.getAccessToken();
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    emailOtpController.dispose();
    phoneOtpController.dispose();
    super.dispose();
  }


  Future<void> resendOtp() async {
    final type = currentStep == VerificationType.email
        ? "EMAIL"
        : "SMS";

    startTimer();
    await _resendOtp(type);
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final authState = ref.watch(authProvider);
    final pinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: theme.textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w700,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );
    return SafeArea(
        bottom: true, top: false,
        child: Scaffold(
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.1),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Image.asset(
                              "assets/images/sign_up.png",
                              // height: size.height * 0.3,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  width: size.width * 0.3,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.white,
                                        theme.colorScheme.primary
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: Numbers.DOUBLE_NUMBER_4),
                              Text(
                                "OTP",
                                style: theme.textTheme.titleMedium!.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: Numbers.DOUBLE_NUMBER_4),
                              Expanded(
                                child: Container(
                                  width: size.width * 0.3,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerRight,
                                      end: Alignment.centerLeft,
                                      colors: [
                                        Colors.white,
                                        theme.colorScheme.primary
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Numbers.DOUBLE_NUMBER_6),
                          Text(
                            Strings.EMAIL_PHONE_VERIFY_SCREEN,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                    authState.isEmailVerified?Padding(padding: EdgeInsetsGeometry.only(bottom: Numbers.DOUBLE_NUMBER_16),
                    child:  _verificationCard(
                      title: "Email Verification",
                      subTitle: "Verified successfully",
                    ),
                    ): const SizedBox(),

                    authState.isMobileVerified?
                    _verificationCard(
                      title: "Phone Number Verification",
                      subTitle: "Verified successfully",
                    ):
                CustomContainer(
                  padding: Numbers.DOUBLE_NUMBER_10,
                  child: buildOtpVerificationSection(
                    context: context,
                    title: currentStep == VerificationType.email
                        ? "Email Verification"
                        : "Phone Verification",
                    subTitle: currentStep == VerificationType.email
                        ? authState.signUpData['email']
                        : authState.signUpData['number'],
                    controller: currentStep == VerificationType.email
                        ? emailOtpController
                        : phoneOtpController,
                    isResendVisible: isResendVisible,
                    seconds: seconds,
                    pinTheme: pinTheme,
                    buttonText: currentStep == VerificationType.email
                        ? "Verify Email OTP"
                        : "Verify Phone OTP",
                    onResend: resendOtp,
                    onVerify: () async {
                      if (currentStep == VerificationType.email) {
                        await _verifyEmailOtp();
                      } else {
                        await _verifyPhoneOtp();
                      }
                    },
                  ),
                ),
                    authState.isEmailVerified && authState.isMobileVerified? Padding(
                      padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
                      child: authState.isLoading
                          ? Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      )
                          : SizedBox(
                        width: double.infinity,
                        child: CustomElevatedButton(
                          title: "Continue",
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, AppRoutes.idVerification);
                          },
                        ),
                      ),
                    ):
                    SizedBox(height: Numbers.DOUBLE_NUMBER_16,),
                    SupportWidget(context: context),
                  ],
                ),
              ),
              if (authState.isResentOtpLoading)
                Container(
                  color: Colors.black26,
                  alignment: Alignment.center,
                  height: 70,
                  width: double.infinity,
                  padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      CircularProgressIndicator(),
                      SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                      Text(
                        "Resending OTP...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: Numbers.DOUBLE_NUMBER_16,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ));
  }

  Widget buildOtpVerificationSection({
    required BuildContext context,
    required String title,
    required String subTitle,
    required TextEditingController controller,
    required VoidCallback onVerify,
    required VoidCallback onResend,
    required bool isResendVisible,
    required int seconds,
    required PinTheme pinTheme,
    String buttonText = "Verify OTP",
  }) {
    final theme = Theme.of(context);
    final authState = ref.read(authProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          subTitle,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),

        Pinput(
          length: 6,
          controller: controller,
          autofocus: true,
          defaultPinTheme: pinTheme,
          focusedPinTheme: pinTheme,
          submittedPinTheme: pinTheme,
          separatorBuilder: (_) => const SizedBox(width: 12),
          showCursor: true,
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 20),

        Row(
          children: [
            isResendVisible? GestureDetector(
              onTap: isResendVisible ? onResend : null,
              child: Text(
                "Resend OTP ?",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ):
            Text(
              "00:${seconds.toString().padLeft(2, '0')}",
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child:authState.isOtpVerifyLoading
              ?const Center(child: CircularProgressIndicator(),): CustomElevatedButton(
            onPressed: onVerify,
            title: buttonText
          ),
        ),
      ],
    );
  }

  Widget _verificationCard({
    required String title,
    required String subTitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.green,
        ),
        borderRadius: BorderRadius.circular(12),
          boxShadow:  [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: Offset(0, 3),
              blurRadius: 6,
              // spreadRadius: 0,
            ),
          ]
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subTitle,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyEmailOtp() async {
    if (emailOtpController.text.trim().length != 6) {
      Utils.showErrorSnackBar(context, "Enter valid OTP");
      return;
    }

    final body = {
      "signup_session_token":Utils.signUpSession,
      "otp": emailOtpController.text.trim(),
    };

    await _emailVerification(body);

    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.isEmailVerified) {
      setState(() {
        currentStep = VerificationType.phone;
      });

      startTimer();
    }
  }

  Future<void> _verifyPhoneOtp() async {
    if (phoneOtpController.text.trim().length != 6) {
      Utils.showErrorSnackBar(context, "Enter valid OTP");
      return;
    }

    final body = {
      "signup_session_token":Utils.signUpSession,
      "otp": phoneOtpController.text.trim(),
    };

    await _mobileNoVerification(body);
  }

  Future<void> _resendOtp(String type) async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();
      if (hasInternet) {
        ref.read(authProvider).setResentOtpLoading(hasInternet);
        if (!mounted) return;
        FocusScope.of(context).unfocus();
        await ref.read(resendOtpNotifier(type).future);
      } else {
        if (!mounted) return;
        Utils.showSnackBar(context, Strings.NO_INTERNET, Colors.red);
      }
    } catch (e) {
      ref.read(authProvider).setResentOtpLoading(false);
    } finally {
      ref.read(authProvider).setResentOtpLoading(false);
    }
  }

  Future<void> _emailVerification(Map<String, dynamic> body) async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();
      if (hasInternet) {
        ref.read(authProvider).setOtpVerifyLoading(hasInternet);
        if (!mounted) return;
        FocusScope.of(context).unfocus();
        await ref.read(verifyEmailNotifier(body).future);
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

  Future<void> _mobileNoVerification(Map<String, dynamic> body) async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();
      if (hasInternet) {
        ref.read(authProvider).setOtpVerifyLoading(hasInternet);
        if (!mounted) return;
        FocusScope.of(context).unfocus();
        await ref.read(verifyPhoneNotifier(body).future);
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
}
