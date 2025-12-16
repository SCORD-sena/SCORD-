import 'package:flutter/material.dart';
import '/../../models/rendimiento_model.dart';

class JugadorEstadisticasCard extends StatelessWidget {
  final EstadisticasTotales? estadisticas;

  const JugadorEstadisticasCard({
    super.key,
    required this.estadisticas,
  });

  Widget _buildEstadisticaItem(String label, String value) {
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

  Widget _buildEstadisticaDetalladaItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xffe63946),
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
    if (estadisticas == null) {
      return const Card(
        elevation: 3,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No hay estadísticas disponibles'),
          ),
        ),
      );
    }

    final totales = estadisticas!.totales;
    final promedios = estadisticas!.promedios;

    return Column(
      children: [
        // Estadísticas Básicas
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Temporada 24/25 - Estadísticas Básicas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffe63946),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildEstadisticaItem(
                  '⚽ Goles:',
                  totales['total_goles']?.toString() ?? '0',
                ),
                const Divider(height: 1),
                _buildEstadisticaItem(
                  '🎯 Asistencias:',
                  totales['total_asistencias']?.toString() ?? '0',
                ),
                const Divider(height: 1),
                _buildEstadisticaItem(
                  '📋 Partidos:',
                  totales['total_partidos_jugados']?.toString() ?? '0',
                ),
                const Divider(height: 1),
                _buildEstadisticaItem(
                  '⏱️ Minutos:',
                  totales['total_minutos_jugados']?.toString() ?? '0',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Estadísticas Detalladas
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Estadísticas Detalladas',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xffe63946),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildEstadisticaDetalladaItem(
                  '⚽ Goles de Cabeza',
                  totales['total_goles_cabeza']?.toString() ?? '0',
                ),
                const Divider(height: 1),
                _buildEstadisticaDetalladaItem(
                  '📊 Goles por Partido',
                  promedios['goles_por_partido']?.toStringAsFixed(2) ?? '0.00',
                ),
                const Divider(height: 1),
                _buildEstadisticaDetalladaItem(
                  '🎯 Tiros a puerta',
                  totales['total_tiros_apuerta']?.toString() ?? '0',
                ),
                const Divider(height: 1),
                _buildEstadisticaDetalladaItem(
                  '🚩 Fueras de Juego',
                  totales['total_fueras_de_lugar']?.toString() ?? '0',
                ),
                const Divider(height: 1),
                _buildEstadisticaDetalladaItem(
                  '🟨 Tarjetas Amarillas',
                  totales['total_tarjetas_amarillas']?.toString() ?? '0',
                ),
                const Divider(height: 1),
                _buildEstadisticaDetalladaItem(
                  '🟥 Tarjetas Rojas',
                  totales['total_tarjetas_rojas']?.toString() ?? '0',
                ),
                const Divider(height: 1),
                _buildEstadisticaDetalladaItem(
                  '🧤 Arco en cero',
                  totales['total_arco_en_cero']?.toString() ?? '0',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}