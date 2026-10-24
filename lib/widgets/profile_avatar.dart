import 'package:flutter/material.dart';
import '../services/store.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;
  const ProfileAvatar({super.key, required this.radius});

  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF29B6D9),
        child: Text(
            store.name.isNotEmpty ? store.name[0].toUpperCase() : '?',
            style: TextStyle(
                fontSize: radius * .9,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      );
}
