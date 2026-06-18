import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:smedge/common_files/network_checker.dart';
import 'package:smedge/utils/router/app_routes.dart';
import 'package:smedge/view/auth/auth_view_model.dart';
import 'package:smedge/view/dash_board/screens/dashboard_screen.dart';

import '../../../common_files/custom_container.dart';
import '../../../common_files/custom_elevated_button.dart';
import '../../../common_files/support_widget.dart';
import '../../../common_files/utils.dart';
import '../../../constants/numbers.dart';
import '../../../constants/strings.dart';
import '../../../utils/global_utils.dart';
import '../../../provider/provider.dart';

class SignInOtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  const SignInOtpVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<SignInOtpVerificationScreen> createState() => _SignInOtpVerificationScreenState();
}

class _SignInOtpVerificationScreenState extends ConsumerState<SignInOtpVerificationScreen> {
  final pinController = TextEditingController();
  Timer? _timer;
  int _seconds = 60;
  bool isResendVisible = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).setContext(context);
    });
    fetchToken();
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() async {
    _seconds = 60;
    isResendVisible = false;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (time) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          isResendVisible = true;
        });
      }
    });
  }

  Future<void> fetchToken()async{
    await Utils.getSignInToken();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final pinTheme = PinTheme(
      width: 60,
      height: 60,
      textStyle: theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700),
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
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.15),
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
                                      theme.colorScheme.primary,
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
                                      theme.colorScheme.primary,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Numbers.DOUBLE_NUMBER_6),
                        Text(
                          Strings.SIGN_IN_OTP_VERIFICATION,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                  Pinput(
                    length: 6,
                    controller: pinController,
                    autofocus: true,
                    defaultPinTheme: pinTheme,
                    focusedPinTheme: pinTheme,
                    submittedPinTheme: pinTheme,
                    separatorBuilder: (index) =>
                        SizedBox(width: Numbers.DOUBLE_NUMBER_12),
                    showCursor: true,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                  isResendVisible
                      ? GestureDetector(
                    onTap: () {
                      startTimer();
                      _resendOtp({"signin_session_token": Utils.signInToken,
                        "channel": "EMAIL"});
                    },
                    child: Text(
                      "Resend OTP",
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.red,
                        decorationThickness: 2,
                      ),
                    ),
                  )
                      : Text(
                    "00:${_seconds.toString().padLeft(2, '0')}",
                    style: theme.textTheme.titleMedium,
                  ),

                  Padding(
                    padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
                    child:authState.isLoading?Center(child: CircularProgressIndicator())
                        : SizedBox(
                      width: double.infinity,
                      child: CustomElevatedButton(
                        title: "Next",
                        onPressed: () {
                          if (pinController.text.isEmpty) {
                            Utils.showSnackBar(
                              context,
                              "Please Enter OTP",
                              Colors.red,
                            );
                            return;
                          } else {
                            Map<String, dynamic> body = {
                              "signin_session_token": Utils.signInToken,
                              "otp": pinController.text,
                            };
                            _signInNetworkCall(body);
                          }
                        },
                      ),
                    ),
                  ),
                  SupportWidget(context: context),
                ],
              ),
            ),
          ),
          Visibility(
              visible: authState.isResentOtpLoading,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Numbers.DOUBLE_NUMBER_12),
                  color: Colors.black54,
                ),
                padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
                child: Row(
                  children: [
                    CircularProgressIndicator(),
                    Text("OTP Resending...",style: theme.textTheme.titleMedium!.copyWith(color: Colors.white),),
                  ],
                ),
              ))
        ],
      ),
    );
  }
  Future<void> _signInNetworkCall(Map<String, dynamic> body) async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();

      if (!hasInternet) {
        Utils.showErrorSnackBar(context, Strings.NO_INTERNET);
        return;
      }
      ref.read(authProvider).setLoading(hasInternet);
      await ref.read(signInOtpVerificationNotifier(body).future);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      ref.read(authProvider).setLoading(false);
    }
  }

  Future<void> _resendOtp(Map<String, dynamic> body) async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();
      if (hasInternet) {
        ref.read(authProvider).setResentOtpLoading(hasInternet);
        if (!mounted) return;
        FocusScope.of(context).unfocus();
        await ref.read(signInResendOtpNotifier(body).future);
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
}
