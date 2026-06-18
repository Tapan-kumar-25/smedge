import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/custom_container.dart';
import 'package:smedge/common_files/custom_elevated_button.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/constants/strings.dart';
import 'package:smedge/provider/provider.dart';
import 'package:smedge/view/auth/auth_view_model.dart';

import '../../../common_files/network_checker.dart';
import '../../../common_files/support_widget.dart';
import '../../../utils/router/app_routes.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasDigit = false;
  bool hasSpacialCharacter = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).setContext(context);
    });
    Utils.getSignUpSession();
    super.initState();
    passwordController.addListener(() {
      final value = passwordController.text;
      setState(() {
        hasMinLength = value.length >= 8;
        hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
        hasDigit = RegExp(r'[0-9]').hasMatch(value);
        hasSpacialCharacter = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
      });
    });
  }

  @override
  void dispose() {
    numberController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final authState = ref.watch(authProvider);
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.1),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(child: Image.asset("assets/images/sign_up.png")),
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
                          "Sign-Up",
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
                      Strings.ENTER_MAIL_TO_SECURE_YOUR_ACCOUNT,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              _customTextField(
                context: context,
                controller: nameController,
                textType: TextInputType.text,
                hint: 'Name',
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              _customTextField(
                context: context,
                controller: emailController,
                textType: TextInputType.emailAddress,
                hint: 'Email',
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
                        initialSelection: "+971",
                        hideHeaderText: true,
                        onChanged: (value) {
                          authState.setCountryCode(value.dialCode ?? "+971");
                          authState.setNationality(value.code ?? "AE");
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
                    child: _customTextField(
                      context: context,
                      controller: numberController,
                      textType: TextInputType.number,
                      hint: "Mobile number",
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              _customTextField(
                context: context,
                controller: passwordController,
                textType: TextInputType.emailAddress,
                hint: "Password",
                obscureText: !isPasswordVisible,
                alignment: TextAlignVertical.center,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),

              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              _customTextField(
                context: context,
                controller: confirmPasswordController,
                textType: TextInputType.emailAddress,
                hint: "Confirm Password",
                obscureText: !isConfirmPasswordVisible,
                alignment: TextAlignVertical.center,
                suffixIcon: IconButton(
                  icon: Icon(
                    isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: buildValidationItem(
                          hasUppercase,
                          "One uppercase letter",
                        ),
                      ),
                      Expanded(
                        child: buildValidationItem(hasDigit, "One digit"),
                      ),
                    ],
                  ),
                  SizedBox(height: Numbers.DOUBLE_NUMBER_6),
                  Row(
                    children: [
                      Expanded(
                        child: buildValidationItem(
                          hasSpacialCharacter,
                          "One special character",
                        ),
                      ),
                      Expanded(
                        child: buildValidationItem(
                          hasMinLength,
                          "At least 8 characters",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
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
                            final isValid = authState.validateSignUp(
                              name: nameController.text,
                              email: emailController.text,
                              number: numberController.text,
                              password: passwordController.text,
                              confirmPassword: confirmPasswordController.text,
                            );
                            if (isValid == true) {
                              authState.setSignUpData({
                                "email": emailController.text,
                                "number":
                                    "${authState.countryCode}${numberController.text}",
                              });
                              final body = {
                                "name": nameController.text.trim(),
                                "email": emailController.text.trim(),
                                "phone_number":
                                    "${authState.countryCode}${numberController.text.trim()}",
                                "password": passwordController.text.trim(),
                                "confirm_password": confirmPasswordController
                                    .text
                                    .trim(),
                                "nationality": authState.nationality,
                                "gender": "MALE",
                                "date_of_birth": "1990-05-15",
                              };
                              _signUpNetworkCall(body);
                            }
                          },
                        ),
                      ),
              ),

              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Already an user? ",
                      style: theme.textTheme.titleMedium,
                    ),
                    TextSpan(
                      text: "Sign In",
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.signIn,
                          );
                        },
                    ),
                  ],
                ),
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              SupportWidget(context: context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customTextField({
    required BuildContext context,
    required TextEditingController controller,
    required TextInputType textType,
    required String hint,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
    TextAlignVertical alignment = TextAlignVertical.top,
  }) {
    final theme = Theme.of(context);
    return CustomContainer(
      padding: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextField(
          autofocus: false,
          obscureText: obscureText,
          controller: controller,
          style: theme.textTheme.titleMedium,
          textAlignVertical: alignment,
          keyboardType: textType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            hintText: hint,
            hintStyle: theme.textTheme.bodySmall!.copyWith(
              fontSize: Numbers.DOUBLE_NUMBER_15,
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget buildValidationItem(bool isValid, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 20,
          width: 20,
          decoration: BoxDecoration(
            color: isValid ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isValid ? Icons.check : Icons.close,
            size: 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: isValid ? Colors.green : Colors.red),
          ),
        ),
      ],
    );
  }

  Future<void> _signUpNetworkCall(Map<String, dynamic> body) async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();

      if (!hasInternet) {
        Utils.showSnackBar(context, Strings.NO_INTERNET, Colors.red);
        return;
      }
      debugPrint("STEP 1");
      ref.read(authProvider).setLoading(hasInternet);
      final emailResponse = await ref.read(
        checkEmailNotifier(emailController.text.trim()).future,
      );
      debugPrint("STEP 2");
      debugPrint("Email available = ${emailResponse.data?.available}");
      if (emailResponse.data?.available == false) {
        Utils.showErrorSnackBar(context, "Email already registered");
        return;
      }
      debugPrint("STEP 4 - Calling phone API");
      final phoneResponse = await ref.read(
        checkPhoneNotifier(
          "${ref.read(authProvider).countryCode}${numberController.text.trim()}",
        ).future,
      );
      debugPrint("Phone available = ${phoneResponse.data?.available}");

      if (phoneResponse.data?.available == false) {
        Utils.showErrorSnackBar(context, "Phone number already registered");
        return;
      }
      debugPrint("=====================");
      await ref.read(emailSignUpNotifier(body).future);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      ref.read(authProvider).setLoading(false);
    }
  }
}
