import 'package:flutter/material.dart';
import '/../../models/jugador_model.dart';

class JugadorInfoDeportivaCard extends StatelessWidget {
  final Jugador? jugador;

  const JugadorInfoDeportivaCard({
    super.key,
    required this.jugador,
  });

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (jugador == null) {
      return const Card(
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No hay información deportiva disponible'),
          ),
        ),
      );
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Información Deportiva',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffe63946),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoItem(
              'Categoría:',
              jugador!.categoria?.descripcion ?? '-',
            ),
            const Divider(height: 1),
            _buildInfoItem('Dorsal:', jugador!.dorsal.toString()),
            const Divider(height: 1),
            _buildInfoItem('Posición:', jugador!.posicion),
          ],
        ),
      ),
    );
  }
}