import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/custom_container.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/provider/provider.dart';
import 'package:smedge/view/auth/auth_view_model.dart';

import '../../../common_files/custom_elevated_button.dart';
import '../../../common_files/network_checker.dart';
import '../../../common_files/support_widget.dart';
import '../../../common_files/utils.dart';
import '../../../constants/strings.dart';
import '../../../utils/router/app_routes.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).setContext(context);
    });
    super.initState();
  }

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isSecureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final authState = ref.watch(authProvider);
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
                              colors: [Colors.white, theme.colorScheme.primary],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Numbers.DOUBLE_NUMBER_4),
                      Text(
                        "Sign-In",
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
                              colors: [Colors.white, theme.colorScheme.primary],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Numbers.DOUBLE_NUMBER_6),
                  Text(
                    Strings.SIGN_IN_DETAILS,
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
                child: TextField(
                  autofocus: false,
                  controller: _emailController,
                  style: theme.textTheme.titleMedium,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: theme.textTheme.bodyMedium!.copyWith(
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: Numbers.DOUBLE_NUMBER_16),
            CustomContainer(
              padding: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  autofocus: false,
                  controller: _passwordController,
                  obscureText: isSecureText,
                  style: theme.textTheme.titleMedium,
                  textAlignVertical: TextAlignVertical.center,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: theme.textTheme.bodyMedium!.copyWith(
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isSecureText = !isSecureText;
                        });
                      },
                      icon: Icon(
                        isSecureText ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: Numbers.DOUBLE_NUMBER_16),
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  if (_emailController.text.isEmpty) {
                    Utils.showSnackBar(
                      context,
                      "Enter Registered Email",
                      Colors.red,
                    );
                    return;
                  }
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.forgotPassword,
                    arguments: _emailController.text,
                  );
                },
                child: Text(
                  "Forgot Password?",
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
              child: authState.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: CustomElevatedButton(
                        title: "Continue",
                        onPressed: () async {
                          final value = authState.validateSignIn(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          if (value == true) {
                            Map<String, dynamic> body = {
                              "email": _emailController.text,
                              "password": _passwordController.text,
                              "device_token": Utils.deviceId,
                            };
                            _signInNetworkCall(body);
                          }
                        },
                      ),
                    ),
            ),

            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "Don't have an account? ",
                    style: theme.textTheme.titleMedium,
                  ),
                  TextSpan(
                    text: "Sign Up",
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.pushReplacementNamed(context, AppRoutes.signUp);
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
      await ref.read(signInNotifier(body).future);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      ref.read(authProvider).setLoading(false);
    }
  }
}
