import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/constants/strings.dart';
import 'package:smedge/utils/router/app_routes.dart';

import '../../../common_files/custom_container.dart';
import '../../../common_files/custom_elevated_button.dart';
import '../../../common_files/support_widget.dart';
import '../../../provider/provider.dart';

class SetPasswordScreen extends ConsumerStatefulWidget {
  final String? previousScreen;

  const SetPasswordScreen({super.key, this.previousScreen = ""});

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasDigit = false;
  bool hasSpacialCharacter = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).setContext(context);
    });
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
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.06),
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
                            "Set Your Password",
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
                        Strings.CREATE_A_SECURE_PASSWORD,
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
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      style: theme.textTheme.titleMedium,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: theme.textTheme.titleMedium!.copyWith(
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                CustomContainer(
                  padding: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: confirmPasswordController,
                      obscureText: !isConfirmPasswordVisible,
                      style: theme.textTheme.titleMedium,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        hintStyle: theme.textTheme.titleMedium!.copyWith(
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                buildValidationItem(hasMinLength, "At least 8 characters"),
                const SizedBox(height: 6),
                buildValidationItem(hasUppercase, "One uppercase letter"),
                const SizedBox(height: 6),
                buildValidationItem(hasDigit, "One digit"),
                const SizedBox(height: 6),
                buildValidationItem(hasSpacialCharacter, "One special character"),
                Padding(
                  padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
                  child: SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      title: "Confirm",
                      onPressed: () {
                        final password = passwordController.text.trim();
                        final confirmPassword = confirmPasswordController.text
                            .trim();
                        if (password.isEmpty || confirmPassword.isEmpty) {
                          Utils.showSnackBar(
                            context,
                            "Please fill all fields",
                            Colors.red,
                          );
                          return;
                        }
                        if (!hasMinLength || !hasUppercase || !hasDigit || !hasSpacialCharacter) {
                          Utils.showSnackBar(
                            context,
                            "Password does not meet requirements",
                            Colors.red,
                          );
                          return;
                        }
                        if (password != confirmPassword) {
                          Utils.showSnackBar(
                            context,
                            "Passwords do not match",
                            Colors.red,
                          );
                          return;
                        }

                        /// API call
                        if (widget.previousScreen == "") {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.identity,
                            arguments: passwordController.text,
                          );
                        } else {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.signIn,
                          );
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
      ),
    );
  }

  Widget buildValidationItem(bool isValid, String text) {
    return Row(
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
        Text(
          text,
          style: TextStyle(color: isValid ? Colors.green : Colors.red),
        ),
      ],
    );
  }
}
