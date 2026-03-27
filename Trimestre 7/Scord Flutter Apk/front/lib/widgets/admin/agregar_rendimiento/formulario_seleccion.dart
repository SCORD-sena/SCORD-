import 'package:flutter/material.dart';
import '../../../models/categoria_model.dart';
import '../../../models/jugador_model.dart';
import '../../../models/competencia_model.dart';
import '../../../models/partido_model.dart';

class FormularioSeleccion extends StatelessWidget {
  final List<Categoria> categorias;
  final List<Jugador> jugadoresFiltrados;
  final List<Competencia> competenciasFiltradas;
  final List<Partido> partidosFiltrados;
  
  final String? categoriaSeleccionada;
  final int? competenciaSeleccionada;
  final String? jugadorSeleccionado;
  final String? partidoSeleccionado;
  
  final bool isLoadingCompetencias;
  final bool isLoadingPartidos;
  
  final Function(String?) onCategoriaChanged;
  final Function(int?) onCompetenciaChanged;
  final Function(String?) onJugadorChanged;
  final Function(String?) onPartidoChanged;

  const FormularioSeleccion({
    super.key,
    required this.categorias,
    required this.jugadoresFiltrados,
    required this.competenciasFiltradas,
    required this.partidosFiltrados,
    required this.categoriaSeleccionada,
    required this.competenciaSeleccionada,
    required this.jugadorSeleccionado,
    required this.partidoSeleccionado,
    required this.isLoadingCompetencias,
    required this.isLoadingPartidos,
    required this.onCategoriaChanged,
    required this.onCompetenciaChanged,
    required this.onJugadorChanged,
    required this.onPartidoChanged,
  });

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
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.filter_list, color: Colors.red, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Seleccionar Jugador y Partido',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffe63946)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // ✅ FILTRO 1: Categoría
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Categoría *',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.group, color: Color(0xffe63946)),
              ),
              value: categoriaSeleccionada,
              items: [
                const DropdownMenuItem(value: null, child: Text("-- Selecciona categoría --")),
                ...categorias.map((cat) => DropdownMenuItem(
                  value: cat.idCategorias.toString(),
                  child: Text(cat.descripcion),
                )),
              ],
              onChanged: onCategoriaChanged,
            ),
            const SizedBox(height: 16),

            // ✅ FILTRO 2: Competencia (filtrada por categoría)
            if (isLoadingCompetencias)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(color: Color(0xffe63946)),
                ),
              )
            else
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Competencia *',
                  labelStyle: const TextStyle(color: Color(0xffe63946)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.emoji_events, color: Color(0xffe63946)),
                  hintText: categoriaSeleccionada == null
                      ? 'Primero selecciona una categoría'
                      : competenciasFiltradas.isEmpty
                          ? 'No hay competencias para esta categoría'
                          : 'Selecciona una competencia',
                ),
                value: competenciaSeleccionada,
                items: [
                  const DropdownMenuItem(value: null, child: Text("-- Selecciona competencia --")),
                  ...competenciasFiltradas.map((comp) => DropdownMenuItem(
                    value: comp.idCompetencias,
                    child: Text('${comp.nombre} (${comp.ano})'),
                  )),
                ],
                onChanged: (categoriaSeleccionada == null || competenciasFiltradas.isEmpty)
                    ? null
                    : onCompetenciaChanged,
              ),
            
            // ⚠️ MENSAJE DE ALERTA cuando no hay competencias
            if (categoriaSeleccionada != null && competenciasFiltradas.isEmpty && !isLoadingCompetencias)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No hay competencias para esta categoría. Contacta al administrador.',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // ✅ FILTRO 3: Partido (filtrado por competencia)
            if (isLoadingPartidos)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(color: Color(0xffe63946)),
                ),
              )
            else
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Partido *',
                  labelStyle: const TextStyle(color: Color(0xffe63946)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.sports_soccer, color: Color(0xffe63946)),
                  hintText: competenciaSeleccionada == null
                      ? 'Primero selecciona una competencia'
                      : partidosFiltrados.isEmpty
                          ? 'No hay partidos para esta competencia'
                          : 'Selecciona un partido',
                ),
                value: partidoSeleccionado,
                items: [
                  const DropdownMenuItem(value: null, child: Text("-- Selecciona partido --")),
                  ...partidosFiltrados.map((partido) => DropdownMenuItem(
                    value: partido.idPartidos.toString(),
                    child: Text('vs ${partido.equipoRival} - ${partido.formacion}'),
                  )),
                ],
                onChanged: (competenciaSeleccionada == null || partidosFiltrados.isEmpty)
                    ? null
                    : onPartidoChanged,
              ),

            // ⚠️ MENSAJE DE ALERTA cuando no hay partidos
            if (competenciaSeleccionada != null && partidosFiltrados.isEmpty && !isLoadingPartidos)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No hay partidos para esta competencia. Crea un partido primero.',
                          style: TextStyle(
                            color: Colors.orange.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // ✅ FILTRO 4: Jugador (filtrado por categoría)
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Jugador *',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.person, color: Color(0xffe63946)),
              ),
              value: jugadorSeleccionado,
              items: [
                const DropdownMenuItem(value: null, child: Text("-- Selecciona jugador --")),
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
          ],
        ),
      ),
    );
  }
}