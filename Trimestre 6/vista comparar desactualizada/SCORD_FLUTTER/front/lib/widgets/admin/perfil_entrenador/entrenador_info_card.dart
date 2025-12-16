import 'package:flutter/material.dart';

class EntrenadorInfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const EntrenadorInfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: const Color(0xffe63946), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffe63946),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}