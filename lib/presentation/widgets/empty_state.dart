import 'package:flutter/material.dart';
import 'neumorphic.dart';

class NeumorphicEmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const NeumorphicEmptyState({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeumorphicContainer(
              width: 80,
              height: 80,
              borderRadius: 40,
              child: Center(
                child: Icon(
                  icon,
                  size: 32,
                  color: const Color(0xFFB8B8C0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF8A8A93),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
