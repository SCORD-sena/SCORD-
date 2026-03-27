import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../controllers/admin/gestion_competencias_controller.dart';

class DialogoCompetencia extends StatefulWidget {
  final GestionCompetenciasController controller;

  const DialogoCompetencia({super.key, required this.controller});

  @override
  State<DialogoCompetencia> createState() => _DialogoCompetenciaState();
}

class _DialogoCompetenciaState extends State<DialogoCompetencia> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.controller.modoEdicion ? 'Editar Competencia' : 'Nueva Competencia',
        style: const TextStyle(color: Color(0xffe63946), fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dropdown de categoría
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Categoría *',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.group, color: Color(0xffe63946)),
              ),
              value: widget.controller.categoriaSeleccionada,
              items: [
                const DropdownMenuItem(value: null, child: Text("-- Selecciona categoría --")),
                ...widget.controller.categorias.map((cat) => DropdownMenuItem(
                  value: cat.idCategorias.toString(),
                  child: Text(cat.descripcion),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  widget.controller.seleccionarCategoria(value);
                });
              },
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: widget.controller.nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre * (máx 50 caracteres)',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.emoji_events, color: Color(0xffe63946)),
                counterText: '${widget.controller.nombreController.text.length}/50',
              ),
              maxLength: 50,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.controller.tipoController,
              decoration: InputDecoration(
                labelText: 'Tipo * (máx 30 caracteres)',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.category, color: Color(0xffe63946)),
                hintText: 'Ejemplo: Liga, Copa, Torneo',
                counterText: '${widget.controller.tipoController.text.length}/30',
              ),
              maxLength: 30,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.controller.anoController,
              decoration: InputDecoration(
                labelText: 'Año *',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.calendar_today, color: Color(0xffe63946)),
                hintText: 'Ejemplo: 2024',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffe63946),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Guardar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}