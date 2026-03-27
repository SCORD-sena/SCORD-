import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/jugador_model.dart';

class InfoMensualidadAdminCard extends StatelessWidget {
  final Jugador? jugadorSeleccionado;
  final VoidCallback? onRegistrarPago;
  final bool procesandoPago;

  const InfoMensualidadAdminCard({
    super.key,
    this.jugadorSeleccionado,
    this.onRegistrarPago,
    this.procesandoPago = false,
  });

  @override
  Widget build(BuildContext context) {
    if (jugadorSeleccionado == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.credit_card, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Seleccione un jugador para gestionar mensualidad',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Si no hay datos de mensualidad
    if (jugadorSeleccionado!.fechaIngresoClub == null && 
        jugadorSeleccionado!.fechaVencimientoMensualidad == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.orange),
              SizedBox(height: 8),
              Text(
                'Este jugador no tiene fechas de mensualidad configuradas',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titulo
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Gestion de Mensualidad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tiempo en el club
            if (jugadorSeleccionado!.fechaIngresoClub != null) ...[
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Fecha de Ingreso',
                value: DateFormat('dd/MM/yyyy').format(jugadorSeleccionado!.fechaIngresoClub!),
                color: Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.timer,
                label: 'Tiempo en el Club',
                value: jugadorSeleccionado!.tiempoEnClub?.texto ?? 'No disponible',
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
            ],

            // Mensualidad
            if (jugadorSeleccionado!.fechaVencimientoMensualidad != null) ...[
              _buildInfoRow(
                icon: Icons.event_available,
                label: 'Proximo Vencimiento',
                value: DateFormat('dd/MM/yyyy').format(jugadorSeleccionado!.fechaVencimientoMensualidad!),
                color: Colors.orange,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.access_time,
                label: 'Tiempo Restante',
                value: jugadorSeleccionado!.diasParaVencimiento?.texto ?? 'No disponible',
                color: Colors.orange,
              ),
              const SizedBox(height: 16),

              // Boton de registrar pago
              if (onRegistrarPago != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: procesandoPago ? null : onRegistrarPago,
                    icon: procesandoPago
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(
                      procesandoPago ? 'Procesando...' : 'Registrar Pago',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
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
                  fontSize: 15,
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