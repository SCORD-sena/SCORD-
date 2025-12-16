import 'package:flutter/material.dart';
import '../../../models/categoria_model.dart';
import '../../../models/jugador_model.dart';
import '../../../models/partido_model.dart';

class FormularioSeleccionEntrenador extends StatelessWidget {
  final List<Categoria> categorias;
  final List<Jugador> jugadoresFiltrados;
  final List<Partido> partidos;
  final String? categoriaSeleccionada;
  final String? jugadorSeleccionado;
  final String? partidoSeleccionado;
  final Function(String?) onCategoriaChanged;
  final Function(String?) onJugadorChanged;
  final Function(String?) onPartidoChanged;

  const FormularioSeleccionEntrenador({
    super.key,
    required this.categorias,
    required this.jugadoresFiltrados,
    required this.partidos,
    required this.categoriaSeleccionada,
    required this.jugadorSeleccionado,
    required this.partidoSeleccionado,
    required this.onCategoriaChanged,
    required this.onJugadorChanged,
    required this.onPartidoChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar Jugador y Partido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xffe63946)
              ),
            ),
            const SizedBox(height: 16),
            
            // Dropdown Categoría
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Categoría *',
                labelStyle: TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(),
              ),
              value: categoriaSeleccionada,
              items: [
                const DropdownMenuItem(value: null, child: Text("Seleccionar categoría")),
                ...categorias.map((cat) => DropdownMenuItem(
                  value: cat.idCategorias.toString(),
                  child: Text(cat.descripcion),
                )),
              ],
              onChanged: onCategoriaChanged,
            ),
            const SizedBox(height: 16),

            // Dropdown Jugador
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Jugador *',
                labelStyle: TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(),
              ),
              value: jugadorSeleccionado,
              items: [
                const DropdownMenuItem(value: null, child: Text("Seleccionar jugador")),
                ...jugadoresFiltrados.map((jug) {
                  final nombre = '${jug.persona.nombre1} ${jug.persona.apellido1}';
                  return DropdownMenuItem(
                    value: jug.idJugadores.toString(),
                    child: Text(nombre),
                  );
                }),
              ],
              onChanged: categoriaSeleccionada == null ? null : onJugadorChanged,
            ),
            const SizedBox(height: 16),

            // Dropdown Partido
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Partido *',
                labelStyle: TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(),
              ),
              value: partidoSeleccionado,
              items: [
                const DropdownMenuItem(value: null, child: Text("Seleccionar partido")),
                ...partidos.map((partido) => DropdownMenuItem(
                  value: partido.idPartidos.toString(),
                  child: Text(partido.rival ?? 'Partido #${partido.idPartidos}'),
                )),
              ],
              onChanged: onPartidoChanged,
            ),
          ],
        ),
      ),
    );
  }
}