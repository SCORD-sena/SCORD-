import 'package:flutter/material.dart';
import '../../../models/rendimiento_model.dart';

class EstadisticasCard extends StatelessWidget {
  final bool loading;
  final bool modoEdicion;
  final EstadisticasTotales? estadisticasTotales;
  final Map<String, String> formData;
  final Function(String, String) onCampoChanged;

  const EstadisticasCard({
    super.key,
    required this.loading,
    required this.modoEdicion,
    required this.estadisticasTotales,
    required this.formData,
    required this.onCampoChanged,
  });

  // ✅ AGREGAR ESTE MAPA
  static const Map<String, String> _fieldNameMap = {
    'total_goles': 'goles',
    'total_asistencias': 'asistencias',
    'total_partidos_jugados': 'partidosJugados',
    'total_minutos_jugados': 'minutosJugados',
    'total_goles_cabeza': 'golesDeCabeza',
    'total_tiros_apuerta': 'tirosApuerta',
    'total_fueras_de_lugar': 'fuerasDeLugar',
    'total_tarjetas_amarillas': 'tarjetasAmarillas',
    'total_tarjetas_rojas': 'tarjetasRojas',
    'total_arco_en_cero': 'arcoEnCero',
  };

  Widget _buildEstadisticaItem(
    String label, 
    String statKey, 
    {bool isEditable = false, String? statAverageKey}
  ) {
    // ✅ USAR EL MAPA EN VEZ DE split()
    final fieldName = _fieldNameMap[statKey] ?? statKey.split('_').last;

    if (isEditable && modoEdicion) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label, 
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: Color(0xffe63946), 
                  fontSize: 13
                )
              ),
            ),
            SizedBox(
              width: 70,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6)
                ),
                controller: TextEditingController(text: formData[fieldName])
                  ..selection = TextSelection.collapsed(
                    offset: formData[fieldName]?.length ?? 0
                  ),
                onChanged: (value) => onCampoChanged(fieldName, value),
              ),
            ),
          ],
        ),
      );
    }

    String displayValue = '0';
    if (estadisticasTotales != null) {
      if (statAverageKey != null) {
        final val = estadisticasTotales!.promedios[statAverageKey];
        displayValue = val != null ? val.toStringAsFixed(2) : '0';
      } else {
        displayValue = estadisticasTotales!.totales[statKey]?.toString() ?? '0';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: statAverageKey == null ? FontWeight.w600 : FontWeight.normal,
                color: const Color(0xffe63946),
                fontSize: 13
              )
            ),
          ),
          Text(displayValue, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                'Estadísticas',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xffe63946)
                )
              )
            ),
            const Divider(height: 16),

            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(color: Color(0xffe63946))
                )
              )
            else if (estadisticasTotales != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      modoEdicion ? "Editar Último Partido" : "Estadísticas Básicas",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                    )
                  ),
                  const SizedBox(height: 10),

                  _buildEstadisticaItem('⚽ Goles', 'total_goles', isEditable: true),
                  _buildEstadisticaItem('🎯 Asistencias', 'total_asistencias', isEditable: true),
                  _buildEstadisticaItem('📋 Partidos', 'total_partidos_jugados'),
                  _buildEstadisticaItem('⏱️ Minutos', 'total_minutos_jugados', isEditable: true),

                  const Divider(height: 16),

                  const Center(
                    child: Text(
                      "Estadísticas Detalladas",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                    )
                  ),
                  const SizedBox(height: 10),

                  _buildEstadisticaItem('⚽ Goles de Cabeza', 'total_goles_cabeza', isEditable: true),
                  _buildEstadisticaItem('📊 Goles por Partido', 'total_goles', statAverageKey: 'goles_por_partido'),
                  _buildEstadisticaItem('🎯 Tiros a puerta', 'total_tiros_apuerta', isEditable: true),
                  _buildEstadisticaItem('🚩 Fueras de Juego', 'total_fueras_de_lugar', isEditable: true),
                  _buildEstadisticaItem('🟨 Tarjetas Amarillas', 'total_tarjetas_amarillas', isEditable: true),
                  _buildEstadisticaItem('🟥 Tarjetas Rojas', 'total_tarjetas_rojas', isEditable: true),
                  _buildEstadisticaItem('🧤 Arco en cero', 'total_arco_en_cero', isEditable: true),
                ],
              )
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Selecciona un jugador para ver sus estadísticas',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                )
              ),
          ],
        ),
      ),
    );
  }
}