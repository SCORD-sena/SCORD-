import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../controllers/entrenador/agregar_resultado_entrenador_controller.dart';

class FormularioDatosResultadoEntrenador extends StatefulWidget {
  final AgregarResultadoEntrenadorController controller;

  const FormularioDatosResultadoEntrenador({
    super.key,
    required this.controller,
  });

  @override
  State<FormularioDatosResultadoEntrenador> createState() => _FormularioDatosResultadoEntrenadorState();
}

class _FormularioDatosResultadoEntrenadorState extends State<FormularioDatosResultadoEntrenador> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.assessment, color: Colors.green, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Datos del Resultado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Marcador
            TextField(
              controller: widget.controller.marcadorController,
              decoration: InputDecoration(
                labelText: 'Marcador * (máx 10 caracteres)',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.scoreboard, color: Color(0xffe63946)),
                hintText: 'Ejemplo: 3-1, 2-2',
                counterText: '${widget.controller.marcadorController.text.length}/10',
              ),
              maxLength: 10,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Puntos Obtenidos
            TextField(
              controller: widget.controller.puntosController,
              decoration: InputDecoration(
                labelText: 'Puntos Obtenidos *',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.stars, color: Color(0xffe63946)),
                hintText: 'Ejemplo: 3',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            // Observación
            TextField(
              controller: widget.controller.observacionController,
              decoration: InputDecoration(
                labelText: 'Observación (opcional, máx 100 caracteres)',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.notes, color: Color(0xffe63946)),
                hintText: 'Comentarios adicionales',
                counterText: '${widget.controller.observacionController.text.length}/100',
              ),
              maxLength: 100,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }
}