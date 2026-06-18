import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/utils/router/app_routes.dart';
import 'package:smedge/provider/provider.dart';

import '../../../common_files/network_checker.dart';
import '../../../common_files/utils.dart';
import '../../../constants/strings.dart';
import '../../../utils/global_utils.dart';
import '../auth_view_model.dart';

class OnBoardingScreen extends ConsumerStatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  ConsumerState<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends ConsumerState<OnBoardingScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).setContext(context);
    });
    Utils.getSignUpSession();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final carouselHeight = isLandscape ? size.height * 0.7 : size.height * 0.5;

    return Scaffold(
      body: SafeArea(
        top: true,
        child: Padding(
          padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CarouselSlider(
                        items: introImageList.map((value) {
                          return SizedBox(
                            width: double.infinity,
                            child: Image.asset(value, fit: BoxFit.contain),
                          );
                        }).toList(),
                        options: CarouselOptions(
                          autoPlay: true,
                          viewportFraction: 1,
                          height: carouselHeight,
                          initialPage: authState.currentIndex,
                          autoPlayCurve: Curves.linear,
                          autoPlayAnimationDuration: const Duration(
                            milliseconds: 300,
                          ),
                          onPageChanged: (index, reason) {
                            setState(() {
                              authState.setCurrentIndex(index);
                            });
                          },
                        ),
                      ),

                      SizedBox(height: Numbers.DOUBLE_NUMBER_10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: introImageList.asMap().entries.map((value) {
                          bool isActive = authState.currentIndex == value.key;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(
                              horizontal: Numbers.DOUBLE_NUMBER_4,
                            ),
                            height: Numbers.DOUBLE_NUMBER_8,
                            width: isActive
                                ? Numbers.DOUBLE_NUMBER_18
                                : Numbers.DOUBLE_NUMBER_8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? theme.colorScheme.primary
                                  : Colors.blue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(
                                Numbers.DOUBLE_NUMBER_10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: Numbers.DOUBLE_NUMBER_12),

                      authState.currentIndex == 0
                          ? _intro1(
                              context,
                              "POS Financing for ",
                              "Growing Businesses",
                              null,
                              Strings.GET_ACCESS,
                            )
                          : _intro1(
                              context,
                              "Open an ",
                              "SME Account.",
                              "Simplified",
                              Strings.OPEN_ACCOUNT,
                            ),
                      SizedBox(height: Numbers.DOUBLE_NUMBER_16),

                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: authState.isLoading?Center(child: CircularProgressIndicator(),): ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 6,
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Numbers.DOUBLE_NUMBER_10,
                          ),
                        ),
                      ),
                      onPressed: () {
                        if(Utils.signUpSession == ""){
                          Navigator.pushNamed(
                            context,
                            AppRoutes.signUp,
                          );
                        }else{
                        _signUpNetworkCall();}
                      },
                      child: Text(
                        "Sign Up",
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: Numbers.DOUBLE_NUMBER_16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 6,
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Numbers.DOUBLE_NUMBER_10,
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.signIn,
                        );
                      },
                      child: Text(
                        "Sign In",
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    elevation: 6,
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Numbers.DOUBLE_NUMBER_10,
                      ),
                    ),
                  ),
                  icon: Icon(Icons.fingerprint, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.signUpWithUaePass);
                  },
                  label: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: Numbers.DOUBLE_NUMBER_12,
                    ),
                    child: Text(
                      "Sign up with UAE PASS",
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _intro1(
    BuildContext context,
    String title1,
    String title2,
    String? title3,
    String description,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: title1, style: theme.textTheme.titleMedium),
              TextSpan(
                text: title2,
                style: theme.textTheme.titleMedium!.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              if (title3 != null)
                TextSpan(text: " $title3", style: theme.textTheme.titleMedium),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Numbers.DOUBLE_NUMBER_10),
        Text(
          description,
          style: theme.textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  Future<void> _signUpNetworkCall() async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();
      if (hasInternet) {
        ref.read(authProvider).setLoading(hasInternet);
        if(!mounted) return;
        FocusScope.of(context).unfocus();
        await ref.read(resumeSignupNotifier.future);
      }else{
        if(!mounted) return;
        Utils.showSnackBar(context, Strings.NO_INTERNET, Colors.red);
      }

    } catch (e) {
      ref.read(authProvider).setLoading(false);
    }finally{
      ref.read(authProvider).setLoading(false);
    }
  }
}
