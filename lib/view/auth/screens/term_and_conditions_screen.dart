import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/custom_container.dart';
import 'package:smedge/common_files/custom_elevated_button.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/provider/provider.dart';

class TermsConditionsScreen extends ConsumerWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    return Scaffold(
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: Numbers.DOUBLE_NUMBER_16),
          child: Column(
            children: [
               SizedBox(height: Numbers.DOUBLE_NUMBER_20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Terms & Conditions",
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
               SizedBox(height: Numbers.DOUBLE_NUMBER_8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Please review and accept our\nTerms & Conditions to continue using Smedge Services.",
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: Colors.blue,
                  ),
                ),
              ),
               SizedBox(height: Numbers.DOUBLE_NUMBER_20),
              Expanded(
                child: CustomContainer(
                  padding:  Numbers.DOUBLE_NUMBER_16,

                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        TermsItem(
                          title: "1. Account Usage",
                          description:
                          "By accessing Smedge, you agree to use our financial services responsibly and in compliance with all applicable laws. Unauthorized use may result in account termination.",
                        ),
                        TermsItem(
                          title: "2. Data Privacy & Security",
                          description:
                          "We employ bank-grade encryption to protect your sensitive data. We do not sell your personal information to third parties. For more details, review our Privacy Policy.",
                        ),
                        TermsItem(
                          title: "3. Financial Services Terms",
                          description:
                          "Smedge provides a platform for financial management. We are not a bank but partner with licensed banking institutions to deliver secure infrastructure.",
                        ),
                        TermsItem(
                          title: "4. Regulatory Compliance",
                          description:
                          "Your account is subject to anti-money laundering (AML) and know-your-customer (KYC) regulations. We may request additional documentation periodically.",
                        ),
                        TermsItem(
                          title: "5. Limitation of Liability",
                          description:
                          "Smedge is not liable for indirect, incidental, or consequential damages arising from the use or inability to use our services and platform.",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
               SizedBox(height: Numbers.DOUBLE_NUMBER_20),
              SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  onPressed: () {
                    authState.setTermAndCondition(true);
                    Navigator.pop(context);
                  },

                  title: "I have read the T&Cs",
                ),
              ),
              SizedBox(height: Numbers.DOUBLE_NUMBER_20),
            ],
          ),
        ),
      ),
    );
  }
}

class TermsItem extends StatelessWidget {
  final String title;
  final String description;

  const TermsItem({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13.5,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
