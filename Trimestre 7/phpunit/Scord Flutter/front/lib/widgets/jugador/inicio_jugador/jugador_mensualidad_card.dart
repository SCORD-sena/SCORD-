import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JugadorMensualidadCard extends StatelessWidget {
  final DateTime? fechaIngresoClub;
  final String? tiempoEnClubTexto;
  final DateTime? fechaVencimientoMensualidad;
  final String? diasParaVencimientoTexto;
  final bool mensualidadVencida;
  final String estadoPago;

  const JugadorMensualidadCard({
    super.key,
    this.fechaIngresoClub,
    this.tiempoEnClubTexto,
    this.fechaVencimientoMensualidad,
    this.diasParaVencimientoTexto,
    this.mensualidadVencida = false,
    this.estadoPago = 'sin_definir',
  });

  @override
  Widget build(BuildContext context) {
    // Si no hay datos de mensualidad, no mostrar nada
    if (fechaIngresoClub == null && fechaVencimientoMensualidad == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titulo
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xffe63946).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Color(0xffe63946),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Informacion de Mensualidad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffe63946),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Tiempo en el club
            if (fechaIngresoClub != null) ...[
              _buildInfoSection(
                icon: Icons.calendar_today,
                title: 'Fecha de Ingreso al Club',
                value: DateFormat('dd/MM/yyyy').format(fechaIngresoClub!),
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildInfoSection(
                icon: Icons.timer,
                title: 'Tiempo en el Club',
                value: tiempoEnClubTexto ?? 'No disponible',
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
            ],

            // Mensualidad
            if (fechaVencimientoMensualidad != null) ...[
              _buildInfoSection(
                icon: Icons.event_available,
                title: 'Proximo Vencimiento de Mensualidad',
                value: DateFormat('dd/MM/yyyy').format(fechaVencimientoMensualidad!),
                iconColor: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildInfoSection(
                icon: Icons.access_time,
                title: 'Tiempo Restante',
                value: diasParaVencimientoTexto ?? 'No disponible',
                iconColor: Colors.orange,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}