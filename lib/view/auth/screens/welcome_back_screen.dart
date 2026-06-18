import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/custom_elevated_button.dart';
import 'package:smedge/common_files/support_widget.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/provider/provider.dart';
import 'package:smedge/utils/router/app_routes.dart';

class WelcomeBackScreen extends ConsumerStatefulWidget {
  const WelcomeBackScreen({super.key});

  @override
  ConsumerState<WelcomeBackScreen> createState() => _WelcomeBackScreenState();
}

class _WelcomeBackScreenState extends ConsumerState<WelcomeBackScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final authState = ref.watch(authProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      body: SafeArea(
        top: true,bottom: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                          "Welcome back!",
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
                      "Tapan",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  title: "Sign In",
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.signIn);
                  },
                ),
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              _OrDivider(),
              const SizedBox(height: 20),
              _UaePassButton(),
              const SizedBox(height: 48),
              SupportWidget(context: context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 1.5,
      color: const Color(0xFF1A2D5A).withOpacity(0.3),
    );
  }
}

class _SignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, AppRoutes.signIn);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCC1B1B),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Sign In',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFFD1D5DB))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: const Color(0xFFD1D5DB))),
      ],
    );
  }
}

class _UaePassButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF111827),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.symmetric(horizontal: Numbers.DOUBLE_NUMBER_10)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fingerprint,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Sign In with UAE PASS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
