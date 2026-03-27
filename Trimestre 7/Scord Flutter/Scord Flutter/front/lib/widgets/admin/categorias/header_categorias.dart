import 'package:flutter/material.dart';

class HeaderCategorias extends StatelessWidget {
  const HeaderCategorias({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xffe63946).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.category,
            color: Color(0xffe63946),
            size: 32,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Categorías Actuales',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xffe63946),
          ),
        ),
      ],
    );
  }
}