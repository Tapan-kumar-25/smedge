import 'package:flutter/material.dart';
import 'package:smedge/common_files/custom_elevated_button.dart';

class BusinessDetailsScreen1 extends StatelessWidget {
  const BusinessDetailsScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          'Business Details',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _businessCard(),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: "Basic Information",
                      children: [
                        _row("Trading Name", "Edwin Trading"),
                        _row(
                          "Website",
                          "https://www.edwintrading.ae",
                          isLink: true,
                        ),
                        _row(
                          "Business Type",
                          "Limited Liability Company (LLC)",
                        ),
                        _row("Agent Code", "AGT-4402", isRed: true),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _sectionCard(
                      title: "Legal & Registration",
                      trailing: _chip("Expiring Soon"),
                      children: [
                        _row("Trade License", "GSTIXXXXX5"),
                        _row("Incorporated", "03 / 14 / 2022"),
                        _row(
                          "Expiry",
                          "03 / 13 / 2027",
                          valueColor: Colors.green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _sectionCard(
                      title: "Registered Address",
                      trailing: Text(
                        "View on Maps",
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.location_on, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Suite 402, Financial District, Al Maryah Island, Abu Dhabi, UAE",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _sectionCard(
                      title: "Required Documents",
                      children: [
                        _docItem("Trade License", true),
                        _docItem("UBO Emirates ID", true),
                        _docItem("MOA / AOA", false),
                        _docItem("Passport", true),
                        _docItem("Bank Statement", true),
                        _docItem("VAT Registration Certificate", true),
                        _docItem("VAT Returns", true),
                        _docItem("Company Ejari / Tenancy Contract", true),
                      ],
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  onPressed: () {},
                  title: "Apply for financing",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= Widgets =================


  Widget _businessCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3D7A), Color(0xFF5C8FD6)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.green.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edwin Trading LLC",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "ID: GSTIN12345",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Verified",
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              ?trailing,
            ],
          ),
          const Divider(color: Colors.black12,),
          ...children,
        ],
      ),
    );
  }

  Widget _row(
    String title,
    String value, {
    bool isLink = false,
    bool isRed = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color:
                    valueColor ??
                    (isLink
                        ? Colors.blue
                        : isRed
                        ? Colors.red
                        : Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _docItem(String title, bool uploaded) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
          Text(
            uploaded ? "Uploaded" : "Missing",
            style: TextStyle(
              color: uploaded ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              uploaded ? "View" : "Upload",
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
