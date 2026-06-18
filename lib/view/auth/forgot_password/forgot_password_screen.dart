import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:smedge/common_files/custom_container.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/utils/router/app_routes.dart';
import 'package:smedge/provider/provider.dart';

import '../../../common_files/custom_elevated_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final String email;

  const ForgotPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final pinController = TextEditingController();
  Timer? _timer;
  int _seconds = 60;
  bool isResendVisible = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).setContext(context);
    });
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.primary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.05),
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
                      "We’ve sent a one-time password to your email. Enter it below to verify and continue.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              CustomContainer(
                padding: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextFormField(
                    readOnly: true,
                    initialValue: widget.email,
                    style: theme.textTheme.titleMedium,
                    textAlignVertical: TextAlignVertical.top,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText:  "Email",
                      hintStyle: theme.textTheme.bodyMedium!.copyWith(color: Colors.grey,),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              Pinput(
                length: 4,
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
                  // call resend API here
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
                child: SizedBox(
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
                        Navigator.pushReplacementNamed(context, AppRoutes.setPassword,arguments: "forgotPassword");
                      }
                    },
                  ),
                ),
              ),

              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Need help?",
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: "We’re here for you",
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_8),
              Text(
                "Choose a support option to connect with our team instantly",
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
