import 'package:flutter/material.dart';
import '../core/theme.dart';

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  const Panel(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16),
      this.color = kCard});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(18)),
        child: child,
      );
}

class Bar extends StatelessWidget {
  final double value; // 0..1+
  const Bar(this.value, {super.key});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          minHeight: 6,
          backgroundColor: Colors.white10,
          valueColor:
              AlwaysStoppedAnimation(value > 1 ? kRed : kOrange),
        ),
      );
}
