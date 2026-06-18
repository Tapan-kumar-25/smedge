import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smedge/constants/numbers.dart';

import '../../utils/global_utils.dart';

enum PaymentStatus { paid, due, upcoming }

class RepaymentScheduleItem {
  final DateTime date;
  final double amount;
  final PaymentStatus status;

  const RepaymentScheduleItem({
    required this.date,
    required this.amount,
    required this.status,
  });
}

class ProductDetail {
  final String loanRef;
  final String title;
  final String activatedDate;
  final String planLabel;
  final double outstandingBalance;
  final double totalRepayable;
  final double monthlyInstalment;
  final DateTime nextPaymentDate;
  final List<RepaymentScheduleItem> schedule;

  const ProductDetail({
    required this.loanRef,
    required this.title,
    required this.activatedDate,
    required this.planLabel,
    required this.outstandingBalance,
    required this.totalRepayable,
    required this.monthlyInstalment,
    required this.nextPaymentDate,
    required this.schedule,
  });
}

final productDetail = ProductDetail(
  loanRef: 'FIN-2026-00481',
  title: 'Edwin Trading LLC - POS Financing',
  activatedDate: '1Nov 2025',
  planLabel: '6-month plan',
  outstandingBalance: 5900.00,
  totalRepayable: 8850.00,
  monthlyInstalment: 1475.00,
  nextPaymentDate: DateTime(2026, 5, 1),
  schedule: [
    RepaymentScheduleItem(
      date: DateTime(2025, 12, 1),
      amount: 1475.00,
      status: PaymentStatus.paid,
    ),
    RepaymentScheduleItem(
      date: DateTime(2026, 1, 1),
      amount: 1475.00,
      status: PaymentStatus.paid,
    ),
    RepaymentScheduleItem(
      date: DateTime(2026, 5, 1),
      amount: 1475.00,
      status: PaymentStatus.due,
    ),
    RepaymentScheduleItem(
      date: DateTime(2026, 4, 1),
      amount: 1475.00,
      status: PaymentStatus.upcoming,
    ),
  ],
);

class MyProductDetailScreen extends StatelessWidget {
  const MyProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDF1F8),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Product Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
              child: Container(
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
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Loan ref: ${productDetail.loanRef}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF8A8FAE),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  productDetail.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A2E),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      'Activated ${productDetail.activatedDate}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8A8FAE),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.circle,
                                      size: 6,
                                      color: Color(0xFFE53935),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      productDetail.planLabel,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF8A8FAE),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {},
                              child: Icon(
                                Icons.download,
                                size: Numbers.DOUBLE_NUMBER_20,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1, color: Color(0xFFEEEFF4)),

                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _statBox(
                                  'Outstanding balance',
                                  productDetail.outstandingBalance,
                                  isCurrency: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _statBox(
                                  'Total repayable',
                                  productDetail.totalRepayable,
                                  isCurrency: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _statBox(
                                  'Monthly instalment',
                                  productDetail.monthlyInstalment,
                                  isCurrency: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _statBox(
                                  'Next Payment',
                                  0,
                                  dateValue: productDetail.nextPaymentDate,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFEEEFF4)),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Repayment schedule',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...productDetail.schedule.map(
                            (item) => _scheduleRow(item),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(
    String label,
    double value, {
    bool isCurrency = false,
    DateTime? dateValue,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1A3A6B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          if (dateValue != null)
            Text(
              fmtFullDate(dateValue),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/svg/dirham.svg",
                  height: Numbers.DOUBLE_NUMBER_12,
                ),
                Text(
                  ' ${_fmt(value)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _scheduleRow(RepaymentScheduleItem item) {
    Color statusColor;
    String statusLabel;
    Widget leadingIcon;

    switch (item.status) {
      case PaymentStatus.paid:
        statusColor = const Color(0xFF34A853);
        statusLabel = 'Paid';
        leadingIcon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF34A853), width: 1.5),
          ),
          child: const Icon(Icons.check, size: 14, color: Color(0xFF34A853)),
        );
        break;
      case PaymentStatus.due:
        statusColor = const Color(0xFFD32F2F);
        statusLabel = 'Due';
        leadingIcon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD32F2F), width: 1.5),
          ),
          child: const Icon(Icons.close, size: 14, color: Color(0xFFD32F2F)),
        );
        break;
      case PaymentStatus.upcoming:
        statusColor = const Color(0xFF8A8FAE);
        statusLabel = 'Upcoming';
        leadingIcon = Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF8A8FAE), width: 1.5),
          ),
          child: const Icon(
            Icons.calendar_month_outlined,
            size: 13,
            color: Color(0xFF8A8FAE),
          ),
        );
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          leadingIcon,
          SizedBox(width: Numbers.DOUBLE_NUMBER_10),
          Expanded(
            child: Text(
              fmtScheduleDate(item.date),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                "assets/svg/dirham.svg",
                height: Numbers.DOUBLE_NUMBER_8,
              ),
              Text(
                ' ${_fmt(item.amount)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: item.status == PaymentStatus.due
                      ? const Color(0xFFD32F2F)
                      : const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: item.status == PaymentStatus.paid
                  ? const Color(0xFFE8F5E9)
                  : item.status == PaymentStatus.due
                  ? const Color(0xFFFFEBEE)
                  : const Color(0xFFF2F4F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
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
}
