import 'package:flutter/material.dart';
import '../../../controllers/admin/gestion_categorias_controller.dart';

class DialogoCategoria extends StatefulWidget {
  final GestionCategoriasController controller;

  const DialogoCategoria({
    super.key,
    required this.controller,
  });

  @override
  State<DialogoCategoria> createState() => _DialogoCategoriaState();
}

class _DialogoCategoriaState extends State<DialogoCategoria> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.controller.modoEdicion ? 'Editar Categoría' : 'Nueva Categoría',
        style: const TextStyle(
          color: Color(0xffe63946),
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo ID
            TextField(
              decoration: InputDecoration(
                labelText: 'ID *',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.tag, color: Color(0xffe63946)),
                hintText: 'Ejemplo: 1',
              ),
              keyboardType: TextInputType.number,
              enabled: !widget.controller.modoEdicion, // ID no editable en edición
            ),
            const SizedBox(height: 16),

            // Campo Descripción
            TextField(
              controller: widget.controller.descripcionController,
              decoration: InputDecoration(
                labelText: 'Categorías * (máx 20 caracteres)',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.description, color: Color(0xffe63946)),
                counterText: '${widget.controller.descripcionController.text.length}/20',
                hintText: 'Ejemplo: SUB 15',
              ),
              maxLength: 20,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Campo Tipo de Categoría
            TextField(
              controller: widget.controller.tiposCategoriaController,
              decoration: InputDecoration(
                labelText: 'Tipo de Categoría * (máx 30 caracteres)',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.category, color: Color(0xffe63946)),
                counterText: '${widget.controller.tiposCategoriaController.text.length}/30',
                hintText: 'Ejemplo: PRE BABY (4, 5 y 6 AÑOS)',
              ),
              maxLength: 30,
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