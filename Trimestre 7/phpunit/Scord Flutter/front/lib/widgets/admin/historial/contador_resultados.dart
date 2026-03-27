import 'package:flutter/material.dart';

class ContadorResultados extends StatelessWidget {
  final int cantidad;
  final String texto;

  const ContadorResultados({
    super.key,
    required this.cantidad,
    this.texto = 'resultado(s)',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$cantidad $texto',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}