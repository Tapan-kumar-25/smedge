import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/utils/router/app_routes.dart';
import 'package:smedge/provider/provider.dart';

import '../../../common_files/custom_container.dart';
import '../../../common_files/custom_elevated_button.dart';
import '../../../common_files/network_checker.dart';
import '../../../common_files/support_widget.dart';
import '../../../constants/numbers.dart';
import '../../../constants/strings.dart';
import '../../../utils/global_utils.dart';
import '../auth_view_model.dart';

class IdentityOtpScreen extends ConsumerStatefulWidget {
  const IdentityOtpScreen({super.key});

  @override
  ConsumerState<IdentityOtpScreen> createState() => _IdentityOtpScreenState();
}

class _IdentityOtpScreenState extends ConsumerState<IdentityOtpScreen> {
  final otpController = TextEditingController();
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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.primary),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
            child: Center(
              child: Column(
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
                          "We’ve sent a one-time password to your phone number. Enter it below to verify and continue.",
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomContainer(
                          padding: 2,
                          child: CountryCodePicker(
                            padding: EdgeInsetsGeometry.zero,
                            initialSelection: authState.countryCode,
                            hideHeaderText: true,
                            onChanged: (value) {
                              // authState.setCountryCode(value.dialCode ?? "+971");
                            },
                            flagDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1),
                            ),
                            pickerStyle: PickerStyle.bottomSheet,
                          ),
                        ),
                      ),
                      SizedBox(width: Numbers.DOUBLE_NUMBER_10),
                      Expanded(
                        flex: 6,
                        child: CustomContainer(
                          padding: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextFormField(
                              initialValue: authState.mobileNumber,
                              readOnly: true,
                              style: theme.textTheme.titleMedium,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                hintText: "Mobile number",
                                hintStyle: theme.textTheme.titleMedium!.copyWith(
                                  color: Colors.grey,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                  Pinput(
                    length: 6,
                    controller: otpController,
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
                            _resendOtp();
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
                        title: "Continue",
                        onPressed: () {
                          String pin = otpController.text.trim();
                          if (pin.isEmpty) {
                            Utils.showSnackBar(
                              context,
                              "Please enter PIN",
                              Colors.red,
                            );
                          } else if (pin.length != 6) {
                            Utils.showSnackBar(
                              context,
                              "PIN must be 6 digits",
                              Colors.red,
                            );
                          } else {

                            _signUpOtpVerifyNetworkCall(otpController.text);
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
    );
  }
  Future<void> _signUpOtpVerifyNetworkCall(String otp) async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();
      if (hasInternet) {
        ref.read(authProvider).setOtpVerifyLoading(hasInternet);
        if (!mounted) return;
        FocusScope.of(context).unfocus();
        // await ref.read(signUpPhoneVerification(otp).future);
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
        await ref.read(resendOtpNotifier("SMS").future);
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
