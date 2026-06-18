import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:smedge/common_files/custom_container.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/provider/provider.dart';
import 'package:smedge/utils/router/app_routes.dart';

import '../../../common_files/custom_elevated_button.dart';
import '../../../common_files/network_checker.dart';
import '../../../common_files/support_widget.dart';
import '../../../constants/strings.dart';
import '../auth_view_model.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String enteredValue;

  const OtpScreen({super.key, required this.enteredValue});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final pinController = TextEditingController();
  Timer? _timer;
  int _seconds = 60;
  bool isResendVisible = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).setContext(context);
    });
    Utils.getSignUpSession();
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
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
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(child: Image.asset("assets/images/sign_up.png")),

                        SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
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
                          "We’ve sent a one-time password to your email. Enter it below to verify and continue.",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall,
                        ),
                        SizedBox(height: Numbers.DOUBLE_NUMBER_20),
                        CustomContainer(
                          padding: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextFormField(
                              readOnly: true,
                              initialValue: widget.enteredValue,
                              style: theme.textTheme.titleMedium,
                              decoration: InputDecoration(border: InputBorder.none),
                            ),
                          ),
                        ),
                        SizedBox(height: Numbers.DOUBLE_NUMBER_20),
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
                        SizedBox(height: Numbers.DOUBLE_NUMBER_20),
                        isResendVisible
                            ? GestureDetector(
                                onTap: () {
                                  startTimer();
                                  _resendOtp();
                                },
                                child: Text(
                                  "Resend OTP",
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : Text(
                                "00:${_seconds.toString().padLeft(2, '0')}",
                                style: theme.textTheme.titleMedium,
                              ),
                        SizedBox(height: Numbers.DOUBLE_NUMBER_20),
                        SizedBox(
                          width: double.infinity,
                          child: authState.isOtpVerifyLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary,
                                  ),
                                )
                              : CustomElevatedButton(
                                  title: "Next",
                                  onPressed: () {
                                    if (pinController.text.isEmpty) {
                                      Utils.showSnackBar(
                                        context,
                                        "Please Enter OTP",
                                        Colors.red,
                                      );
                                      return;
                                    }
                                    _signUpOtpVerifyNetworkCall(pinController.text);
                                  },
                                ),
                        ),
                        SizedBox(height: Numbers.DOUBLE_NUMBER_20),
                        SupportWidget(context: context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
                visible: authState.isResentOtpLoading,
                child: CustomContainer(
                padding: Numbers.DOUBLE_NUMBER_16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: Numbers.DOUBLE_NUMBER_20,
                      child: CircularProgressIndicator(),
                    ),
                    Flexible(
                        flex: 6,
                        child: Text("Resending OTP...",style:theme.textTheme.titleLarge)),
                  ],
                )))
          ],
        ),
      ),
    );
  }

  Future<void> _signUpOtpVerifyNetworkCall(String otp) async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();
      if (hasInternet) {
        ref.read(authProvider).setOtpVerifyLoading(hasInternet);
        if (!mounted) return;
        FocusScope.of(context).unfocus();
        // await ref.read(signUpEmailVerification(otp).future);
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

  Future<void> _resendOtp() async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();
      if (hasInternet) {
        ref.read(authProvider).setResentOtpLoading(hasInternet);
        if (!mounted) return;
        FocusScope.of(context).unfocus();
        await ref.read(resendOtpNotifier("EMAIL").future);
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
