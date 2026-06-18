import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/custom_container.dart';
import 'package:smedge/common_files/custom_elevated_button.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/view/auth/auth_view_model.dart';

import '../../../common_files/network_checker.dart';
import '../../../common_files/support_widget.dart';
import '../../../constants/strings.dart';
import '../../../provider/provider.dart';
import '../../../utils/router/app_routes.dart';

class IdentityScreen extends ConsumerStatefulWidget {
  final String password;

  const IdentityScreen({super.key, required this.password});

  @override
  ConsumerState<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends ConsumerState<IdentityScreen> {
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  String countryCode = "";

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_){
      ref.read(authProvider).setContext(context);
    });
    Utils.getSignUpSession();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.1),
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
                            "Identity",
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
                        "Enter your personal details exactly as per your official documents.",
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
                      controller: nameController,
                      style: theme.textTheme.titleMedium,
                      inputFormatters: [LengthLimitingTextInputFormatter(21)],
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: "Full name as per passport",
                        hintStyle: theme.textTheme.titleMedium!.copyWith(
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                        suffixIcon: (nameController.text.isNotEmpty)
                            ? InkWell(
                                onTap: () {
                                  nameController.clear();
                                },
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Center(
                                    child: Container(
                                      height: 18,
                                      width: 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black12,
                                      ),
                                      child: Icon(Icons.clear, size: 12),
                                    ),
                                  ),
                                ),
                              )
                            : null,
                        suffixIconConstraints: BoxConstraints(
                          minHeight: 24,
                          minWidth: 24,
                        ),
                      ),
                    ),
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
                          initialSelection: "+971",
                          hideHeaderText: true,
                          onChanged: (value) {
                            authState.setCountryCode(value.dialCode ?? "+971");
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
                            controller: numberController,
                            keyboardType: TextInputType.number,
                            style: theme.textTheme.titleMedium,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
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
                Padding(
                  padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
                  child: SizedBox(
                    width: double.infinity,
                    child: authState.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : CustomElevatedButton(
                            title: "Continue",
                            onPressed: () {
                              if (nameController.text.isEmpty) {
                                Utils.showSnackBar(
                                  context,
                                  "Please enter name",
                                  Colors.red,
                                );
                                return;
                              }
                              if (numberController.text.isEmpty) {
                                Utils.showSnackBar(
                                  context,
                                  "Please enter mobile number",
                                  Colors.red,
                                );
                                return;
                              } else {
                                authState.setMobleNumber(numberController.text);
                                // Navigator.pushNamed(
                                //   authState.context,
                                //   AppRoutes.identityOtp,
                                //   arguments: numberController.text
                                // );
                                _signUpSaveProfileNetworkCall({
                                  "signup_session_token": Utils.signUpSession,
                                  "full_name": nameController.text,
                                  "password": widget.password,
                                  "phone_number":
                                      "${authState.countryCode}${numberController.text}",
                                });

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

  Future<void> _signUpSaveProfileNetworkCall(Map<String, dynamic> body) async {
    try {
      final hasInternet = await NetworkChecker.hasInternet();
      if (hasInternet) {
        ref.read(authProvider).setLoading(hasInternet);
        if (!mounted) return;
        FocusScope.of(context).unfocus();
        // await ref.read(signUpSaveProfile(body).future);
      } else {
        if (!mounted) return;
        Utils.showSnackBar(context, Strings.NO_INTERNET, Colors.red);
      }
    } catch (e) {
      ref.read(authProvider).setLoading(false);
    } finally {
      ref.read(authProvider).setLoading(false);
    }
  }
}
