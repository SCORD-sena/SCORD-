import 'package:flutter/material.dart';
import '/../../models/persona_model.dart';

class JugadorInfoPersonalCard extends StatelessWidget {
  final Persona? persona;

  const JugadorInfoPersonalCard({
    super.key,
    required this.persona,
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
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (persona == null) {
      return const Card(
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No hay información personal disponible'),
          ),
        ),
      );
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Foto de perfil
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Nombre completo destacado
            Text(
              persona!.nombreCompleto,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xffe63946),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Lista de información
            _buildInfoItem('Nombre:', persona!.nombreCompleto),
            const Divider(height: 1),
            _buildInfoItem('Edad:', persona!.edad?.toString() ?? '-'),
            const Divider(height: 1),
            _buildInfoItem('Documento:', persona!.numeroDeDocumento),
            const Divider(height: 1),
            _buildInfoItem('Contacto:', persona!.telefono),
          ],
        ),
      ),
    );
  }
}