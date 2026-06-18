import 'package:flutter/material.dart';

import '../constants/numbers.dart';
import 'custom_container.dart';

class CustomToggleButton extends StatefulWidget {
  final List<String> labels;
  final Function(int index)? onTap;
  final int initialIndex;

  const CustomToggleButton({
    super.key,
    required this.labels,
    this.onTap,
    required this.initialIndex,
  });

  @override
  State<CustomToggleButton> createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  late int selectedIndex;

  @override
  void initState() {
    selectedIndex = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / widget.labels.length;

          return SizedBox(
            height: 45,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: selectedIndex * itemWidth,
                  top: 0,
                  child: SizedBox(
                    width: itemWidth,
                    height: 45,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(
                          Numbers.DOUBLE_NUMBER_12,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(
                    widget.labels.length,
                    (index) => _buildTab(widget.labels[index], index),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final selected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (selectedIndex != index) {
            setState(() => selectedIndex = index);
            widget.onTap?.call(index);
          }
        },
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: Numbers.DOUBLE_NUMBER_2),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontSize: Numbers.DOUBLE_NUMBER_16,
              fontWeight: FontWeight.w700,
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.primary,
            ),
            child: Text(label, overflow: TextOverflow.ellipsis),
          ),
        ),
      ),
    );
  }
}
