import 'package:flutter/material.dart';

class ProductServiceModel {
  final String title;
  final String description;
  final IconData icon;
  final List<ProductTag> tags;
  final String amountText;
  final String? subText;
  final String buttonText;
  // final Color buttonColor;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;

  ProductServiceModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.tags,
    required this.amountText,
    this.subText,
    required this.buttonText,
    // required this.buttonColor,
    this.onTap,
    this.onViewDetails,
  });
}
class ProductTag {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  ProductTag({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}
