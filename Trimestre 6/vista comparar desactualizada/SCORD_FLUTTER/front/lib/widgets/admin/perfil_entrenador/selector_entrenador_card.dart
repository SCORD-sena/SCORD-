import 'package:flutter/material.dart';
import '/../../models/categoria_model.dart';
import '/../../models/entrenador_model.dart';

class SelectorEntrenadorCard extends StatelessWidget {
  final List<Categoria> categorias;
  final List<Entrenador> entrenadoresFiltrados;
  final int? categoriaSeleccionada;
  final Entrenador? entrenadorSeleccionado;
  final bool modoEdicion;
  final Function(int?) onCategoriaChanged;
  final Function(int?) onEntrenadorChanged;

  const SelectorEntrenadorCard({
    super.key,
    required this.categorias,
    required this.entrenadoresFiltrados,
    required this.categoriaSeleccionada,
    required this.entrenadorSeleccionado,
    required this.modoEdicion,
    required this.onCategoriaChanged,
    required this.onEntrenadorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selector de categoría
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar Categoría',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xffe63946), fontSize: 13),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: const TextStyle(fontSize: 13, color: Colors.black),
              value: categoriaSeleccionada,
              items: [
                const DropdownMenuItem(value: null, child: Text("-- Selecciona categoría --")),
                ...categorias.map((cat) => DropdownMenuItem(
                  value: cat.idCategorias,
                  child: Text(cat.descripcion),
                )),
              ],
              onChanged: modoEdicion ? null : onCategoriaChanged,
            ),
            
            const SizedBox(height: 12),
            
            // Selector de entrenador
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar Entrenador',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xffe63946), fontSize: 13),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: const TextStyle(fontSize: 13, color: Colors.black),
              value: entrenadorSeleccionado?.idEntrenadores,
              items: [
                const DropdownMenuItem(value: null, child: Text("-- Selecciona entrenador --")),
                ...entrenadoresFiltrados.map((ent) => DropdownMenuItem(
                  value: ent.idEntrenadores,
                  child: Text(ent.persona?.nombreCorto ?? 'Sin nombre'),
                )),
              ],
              onChanged: categoriaSeleccionada == null || modoEdicion ? null : onEntrenadorChanged,
              disabledHint: const Text("Selecciona un entrenador"),
            ),
            
            const SizedBox(height: 16),
            
            // Foto de perfil
            const Center(
              child: Icon(Icons.person, size: 80, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}