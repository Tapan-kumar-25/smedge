import 'package:flutter/material.dart';
import 'package:smedge/common_files/custom_container.dart';
import 'package:smedge/constants/numbers.dart';

import '../screens/pos_financing_1.dart';

class DocumentItem {
  final IconData icon;
  final String title;
  final String subtitle;

  DocumentItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class ProductServiceBottomSheet extends StatelessWidget {
  const ProductServiceBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final List<DocumentItem> items = [
      DocumentItem(
        icon: Icons.description_outlined,
        title: "Trade License",
        subtitle: "Valid & active copy",
      ),
      DocumentItem(
        icon: Icons.person_pin_outlined,
        title: "UBO Emirates ID",
        subtitle: "Employee/POA Holder: provide UBO Emirates ID",
      ),
      DocumentItem(
        icon: Icons.menu_book_outlined,
        title: "MOA / AOA",
        subtitle: "Latest version with all amendments",
      ),
      DocumentItem(
        icon: Icons.person_outline,
        title: "Passport",
        subtitle: "With valid UAE residency visa",
      ),
      DocumentItem(
        icon: Icons.account_balance,
        title: "Bank Statement",
        subtitle: "Last 6 months",
      ),
      DocumentItem(
        icon: Icons.settings,
        title: "VAT Registration Certificate",
        subtitle: "Official VAT registration document",
      ),

      DocumentItem(
        icon: Icons.receipt_long_outlined,
        title: "VAT Returns",
        subtitle: "Latest 2 quarters",
      ),
      DocumentItem(
        icon: Icons.group,
        title: "Company Ejari / Tenancy Contract",
        subtitle: "All business location must be current",
      ),
    ];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.all(Numbers.DOUBLE_NUMBER_16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 50,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              Image.asset(
                "assets/images/folder.png",
                height: Numbers.DOUBLE_NUMBER_100,
              ),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      width: size.width * 0.3,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.white, theme.colorScheme.primary],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: RichText(
                      text: TextSpan(
                        text: "Gather ",
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: "Required",
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                          TextSpan(
                            text: " Files",
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: size.width * 0.3,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [Colors.white, theme.colorScheme.primary],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: Numbers.DOUBLE_NUMBER_10),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          "To comply with regulatory requirements, please upload the\nrelevant company documents confirming your authority to \napply for financing. Accepted format: ",
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    TextSpan(
                      text: "PDF only",
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: Colors.red,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: Numbers.DOUBLE_NUMBER_10),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  padding: EdgeInsets.symmetric(
                    horizontal: Numbers.DOUBLE_NUMBER_10,
                  ),
                  separatorBuilder: (_, index) =>
                      const Divider(color: Colors.black12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildItem(
                      context,
                      item.icon,
                      item.title,
                      item.subtitle,
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: Numbers.DOUBLE_NUMBER_20),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: CustomContainer(
                          padding: Numbers.DOUBLE_NUMBER_12,
                          child: Text(
                            "Not Yet",
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium!.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Numbers.DOUBLE_NUMBER_12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PosFinancing1()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Yes, I'm Ready",
                          style: theme.textTheme.titleMedium!.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 26, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
