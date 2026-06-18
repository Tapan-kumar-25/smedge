import 'package:flutter/material.dart';


class POSTermsConditionsScreen extends StatelessWidget {
  const POSTermsConditionsScreen({super.key});

  static const List<Map<String, String>> _sections = [
    {
      'title': '1.  Information Verification',
      'body':
      'By submitting this POS Financing application to Smedge, you authorize us to verify all provided business and personal information. You consent to Smedge obtaining credit reports, background checks, and financial history as required for the evaluation of this application.',
    },
    {
      'title': '2.  Accuracy of Details',
      'body':
      'You confirm that the business is in good standing and that the details provided are accurate. Any false representation may result in immediate rejection of the application, termination of services, or legal action under applicable laws.',
    },
    {
      'title': '3.  Data Processing',
      'body':
      'You agree to our standard platform terms of service and data processing agreement. We process your data in strict compliance with relevant local and international financial regulations. Your data will be securely stored and only shared with authorized financial partners and regulatory bodies as required.',
    },
    {
      'title': '4.  Financing Terms',
      'body':
      'Final approval and financing terms, including but not limited to interest rates, repayment schedules, and processing fees, are subject to a complete credit assessment and risk analysis by our underwriting team. Submission of this form does not guarantee financing approval.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title:Text(
          'Merchant Financing',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ) ,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _sections
                            .asMap()
                            .entries
                            .map((e) => _buildSection(
                          e.value['title']!,
                          e.value['body']!,
                          isLast: e.key == _sections.length - 1,
                        ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }


  // ─── Section item ────────────────────────────────────────────────────────────

  Widget _buildSection(String title, String body, {bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4B5563),
            height: 1.65,
          ),
        ),
        if (!isLast) ...[
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF3F4F6), thickness: 1),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  // ─── Bottom button ───────────────────────────────────────────────────────────

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () => Navigator.maybePop(context,true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A3A6B),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'I have read the T&Cs',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}