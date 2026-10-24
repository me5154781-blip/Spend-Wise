import 'package:flutter/material.dart';
import '../core/theme.dart';

class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const PillChip(
      {super.key,
      required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? kOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selected ? kOrange : Colors.white24),
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.black : Colors.white)),
        ),
      );
}
