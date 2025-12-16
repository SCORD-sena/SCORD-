import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String mensaje;
  final IconData icono;

  const EmptyState({
    super.key,
    required this.mensaje,
    this.icono = Icons.inbox,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icono,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            mensaje,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}