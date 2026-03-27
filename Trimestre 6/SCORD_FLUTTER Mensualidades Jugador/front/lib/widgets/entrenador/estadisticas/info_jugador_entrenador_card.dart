import 'package:flutter/material.dart';
import '../../../models/categoria_model.dart';
import '../../../models/jugador_model.dart';

class InfoJugadorEntrenadorCard extends StatelessWidget {
  final List<Categoria> categorias;
  final List<Jugador> jugadoresFiltrados;
  final String? categoriaSeleccionadaId;
  final Jugador? jugadorSeleccionado;
  final bool modoEdicion;
  final Function(String?) onCategoriaChanged;
  final Function(int?) onJugadorChanged;
  final String Function(DateTime?) calcularEdad;

  const InfoJugadorEntrenadorCard({
    super.key,
    required this.categorias,
    required this.jugadoresFiltrados,
    required this.categoriaSeleccionadaId,
    required this.jugadorSeleccionado,
    required this.modoEdicion,
    required this.onCategoriaChanged,
    required this.onJugadorChanged,
    required this.calcularEdad,
  });

  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$title:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final persona = jugadorSeleccionado?.persona;
    final categoriaJugador = jugadorSeleccionado?.categoria;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar Categoría',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xffe63946), fontSize: 13),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: const TextStyle(fontSize: 13, color: Colors.black),
              value: categoriaSeleccionadaId,
              items: [
                const DropdownMenuItem(value: null, child: Text("-- Selecciona categoría --")),
                ...categorias.map((cat) => DropdownMenuItem(
                  value: cat.idCategorias.toString(),
                  child: Text(cat.descripcion)
                )),
              ],
              onChanged: modoEdicion ? null : onCategoriaChanged,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Seleccionar Jugador',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(color: Color(0xffe63946), fontSize: 13),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              style: const TextStyle(fontSize: 13, color: Colors.black),
              value: jugadorSeleccionado?.idJugadores,
              items: [
                const DropdownMenuItem(value: null, child: Text("-- Selecciona jugador --")),
                ...jugadoresFiltrados.map((jugador) => DropdownMenuItem(
                  value: jugador.idJugadores,
                  child: Text("${jugador.persona.nombre1} ${jugador.persona.apellido1}"),
                )),
              ],
              onChanged: modoEdicion ? null : onJugadorChanged,
              disabledHint: const Text("Selecciona un jugador"),
            ),
            const SizedBox(height: 16),
            const Center(child: Icon(Icons.person, size: 80, color: Colors.grey)),
            const SizedBox(height: 12),

            const Center(
              child: Text(
                'Información Personal',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xffe63946))
              )
            ),
            const SizedBox(height: 8),
            _buildInfoItem(
              'Nombre',
              persona != null
                  ? "${persona.nombre1} ${persona.nombre2 ?? ''} ${persona.apellido1} ${persona.apellido2 ?? ''}".trim()
                  : "-",
            ),
            _buildInfoItem('Edad', calcularEdad(persona?.fechaDeNacimiento)),
            _buildInfoItem('Documento', persona?.numeroDeDocumento ?? "-"),
            _buildInfoItem('Contacto', persona?.telefono ?? "-"),

            const Divider(height: 24),

            const Center(
              child: Text(
                'Información Deportiva',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xffe63946))
              )
            ),
            const SizedBox(height: 8),
            _buildInfoItem('Categoría', categoriaJugador?.descripcion ?? "-"),
            _buildInfoItem('Dorsal', jugadorSeleccionado?.dorsal.toString() ?? "-"),
            _buildInfoItem('Posición', jugadorSeleccionado?.posicion ?? "-"),
          ],
        ),
      ),
    );
  }
}