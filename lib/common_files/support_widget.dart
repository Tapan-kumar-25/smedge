import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smedge/common_files/utils.dart';
import 'package:smedge/constants/numbers.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/global_utils.dart';
import 'custom_container.dart';

class SupportWidget extends StatefulWidget {
  final BuildContext _context;

  const SupportWidget({super.key, required BuildContext context})
    : _context = context;

  @override
  State<SupportWidget> createState() => _SupportWidgetState();
}

class _SupportWidgetState extends State<SupportWidget> {
  Future<void> _launchURL(Uri uri) async {
    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!success) {
        Utils.showSnackBar(widget._context, "Could not launch", Colors.red);
      }
    } catch (e) {
      Utils.showSnackBar(widget._context, e.toString(), Colors.red);
    }
  }

  void _handleAction(String name) async {
    name = name.toLowerCase();

    if (name.contains("call")) {
      _launchURL(Uri.parse("tel:9090909090"));
    } else if (name.contains("email")) {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'support@gmail.com',
        queryParameters: {'subject': 'Support', 'body': 'Hello'},
      );
      _launchURL(emailUri);
    } else if (name.contains("whatsapp")) {
      final Uri uri = Uri.parse("https://wa.me/918018514398?text=Hello");
      _launchURL(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(signUpOptions.length, (index) {
            final item = signUpOptions[index];

            return GestureDetector(
              onTap: () {
                FocusScope.of(widget._context).unfocus();
                _handleAction(item['name']);
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: Numbers.DOUBLE_NUMBER_16),
                child: CustomContainer(
                  child: SvgPicture.asset(
                    item["icon"],
                    height: Numbers.DOUBLE_NUMBER_30,
                    width: Numbers.DOUBLE_NUMBER_30,
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: Numbers.DOUBLE_NUMBER_16),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "Need help? ",
                style: theme.textTheme.bodyMedium!.copyWith(
                  // color: theme.colorScheme.primary,
                ),
              ),
              TextSpan(
                text: "We’re here for you",
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        SizedBox(height: Numbers.DOUBLE_NUMBER_8),
        Text(
          "Choose a support option to connect with our team instantly",
          style: theme.textTheme.titleSmall,
        ),
      ],
    );
  }
}
