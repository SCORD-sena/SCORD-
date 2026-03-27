import 'package:flutter/material.dart';

class ComparacionChartWidget extends StatelessWidget {
  final Map<String, dynamic> estadisticasComparadas;
  final String jugador1Nombre;
  final String jugador2Nombre;

  const ComparacionChartWidget({
    Key? key,
    required this.estadisticasComparadas,
    required this.jugador1Nombre,
    required this.jugador2Nombre,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats1 = estadisticasComparadas['jugador1']['estadisticas'] as Map<String, dynamic>;
    final stats2 = estadisticasComparadas['jugador2']['estadisticas'] as Map<String, dynamic>;

    // ✅ CLAVES CORRECTAS DEL BACKEND
    final List<Map<String, dynamic>> estadisticas = [
      {'key': 'total_goles', 'label': 'Goles', 'icon': '🏆', 'color1': const Color(0xFF3B82F6), 'color2': const Color(0xFFEF4444)},
      {'key': 'total_goles_cabeza', 'label': 'Goles de Cabeza', 'icon': '⚽', 'color1': const Color(0xFF3B82F6), 'color2': const Color(0xFFEF4444)},
      {'key': 'total_asistencias', 'label': 'Asistencias', 'icon': '👍', 'color1': const Color(0xFF3B82F6), 'color2': const Color(0xFFEF4444)},
      {'key': 'total_tiros_apuerta', 'label': 'Tiros a Puerta', 'icon': '🎯', 'color1': const Color(0xFF3B82F6), 'color2': const Color(0xFFEF4444)},
      {'key': 'total_fueras_de_lugar', 'label': 'Fueras de Juego', 'icon': '🚩', 'color1': const Color(0xFF3B82F6), 'color2': const Color(0xFFEF4444)},
      {'key': 'total_partidos_jugados', 'label': 'Partidos Jugados', 'icon': '📅', 'color1': const Color(0xFF3B82F6), 'color2': const Color(0xFFEF4444)},
      {'key': 'total_tarjetas_amarillas', 'label': 'Tarjetas Amarillas', 'icon': '🟨', 'color1': const Color(0xFF3B82F6), 'color2': const Color(0xFFEF4444)},
      {'key': 'total_tarjetas_rojas', 'label': 'Tarjetas Rojas', 'icon': '🟥', 'color1': const Color(0xFF3B82F6), 'color2': const Color(0xFFEF4444)},
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
              '📈 Visualización Gráfica',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Gráficos
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: estadisticas.map((stat) {
                // ✅ CONVERTIR STRINGS A INT
                final val1 = int.tryParse(stats1[stat['key']]?.toString() ?? '0') ?? 0;
                final val2 = int.tryParse(stats2[stat['key']]?.toString() ?? '0') ?? 0;
                final total = val1 + val2;
                final percentage1 = total > 0 ? (val1 / total) * 100 : 50.0;
                final percentage2 = total > 0 ? (val2 / total) * 100 : 50.0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con icon, label y valores
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                stat['icon'],
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                stat['label'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: stat['color1'],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  val1.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: stat['color2'],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  val2.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Nombres de jugadores
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            jugador1Nombre.split(' ').take(2).join(' '),
                            style: TextStyle(
                              color: stat['color1'],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            jugador2Nombre.split(' ').take(2).join(' '),
                            style: TextStyle(
                              color: stat['color2'],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Barra de progreso
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // ✅ Calcular ancho disponible correctamente
                              final availableWidth = constraints.maxWidth;
                              final width1 = (availableWidth * percentage1 / 100).clamp(0.0, availableWidth);
                              final width2 = (availableWidth * percentage2 / 100).clamp(0.0, availableWidth);
                              
                              return Row(
                                children: [
                                  // Jugador 1
                                  if (width1 > 0)
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 1000),
                                      curve: Curves.easeInOut,
                                      width: width1,
                                      height: 40,
                                      color: stat['color1'],
                                      alignment: Alignment.center,
                                      child: percentage1 > 15
                                          ? Text(
                                              '${percentage1.round()}%',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            )
                                          : null,
                                    ),
                                  // Jugador 2
                                  if (width2 > 0)
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 1000),
                                      curve: Curves.easeInOut,
                                      width: width2,
                                      height: 40,
                                      color: stat['color2'],
                                      alignment: Alignment.center,
                                      child: percentage2 > 15
                                          ? Text(
                                              '${percentage2.round()}%',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            )
                                          : null,
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Indicador de diferencia
                      Center(
                        child: Builder(
                          builder: (context) {
                            if (val1 == val2 && total > 0) {
                              return const Text(
                                'Empate perfecto',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            } else if (val1 > val2) {
                              return Text(
                                '${jugador1Nombre.split(' ')[0]} lidera por ${val1 - val2}',
                                style: const TextStyle(
                                  color: Color(0xFF3B82F6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            } else if (val2 > val1) {
                              return Text(
                                '${jugador2Nombre.split(' ')[0]} lidera por ${val2 - val1}',
                                style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}