import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smedge/common_files/custom_container.dart';
import 'package:smedge/common_files/custom_elevated_button.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:smedge/utils/router/app_routes.dart';

import '../../common_files/custom_toggle_button.dart';

enum ProductStatus { disbursed, processing, rejected }

class MyProduct {
  final String productName;
  final String productId;
  final String companyName;
  final double amount;
  final String amountLabel;
  final double monthlyPayment;
  final DateTime nextPaymentDate;
  final int totalInstallments;
  final int paidInstallments;
  final ProductStatus status;

  const MyProduct({
    required this.productName,
    required this.productId,
    required this.companyName,
    required this.amount,
    required this.amountLabel,
    required this.monthlyPayment,
    required this.nextPaymentDate,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.status,
  });

  int get remainingInstallments => totalInstallments - paidInstallments;

  double get repaymentProgress =>
      totalInstallments == 0 ? 0 : paidInstallments / totalInstallments;

  int get repaymentPercent => (repaymentProgress * 100).round();
}

final List<MyProduct> posProducts = [
  MyProduct(
    productName: 'POS Financing',
    productId: 'PS - 12345',
    companyName: 'Edwin Trading LLC',
    amount: 5900.00,
    amountLabel: 'remaining',
    monthlyPayment: 12965,
    nextPaymentDate: DateTime(2026, 5, 1),
    totalInstallments: 6,
    paidInstallments: 2,
    status: ProductStatus.disbursed,
  ),
  MyProduct(
    productName: 'POS Financing',
    productId: 'PS - 12345',
    companyName: 'ZhongFin Retail Trading..',
    amount: 50000.00,
    amountLabel: 'requested',
    monthlyPayment: 12965,
    nextPaymentDate: DateTime(2026, 1, 17),
    totalInstallments: 8,
    paidInstallments: 0,
    status: ProductStatus.processing,
  ),
  MyProduct(
    productName: 'POS Financing',
    productId: 'PS - 67890',
    companyName: 'Delta Merchants LLC',
    amount: 30000.00,
    amountLabel: 'requested',
    monthlyPayment: 5000,
    nextPaymentDate: DateTime(2026, 3, 10),
    totalInstallments: 6,
    paidInstallments: 0,
    status: ProductStatus.rejected,
  ),
];

final List<MyProduct> smeProducts = [
  MyProduct(
    productName: 'SME Account',
    productId: 'SME - 00123',
    companyName: 'Edwin Trading LLC',
    amount: 120000.00,
    amountLabel: 'remaining',
    monthlyPayment: 8000,
    nextPaymentDate: DateTime(2026, 6, 1),
    totalInstallments: 24,
    paidInstallments: 10,
    status: ProductStatus.disbursed,
  ),
];

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  int _selectedTab = 0;

  List<MyProduct> get _currentProducts =>
      _selectedTab == 0 ? posProducts : smeProducts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: const SizedBox(),
        centerTitle: true,
        surfaceTintColor: theme.scaffoldBackgroundColor,
        title: Text(
          'My Products',
          style: theme.textTheme.titleMedium!.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
            child: CustomToggleButton(
              labels: ["POS Financing"," SME Account"],
              initialIndex: _selectedTab,
              onTap: (value) {
                setState(() => _selectedTab = value);
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _currentProducts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) =>
                  _productCard(_currentProducts[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(MyProduct product) {
    return CustomContainer(
      padding: Numbers.DOUBLE_NUMBER_12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.credit_card_outlined,
                  color: Color(0xFF1A3A6B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.productId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A8FAE),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _statusBadge(product.status),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/svg/dirham.svg",
                height: Numbers.DOUBLE_NUMBER_16,
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  ' ${_fmt(product.amount)} ',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  product.amountLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8A8FAE),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            product.companyName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A3A6B),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Repayment progress',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A8FAE)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${product.repaymentPercent}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: product.repaymentPercent == 0
                      ? const Color(0xFF8A8FAE)
                      : const Color(0xFFE67E22),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: product.repaymentProgress,
              minHeight: 7,
              backgroundColor: const Color(0xffF1F1F1),
              valueColor: AlwaysStoppedAnimation<Color>(
                product.repaymentPercent == 0
                    ? const Color(0xFFE8EAF0)
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  '${product.paidInstallments} of ${product.totalInstallments} paid',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8FAE),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${product.remainingInstallments} remaining',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8A8FAE),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: _infoChip(
                  ' ${_fmt(product.monthlyPayment)}',
                  'Monthly',
                  "assets/svg/dirham.svg",
                ),
              ),
              const SizedBox(width: Numbers.DOUBLE_NUMBER_10),
              Expanded(
                flex: 3,
                child: _infoChip(
                  _fmtDate(product.nextPaymentDate),
                  'Next Payment',
                  null,
                ),
              ),
              const SizedBox(width: Numbers.DOUBLE_NUMBER_10),
              Expanded(
                flex: 4,
                child: CustomElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.productDetails);
                  },
                  title: "More Info",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(ProductStatus status) {
    Color color;
    String label;
    switch (status) {
      case ProductStatus.disbursed:
        color = const Color(0xFF34A853);
        label = 'Disbursed';
        break;
      case ProductStatus.processing:
        color = const Color(0xFFF9A825);
        label = 'Processing';
        break;
      case ProductStatus.rejected:
        color = const Color(0xFFD32F2F);
        label = 'Rejected';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoChip(String top, String bottom, String? svgAsset) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (svgAsset != null) ...[
                SvgPicture.asset(svgAsset, height: Numbers.DOUBLE_NUMBER_10),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  top,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            bottom,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8A8FAE),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double amount) {
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?=\.))'),
          (m) => '${m[1]},',
        );
  }

  String _fmtDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
  }
}
