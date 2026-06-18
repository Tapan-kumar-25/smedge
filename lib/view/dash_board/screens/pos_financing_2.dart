import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smedge/common_files/custom_elevated_button.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/view/dash_board/screens/pos_financing_3.dart';

import '../../../provider/provider.dart';

class POSFinancingScreen2 extends ConsumerStatefulWidget {
  const POSFinancingScreen2({super.key});

  @override
  ConsumerState<POSFinancingScreen2> createState() =>
      _POSFinancingScreen2State();
}

class _POSFinancingScreen2State extends ConsumerState<POSFinancingScreen2> {
  static const _kStepTitles = ['COMPANY DETAILS', 'STEP 2', 'STEP 3'];
  String? selectedIndustryType;
  String? selectedSubType;

  bool isProfitableYes = true;
  bool hasOutstandingLoansYes = true;
  bool hasCompanyCreditCardYes = true;

  final TextEditingController _monthlyRevenueController =
      TextEditingController();
  final TextEditingController _emiController = TextEditingController();
  final TextEditingController _cardLimitController = TextEditingController();

  final List<String> industryTypes = [
    'Retail',
    'Wholesale',
    'Manufacturing',
    'Services',
    'Technology',
    'Healthcare',
    'Food & Beverage',
  ];

  final List<String> subTypes = [
    'Small Business',
    'Medium Enterprise',
    'Large Enterprise',
    'Startup',
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardStateProvider).setContext(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    _monthlyRevenueController.dispose();
    _emiController.dispose();
    _cardLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardStateProvider);
    final theme = Theme.of(context);
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
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
        body: Column(
          children: [
            _buildStepIndicator(dashboardState.currentIndex),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    _buildBusinessProfileCard(),
                    const SizedBox(height: 12),
                    _buildFinancialOverviewCard(),
                    const SizedBox(height: 12),
                    _buildLiabilitiesCard(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildProceedButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1A3A6B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Merchant Financing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEF7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF1A3A6B),
                  size: 20,
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '4',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    final theme = Theme.of(context);
    return Container(
      padding:  EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Color(0xffFBBC05),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(Numbers.DOUBLE_NUMBER_10),
                      topLeft: Radius.circular(Numbers.DOUBLE_NUMBER_10),
                      bottomRight: Radius.circular(Numbers.DOUBLE_NUMBER_10)
                  ),
                ),
                child: const Text(
                  'Step 2 of 3',
                  style: TextStyle(
                    color: Color(0xFF856404),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
               Text(
                'BUSINESS INFORMATION',
                style:  theme.textTheme.titleSmall?.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_kStepTitles.length, (i) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: i < _kStepTitles.length - 1 ? 4 : 0,
                  ),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i == 0
                        ? Colors.green
                        : i == 1
                        ? Theme.of(context).colorScheme.primary
                        : Color(0xffDBEAFD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessProfileCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.handshake_outlined,
            title: 'Business Profile',
            subtitle: 'Manage your business info',
          ),
          const SizedBox(height: 20),
          _buildLabel('INDUSTRY TYPE'),
          const SizedBox(height: 6),
          _buildDropdown(
            hint: 'Select Industry Type',
            value: selectedIndustryType,
            items: industryTypes,
            onChanged: (val) => setState(() => selectedIndustryType = val),
          ),
          const SizedBox(height: 16),
          _buildLabel('SUB TYPE'),
          const SizedBox(height: 6),
          _buildDropdown(
            hint: 'Select Sub Type',
            value: selectedSubType,
            items: subTypes,
            onChanged: (val) => setState(() => selectedSubType = val),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverviewCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.bar_chart_rounded,
            title: 'Financial Overview',
            subtitle:
                'Provide accurate financial details to expedite\nyour approval process',
          ),
          const SizedBox(height: 20),
          const Text(
            'Average Monthly Revenue',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildCurrencyTextField(controller: _monthlyRevenueController),
          const SizedBox(height: 16),
          const Text(
            'Are you currently profitable?',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildToggle(
            isYes: isProfitableYes,
            onToggle: (val) => setState(() => isProfitableYes = val),
          ),
        ],
      ),
    );
  }

  Widget _buildLiabilitiesCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Liabilities',
            subtitle: 'Track your debts',
          ),
          const SizedBox(height: 20),
          const Text(
            'Any outstanding loans?',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildToggle(
            isYes: hasOutstandingLoansYes,
            onToggle: (val) => setState(() => hasOutstandingLoansYes = val),
          ),
          const SizedBox(height: 16),
          const Text(
            'Current EMI obligations',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildCurrencyTextField(controller: _emiController),
          const SizedBox(height: 16),
          const Text(
            'Do you have any Company Credit Cards?',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildToggle(
            isYes: hasCompanyCreditCardYes,
            onToggle: (val) => setState(() => hasCompanyCreditCardYes = val),
          ),
          const SizedBox(height: 16),
          const Text(
            'What is the card limit?',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildCurrencyTextField(controller: _cardLimitController),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF1A3A6B), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B7280),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              hint,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6B7280),
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          borderRadius: BorderRadius.circular(10),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildCurrencyTextField({required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Color(0xFFD1D5DB))),
            ),
            child: SvgPicture.asset("assets/svg/dirham.svg",height: 10),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required bool isYes,
    required ValueChanged<bool> onToggle,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF2F7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: isYes ? 0 : width / 2,
                child: Container(
                  width: width / 2,
                  height: 44,
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  _toggleItem("YES", true, isYes, onToggle),
                  _toggleItem("NO", false, isYes, onToggle),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _toggleItem(
      String label,
      bool value,
      bool isYes,
      ValueChanged<bool> onToggle,
      ) {
    final selected = isYes == value;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (isYes != value) onToggle(value);
        },
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected
                  ? const Color(0xFF1A3A6B)
                  : const Color(0xFF9CA3AF),
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildProceedButton() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: SizedBox(
        width: double.infinity,
        child: CustomElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => POSFinancingDocumentsScreen()),
            );
          },

          title: 'Proceed',
        ),
      ),
    );
  }
}
