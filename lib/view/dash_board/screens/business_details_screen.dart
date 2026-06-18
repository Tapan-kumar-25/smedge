import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smedge/common_files/custom_container.dart';
import 'package:smedge/common_files/custom_elevated_button.dart';
import 'package:smedge/constants/numbers.dart';

import 'business_details_screen_1.dart';

enum CompanyStatus { verified, expireSoon, expired, pending }

class Company {
  final String name;
  final String id;
  final String website;
  final String tradeLicense;
  final String incorporated;
  final String expiry;
  final String address;
  final Color logoBackgroundColor;
  final String logoText;
  final CompanyStatus status;

  const Company({
    required this.name,
    required this.id,
    required this.website,
    required this.tradeLicense,
    required this.incorporated,
    required this.expiry,
    required this.address,
    required this.logoBackgroundColor,
    required this.logoText,
    required this.status,
  });
}

// ─────────────────────────────────────────────
// SAMPLE DATA
// ─────────────────────────────────────────────

final List<Company> companies = [
  Company(
    name: 'Edwin Trading LLC',
    id: 'GSTINI2345',
    website: 'https://www.edwintrading.ae',
    tradeLicense: 'GSTIXXXXX5',
    incorporated: '03 / 14 / 2022',
    expiry: '03 / 13 / 2027',
    address: 'Suite 402, Financial District, Al Maryah Island, Abu Dhabi, UAE',
    logoBackgroundColor: const Color(0xFF2D5A27),
    logoText: '€',
    status: CompanyStatus.verified,
  ),
  Company(
    name: 'ZhongFin Retail Trad...',
    id: '10293847',
    website: 'https://www.zhongfin.io',
    tradeLicense: 'TL-99XXXXX11',
    incorporated: '05 / 15 / 2021',
    expiry: '05 / 14 / 2026',
    address:
    'Unit 15, Innovation Hub, Dubai International City, Dubai, UAE',
    logoBackgroundColor: const Color(0xFFB5451B),
    logoText: '夏',
    status: CompanyStatus.expireSoon,
  ),
];

// ─────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────

class BusinessDetailsScreen extends ConsumerWidget {
  const BusinessDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme= Theme.of(context);
    return SafeArea(
      bottom: true,top: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:Colors.white,
          elevation: 0,
          title: Text("Business Details"),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                itemCount: companies.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) =>
                    InkWell(
                        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (_) => BusinessDetailsScreen1()));},
                        child: CompanyCard(company: companies[index])),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildAddCompanyButton(context),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Companies',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Manage your registered business profiles.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF8A8FAE),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCompanyButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: SizedBox(
        width: double.infinity,
        child: CustomElevatedButton(
          onPressed: () {},
         title: 'Add Company',
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// COMPANY CARD
// ─────────────────────────────────────────────

class CompanyCard extends StatelessWidget {
  final Company company;

  const CompanyCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: Numbers.DOUBLE_NUMBER_12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompanyHeader(),
          const Divider(height: 24, color: Color(0xFFEEEFF4)),
          _buildInfoRow('Website', company.website, isLink: true),
          const SizedBox(height: 10),
          _buildInfoRow('Trade License', company.tradeLicense),
          const SizedBox(height: 10),
          _buildInfoRow('Incorporated', company.incorporated),
          const SizedBox(height: 10),
          _buildInfoRow('Expiry', company.expiry, isExpiry: true),
          const Divider(height: 24, color: Color(0xFFEEEFF4)),
          _buildAddress(),
        ],
      ),
    );
  }

  Widget _buildCompanyHeader() {
    return Row(
      children: [
        // Logo
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: company.logoBackgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              company.logoText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Name + ID
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                company.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ID: ${company.id}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8A8FAE),
                ),
              ),
            ],
          ),
        ),
        // Status badge
        _StatusBadge(status: company.status),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isLink = false, bool isExpiry = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF8A8FAE),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isLink
                  ? const Color(0xFF1A6BBF)
                  : isExpiry
                  ? const Color(0xFFE67E22)
                  : const Color(0xFF1A1A2E),
              decoration: isLink ? TextDecoration.underline : null,
              decorationColor: isLink ? const Color(0xFF1A6BBF) : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddress() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.location_on_outlined,
          color: Color(0xFFE53935),
          size: 18,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            company.address,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF4A4A6A),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// STATUS BADGE WIDGET
// ─────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final CompanyStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _badgeConfig;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 13, color: config.textColor),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig get _badgeConfig {
    switch (status) {
      case CompanyStatus.verified:
        return _BadgeConfig(
          label: 'Verified',
          icon: Icons.check_circle_outline,
          textColor: const Color(0xFF27AE60),
          borderColor: const Color(0xFF27AE60),
          backgroundColor: const Color(0xFFF0FBF4),
        );
      case CompanyStatus.expireSoon:
        return _BadgeConfig(
          label: 'Expire Soon',
          icon: Icons.access_time_outlined,
          textColor: const Color(0xFFE67E22),
          borderColor: const Color(0xFFE67E22),
          backgroundColor: const Color(0xFFFFF8F0),
        );
      case CompanyStatus.expired:
        return _BadgeConfig(
          label: 'Expired',
          icon: Icons.cancel_outlined,
          textColor: const Color(0xFFE53935),
          borderColor: const Color(0xFFE53935),
          backgroundColor: const Color(0xFFFFF0F0),
        );
      case CompanyStatus.pending:
        return _BadgeConfig(
          label: 'Pending',
          icon: Icons.hourglass_empty_outlined,
          textColor: const Color(0xFF8A8FAE),
          borderColor: const Color(0xFF8A8FAE),
          backgroundColor: const Color(0xFFF5F5FA),
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final IconData icon;
  final Color textColor;
  final Color borderColor;
  final Color backgroundColor;

  const _BadgeConfig({
    required this.label,
    required this.icon,
    required this.textColor,
    required this.borderColor,
    required this.backgroundColor,
  });
}