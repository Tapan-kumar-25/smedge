import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Widget child;
  final double padding;
  const CustomContainer({
    super.key,
    required this.child,
    this.padding = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow:  [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: Offset(0, 3),
            blurRadius: 6,
            // spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
