import 'package:flutter/material.dart';
import '../../../models/jugador_model.dart';
import '../../../models/categoria_model.dart';

class SeleccionJugadorEntrenadorCard extends StatelessWidget {
  final List<Categoria> categorias;
  final List<Jugador> jugadoresFiltrados;
  final String? categoriaSeleccionada;
  final Jugador? jugadorSeleccionado;
  final bool modoEdicion;
  final Function(String?) onCategoriaChanged;
  final Function(int?) onJugadorChanged;

  const SeleccionJugadorEntrenadorCard({
    super.key,
    required this.categorias,
    required this.jugadoresFiltrados,
    required this.categoriaSeleccionada,
    required this.jugadorSeleccionado,
    required this.modoEdicion,
    required this.onCategoriaChanged,
    required this.onJugadorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar Categoría',
                labelStyle: TextStyle(fontSize: 13),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: const TextStyle(fontSize: 13, color: Colors.black),
              value: categoriaSeleccionada,
              hint: const Text('-- Selecciona categoría --'),
              items: [
                const DropdownMenuItem(value: null, child: Text('-- Selecciona categoría --')),
                ...categorias.map((cat) => DropdownMenuItem(
                      value: cat.idCategorias.toString(),
                      child: Text(cat.descripcion),
                    )),
              ],
              onChanged: modoEdicion ? null : onCategoriaChanged,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar Jugador',
                labelStyle: TextStyle(fontSize: 13),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: const TextStyle(fontSize: 13, color: Colors.black),
              value: jugadorSeleccionado?.idJugadores,
              hint: const Text('-- Selecciona jugador --'),
              items: [
                const DropdownMenuItem(value: null, child: Text('-- Selecciona jugador --')),
                ...jugadoresFiltrados.map((jug) => DropdownMenuItem(
                      value: jug.idJugadores,
                      child: Text('${jug.persona.nombre1} ${jug.persona.apellido1}'),
                    )),
              ],
              onChanged: categoriaSeleccionada == null || modoEdicion ? null : onJugadorChanged,
            ),
            const SizedBox(height: 16),
            ClipOval(
              child: Image.asset(
                'assets/Foto_Perfil.webp',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}