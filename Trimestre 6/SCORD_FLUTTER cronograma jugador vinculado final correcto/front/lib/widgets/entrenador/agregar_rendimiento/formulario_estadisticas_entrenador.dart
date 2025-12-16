import 'package:flutter/material.dart';

class FormularioEstadisticasEntrenador extends StatelessWidget {
  final TextEditingController golesController;
  final TextEditingController asistenciasController;
  final TextEditingController minutosJugadosController;
  final TextEditingController golesDeCabezaController;
  final TextEditingController tirosApuertaController;
  final TextEditingController fuerasDeLugarController;
  final TextEditingController tarjetasAmarillasController;
  final TextEditingController tarjetasRojasController;
  final TextEditingController arcoEnCeroController;

  const FormularioEstadisticasEntrenador({
    super.key,
    required this.golesController,
    required this.asistenciasController,
    required this.minutosJugadosController,
    required this.golesDeCabezaController,
    required this.tirosApuertaController,
    required this.fuerasDeLugarController,
    required this.tarjetasAmarillasController,
    required this.tarjetasRojasController,
    required this.arcoEnCeroController,
  });

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    int? max,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          labelStyle: const TextStyle(color: Color(0xffe63946)),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Campo obligatorio';
          }
          if (value != null && value.isNotEmpty) {
            final numero = int.tryParse(value);
            if (numero == null || numero < 0) {
              return 'Debe ser un número positivo';
            }
            if (max != null && numero > max) {
              return 'No puede ser mayor a $max';
            }
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda
        Expanded(
          child: Column(
            children: [
              _buildTextField('⚽ Goles', golesController, required: true),
              _buildTextField('🎯 Asistencias', asistenciasController, required: true),
              _buildTextField('⏱ Minutos Jugados', minutosJugadosController, required: true, max: 120),
              _buildTextField('⚽ Goles de Cabeza', golesDeCabezaController),
              _buildTextField('🎯 Tiros a puerta', tirosApuertaController),
            ],
          ),
        ),
        const SizedBox(width: 16),
        
        // Columna derecha
        Expanded(
          child: Column(
            children: [
              _buildTextField('🚩 Fueras de Juego', fuerasDeLugarController),
              _buildTextField('🟨 Tarjetas Amarillas', tarjetasAmarillasController),
              _buildTextField('🟥 Tarjetas Rojas', tarjetasRojasController),
              _buildTextField('🧤 Arco en cero', arcoEnCeroController),
            ],
          ),
        ),
      ],
    );
  }
}