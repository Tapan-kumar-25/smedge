import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/constants/strings.dart';
import 'package:smedge/utils/router/app_routes.dart';

import '../../../common_files/custom_container.dart';
import '../../../common_files/custom_elevated_button.dart';
import '../../../common_files/network_checker.dart';
import '../../../common_files/support_widget.dart';
import '../../../provider/provider.dart';
import '../auth_view_model.dart';

class SetPasswordScreen extends ConsumerStatefulWidget {
  final String? previousScreen;

  const SetPasswordScreen({super.key, this.previousScreen = ""});

  @override
  ConsumerState<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends ConsumerState<SetPasswordScreen> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    Utils.getSignUpSession();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).setContext(context);
    });
    super.initState();
    passwordController.addListener(() {
      ref.read(authProvider).validatePassword(passwordController.text);
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
                      obscureText: !authState.isPasswordVisible,
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
                            authState.isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                           authState.togglePasswordVisibility();
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
                      obscureText: !authState.isConfirmPasswordVisible,
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
                            authState.isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                           authState.toggleConfirmPasswordVisibility();
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: buildValidationItem(
                            authState.hasUppercase,
                            "One uppercase letter",
                          ),
                        ),
                        Expanded(
                          child: buildValidationItem(
                            authState.hasDigit,
                            "One digit",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Numbers.DOUBLE_NUMBER_6),
                    Row(
                      children: [
                        Expanded(
                          child: buildValidationItem(
                            authState.hasSpecialCharacter,
                            "One special character",
                          ),
                        ),
                        Expanded(
                          child: buildValidationItem(
                            authState.hasMinLength,
                            "At least 8 characters",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
                  child: SizedBox(
                    width: double.infinity,
                    child: authState.isLoading
                        ? Center(child: CircularProgressIndicator())
                        : CustomElevatedButton(
                            title: "Confirm",
                            onPressed: () {
                              final password = passwordController.text.trim();
                              final confirmPassword = confirmPasswordController
                                  .text
                                  .trim();
                              if (password.isEmpty || confirmPassword.isEmpty) {
                                Utils.showSnackBar(
                                  context,
                                  "Please fill all fields",
                                  Colors.red,
                                );
                                return;
                              }
                              if (!authState.hasMinLength ||
                                  !authState.hasUppercase ||
                                  !authState.hasDigit ||
                                  !authState.hasSpecialCharacter) {
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
                                Map<String, dynamic> body = {
                                  "signup_session_token":Utils.signUpSession,
                                  "password":passwordController.text,
                                  "confirm_password":confirmPasswordController.text
                                };
                                _setPasswordNetworkCall(body);
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

  Future<void> _setPasswordNetworkCall(Map<String, dynamic> body) async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();

      if (!hasInternet) {
        Utils.showSnackBar(context, Strings.NO_INTERNET, Colors.red);
        return;
      }
      ref.read(authProvider).setLoading(hasInternet);
      await ref.read(signUpSetPasswordProvider(body).future);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      ref.read(authProvider).setLoading(false);
    }
  }
}
