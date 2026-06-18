import 'package:flutter/material.dart';
import 'package:smedge/constants/numbers.dart';

class CustomElevatedButton extends StatefulWidget {
  final String title;
  final VoidCallback onPressed;

  const CustomElevatedButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  State<CustomElevatedButton> createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 6.0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(Numbers.DOUBLE_NUMBER_10),
        )
      ),
      onPressed: widget.onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Numbers.DOUBLE_NUMBER_12),
        child: Text(
          widget.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium!.copyWith(color: Colors.white,fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
