import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/custom_container.dart';
import 'package:smedge/common_files/custom_elevated_button.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/view/auth/auth_view_model.dart';
import 'package:smedge/view/auth/screens/term_and_conditions_screen.dart';

import '../../../common_files/custom_text_field.dart';
import '../../../common_files/network_checker.dart';
import '../../../constants/numbers.dart';
import '../../../constants/strings.dart';
import '../../../provider/provider.dart';

class CompanyDetailsScreen extends ConsumerStatefulWidget {
  const CompanyDetailsScreen({super.key});

  @override
  ConsumerState<CompanyDetailsScreen> createState() =>
      _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends ConsumerState<CompanyDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final companyNameController = TextEditingController();
  final websiteController = TextEditingController();
  final designationController = TextEditingController();
  final percentageController = TextEditingController();
  final turnoverController = TextEditingController();
  final uboController = TextEditingController();

  String? selectedValue;

  void onSelect(String value) {
    setState(() {
      if (selectedValue == value) {
        selectedValue = null;
      } else {
        selectedValue = value;
      }
    });
  }

  Widget buildRadio(String title, String value) {
    return GestureDetector(
      onTap: () {
        onSelect(value);
      },
      child: Row(
        children: [
          Radio<String>(
            visualDensity: VisualDensity(horizontal: -4, vertical: -4),
            value: value,
            groupValue: selectedValue,
            onChanged: (value) {
              onSelect(value!);
            },
          ),
          Text(title, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
  bool isTermAndCondition = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider).setContext(context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Numbers.DOUBLE_NUMBER_30),
              Text(Strings.COMPANY_DETAILS, style: theme.textTheme.titleLarge),
              SizedBox(height: Numbers.DOUBLE_NUMBER_6),
              Text(
                Strings.COMPANY_DETAILS_DATA,
                style: theme.textTheme.titleSmall,
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              CustomContainer(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextFormField(
                        controller: companyNameController,
                        label: "Company Name",
                        hintText: "Enter registered company name",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Company name is required";
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: Numbers.DOUBLE_NUMBER_6),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.orange),
                          SizedBox(width: Numbers.DOUBLE_NUMBER_6),
                          Text(
                            "As mentioned on your trade license",
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                      SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                      CustomTextFormField(
                        controller: websiteController,
                        label: "Website (Optional)",
                        hintText: "https://www.companyname.com",
                      ),
                      SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                      Text(
                        "Authorization Type",
                        textAlign: TextAlign.left,
                        style: theme.textTheme.titleMedium,
                      ),
                      SizedBox(height: Numbers.DOUBLE_NUMBER_6),
                      buildRadio(
                        "Shareholder / Owner / Partner",
                        "shareholder",
                      ),
                      buildRadio("Employee / POA Holder", "employee"),
                      SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                      (selectedValue == "shareholder")
                          ? Column(
                              children: [
                                CustomTextFormField(
                                  controller: percentageController,
                                  label: "Ownership Percentage",
                                  hintText: "Enter percentage",
                                  keyboardType: TextInputType.number,
                                  suffixIcon: Icon(
                                    Icons.percent,
                                    color: Colors.red,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter percentage";
                                    }
                                    final val = num.tryParse(value);
                                    if (val == null || val < 0 || val > 100) {
                                      return "Enter valid % (0-100)";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                                CustomTextFormField(
                                  controller: turnoverController,
                                  label: "Avg Monthly Turnover",
                                  hintText: "Eg: 500.00",
                                  keyboardType: TextInputType.number,
                                  prefixIcon: Image.asset(
                                    "assets/images/Durham_small.png",
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter turnover";
                                    }
                                    if (double.tryParse(value) == null) {
                                      return "Enter valid amount";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            )
                          : (selectedValue == "employee")
                          ? Column(
                              children: [
                                CustomTextFormField(
                                  controller: uboController,
                                  label:
                                      "UBO Name ( Ultimate Beneficial Owner )",
                                  hintText: "Enter UBO Name",
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter UBO Name";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                                CustomTextFormField(
                                  controller: percentageController,
                                  label: "Share Holder Percentage",
                                  hintText: "Enter percentage",
                                  keyboardType: TextInputType.number,
                                  suffixIcon: Icon(
                                    Icons.percent,
                                    color: Colors.red,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Enter percentage";
                                    }
                                    final val = num.tryParse(value);
                                    if (val == null || val < 0 || val > 100) {
                                      return "Enter valid % (0-100)";
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            )
                          : const SizedBox(),

                      SizedBox(height: Numbers.DOUBLE_NUMBER_16),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    visualDensity: const VisualDensity(vertical: 0),
                    value: isTermAndCondition, // authState.isChecked,
                    onChanged: (val) {
                      if (authState.isChecked == false) {
                        Utils.showSnackBar(
                          context,
                          "Please accept terms first",
                          Colors.red,
                        );
                        return;
                      }

                      setState(() {
                        isTermAndCondition = val!;
                      });
                    },
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TermsConditionsScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: RichText(
                          text: const TextSpan(
                            text: "I agree to the ",
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                text: "Terms & Conditions.",
                                style: TextStyle(
                                  color: Colors.red,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(
                                text:
                                    "\nBy continuing, you confirm the information is accurate",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: Numbers.DOUBLE_NUMBER_16),
              SizedBox(
                width: double.infinity,
                child: authState.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : CustomElevatedButton(
                        title: "Continue",
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) return;

                          if (!isTermAndCondition) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please accept Terms & Conditions",
                                ),
                              ),
                            );
                            return;
                          }
                          Map<String, dynamic> body =
                              (selectedValue == "shareholder")
                              ? {
                                  "signup_session_token": Utils.signUpSession,
                                  "company_name": companyNameController.text,
                                  "website": websiteController.text,
                                  "authorization_type":
                                      "SHAREHOLDER_OWNER_PARTNER",
                                  "ownership_percentage":
                                      percentageController.text,
                                  "avg_monthly_turnover":
                                      turnoverController.text,
                                  "consent_accepted": isTermAndCondition,
                                }
                              : {
                                  "signup_session_token": Utils.signUpSession,
                                  "company_name": companyNameController.text,
                                  "website": websiteController.text,
                                  "authorization_type": "EMPLOYEE_POA_HOLDER",
                                  "consent_accepted": isTermAndCondition,
                                };
                          _signUpSaveProfileNetworkCall(body);
                        },
                      ),
              ),
            ],
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
        await ref.read(saveCompanyDetails(body).future);
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
