import 'package:flutter/material.dart';

class ComparacionTableWidget extends StatelessWidget {
  final Map<String, dynamic> estadisticasComparadas;
  final String jugador1Nombre;
  final String jugador2Nombre;

  const ComparacionTableWidget({
    Key? key,
    required this.estadisticasComparadas,
    required this.jugador1Nombre,
    required this.jugador2Nombre,
  }) : super(key: key);

  String _calcularDiferencia(int val1, int val2) {
    final diff = val1 - val2;
    if (diff > 0) return '+$diff';
    return diff.toString();
  }

  Color _getColorDiferencia(int diff) {
    if (diff > 0) return Colors.green;
    if (diff < 0) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final stats1 = estadisticasComparadas['jugador1']['estadisticas'] as Map<String, dynamic>;
    final stats2 = estadisticasComparadas['jugador2']['estadisticas'] as Map<String, dynamic>;

    // ✅ CLAVES CORRECTAS DEL BACKEND
    final List<Map<String, dynamic>> estadisticas = [
      {'key': 'total_goles', 'label': '🏆 Goles'},
      {'key': 'total_goles_cabeza', 'label': '⚽ Goles de Cabeza'},
      {'key': 'total_asistencias', 'label': '👍 Asistencias'},
      {'key': 'total_tiros_apuerta', 'label': '🎯 Tiros a puerta'},
      {'key': 'total_fueras_de_lugar', 'label': '🚩 Fueras de juego'},
      {'key': 'total_partidos_jugados', 'label': '📅 Partidos Jugados'},
      {'key': 'total_tarjetas_amarillas', 'label': '🟨 Tarjetas Amarillas'},
      {'key': 'total_tarjetas_rojas', 'label': '🟥 Tarjetas Rojas'},
    ];

    return Card(
      elevation: 3,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFE63946),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: const Text(
              '📊 Comparación de Estadísticas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Tabla
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
              columns: [
                const DataColumn(
                  label: Text(
                    'Estadística',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    jugador1Nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    jugador2Nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const DataColumn(
                  label: Text(
                    'Diferencia',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: estadisticas.map((stat) {
                // ✅ CONVERTIR STRINGS A INT
                final val1 = int.tryParse(stats1[stat['key']]?.toString() ?? '0') ?? 0;
                final val2 = int.tryParse(stats2[stat['key']]?.toString() ?? '0') ?? 0;
                final diff = val1 - val2;

                return DataRow(
                  cells: [
                    DataCell(Text(stat['label'])),
                    DataCell(
                      Text(
                        val1.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(
                        val2.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataCell(
                      Text(
                        _calcularDiferencia(val1, val2),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getColorDiferencia(diff),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          // Footer con advertencia si hay error
          if (estadisticasComparadas['error'] != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          estadisticasComparadas['error'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text(
                    '💡 Para registrar estadísticas, vaya a Estadisticas jugador  → "agregar" y agregue el rendimiento de los jugadores en los partidos.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}