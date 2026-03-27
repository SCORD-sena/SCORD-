import 'package:flutter/material.dart';

class ItemEliminadoCard extends StatelessWidget {
  final String titulo;
  final String subtitulo1;
  final String? subtitulo2;
  final String? subtitulo3;
  final String inicial;
  final VoidCallback onRestaurar;
  final VoidCallback onEliminarPermanente;

  const ItemEliminadoCard({
    super.key,
    required this.titulo,
    required this.subtitulo1,
    this.subtitulo2,
    this.subtitulo3,
    required this.inicial,
    required this.onRestaurar,
    required this.onEliminarPermanente,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con avatar y nombre
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red.shade100,
                  radius: 24,
                  child: Text(
                    inicial.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Información detallada
            _buildInfoRow(Icons.sports_soccer, subtitulo1),
            
            if (subtitulo2 != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.phone, subtitulo2!),
            ],
            
            if (subtitulo3 != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(Icons.category, subtitulo3!),
            ],
            
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRestaurar,
                    icon: const Icon(Icons.restore, size: 18, color: Colors.green),
                    label: const Text(
                      'Restaurar',
                      style: TextStyle(color: Colors.green, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEliminarPermanente,
                    icon: const Icon(Icons.delete_forever, size: 18, color: Colors.red),
                    label: const Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icono, String texto) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icono, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texto,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}