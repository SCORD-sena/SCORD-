import 'package:flutter/material.dart';
import '../../../controllers/admin/gestion_resultados_controller.dart';

class DialogoResultado extends StatefulWidget {
  final GestionResultadosController controller;

  const DialogoResultado({
    super.key,
    required this.controller,
  });

  @override
  State<DialogoResultado> createState() => _DialogoResultadoState();
}

class _DialogoResultadoState extends State<DialogoResultado> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.controller.modoEdicion ? 'Editar Resultado' : 'Nuevo Resultado',
        style: const TextStyle(
          color: Color(0xffe63946),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
      actions: [
        TextButton(
          onPressed: () {
            widget.controller.limpiarFormulario();
            Navigator.pop(context, false);
          },
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: widget.controller.loading
              ? null
              : () async {
                  Navigator.pop(context, true);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffe63946),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            widget.controller.loading ? 'Guardando...' : 'Guardar',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}