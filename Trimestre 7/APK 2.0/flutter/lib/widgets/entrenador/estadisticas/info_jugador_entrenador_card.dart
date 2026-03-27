import 'package:flutter/material.dart';
import '../../../models/categoria_model.dart';
import '../../../models/jugador_model.dart';
import '../../../models/competencia_model.dart';
import '../../../models/partido_model.dart';

class InfoJugadorEntrenadorCard extends StatelessWidget {
  final List<Categoria> categorias;
  final List<Jugador> jugadoresFiltrados;
  final List<Competencia> competenciasFiltradas;
  final List<Partido> partidosFiltrados;
  
  final String? categoriaSeleccionadaId;
  final int? competenciaSeleccionada;
  final int? partidoSeleccionado;
  final Jugador? jugadorSeleccionado;
  final bool modoEdicion;
  final bool isLoadingCompetencias;
  final bool isLoadingPartidos;
  
  final Function(String?) onCategoriaChanged;
  final Function(int?) onJugadorChanged;
  final Function(int?) onCompetenciaChanged;
  final Function(int?) onPartidoChanged;
  final String Function(DateTime?) calcularEdad;

  const InfoJugadorEntrenadorCard({
    super.key,
    required this.categorias,
    required this.jugadoresFiltrados,
    required this.competenciasFiltradas,
    required this.partidosFiltrados,
    required this.categoriaSeleccionadaId,
    required this.competenciaSeleccionada,
    required this.partidoSeleccionado,
    required this.jugadorSeleccionado,
    required this.modoEdicion,
    required this.isLoadingCompetencias,
    required this.isLoadingPartidos,
    required this.onCategoriaChanged,
    required this.onJugadorChanged,
    required this.onCompetenciaChanged,
    required this.onPartidoChanged,
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

  // 🆕 MÉTODO PARA FILTRAR DUPLICADOS
  List<Competencia> _getCompetenciasUnicas() {
    final Map<int, Competencia> uniqueMap = {};
    for (var comp in competenciasFiltradas) {
      if (!uniqueMap.containsKey(comp.idCompetencias)) {
        uniqueMap[comp.idCompetencias] = comp;
      }
    }
    return uniqueMap.values.toList();
  }

  // 🆕 MÉTODO PARA FILTRAR PARTIDOS DUPLICADOS
  List<Partido> _getPartidosUnicos() {
    final Map<int, Partido> uniqueMap = {};
    for (var partido in partidosFiltrados) {
      if (!uniqueMap.containsKey(partido.idPartidos)) {
        uniqueMap[partido.idPartidos] = partido;
      }
    }
    return uniqueMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final persona = jugadorSeleccionado?.persona;
    final categoriaJugador = jugadorSeleccionado?.categoria;

    // 🆕 OBTENER LISTAS SIN DUPLICADOS
    final competenciasUnicas = _getCompetenciasUnicas();
    final partidosUnicos = _getPartidosUnicos();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🎯 TÍTULO DE SECCIÓN
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xffe63946).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.filter_list, color: Color(0xffe63946), size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Filtros de Búsqueda',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffe63946),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ FILTRO 1: Categoría (solo las asignadas al entrenador)
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Seleccionar Categoría',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                labelStyle: const TextStyle(color: Color(0xffe63946), fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                prefixIcon: const Icon(Icons.group, color: Color(0xffe63946), size: 20),
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

            // ✅ FILTRO 2: Competencia - SIN DUPLICADOS
            if (isLoadingCompetencias)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(color: Color(0xffe63946)),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Seleccionar Competencia',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      labelStyle: const TextStyle(color: Color(0xffe63946), fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      prefixIcon: const Icon(Icons.emoji_events, color: Color(0xffe63946), size: 20),
                      hintText: categoriaSeleccionadaId == null
                          ? 'Primero selecciona una categoría'
                          : competenciasUnicas.isEmpty
                              ? 'No hay competencias'
                              : 'Selecciona una competencia',
                    ),
                    style: const TextStyle(fontSize: 13, color: Colors.black),
                    value: competenciaSeleccionada,
                    items: [
                      const DropdownMenuItem(value: null, child: Text("-- Selecciona competencia --")),
                      ...competenciasUnicas.map((comp) => DropdownMenuItem(
                        value: comp.idCompetencias,
                        child: Text('${comp.nombre} (${comp.ano})'),
                      )),
                    ],
                    onChanged: (categoriaSeleccionadaId == null || modoEdicion || competenciasUnicas.isEmpty)
                        ? null
                        : onCompetenciaChanged,
                  ),
                  
                  if (categoriaSeleccionadaId != null && competenciasUnicas.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          border: Border.all(color: Colors.orange.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No hay competencias para esta categoría',
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
                ],
              ),
            const SizedBox(height: 12),

            // ✅ FILTRO 3: Partido - SIN DUPLICADOS
            if (isLoadingPartidos)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(color: Color(0xffe63946)),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Seleccionar Partido',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      labelStyle: const TextStyle(color: Color(0xffe63946), fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      prefixIcon: const Icon(Icons.sports_soccer, color: Color(0xffe63946), size: 20),
                      hintText: competenciaSeleccionada == null
                          ? 'Primero selecciona una competencia'
                          : partidosUnicos.isEmpty
                              ? 'No hay partidos'
                              : 'Selecciona un partido',
                    ),
                    style: const TextStyle(fontSize: 13, color: Colors.black),
                    value: partidoSeleccionado,
                    items: [
                      const DropdownMenuItem(value: null, child: Text("-- Selecciona partido --")),
                      ...partidosUnicos.map((partido) => DropdownMenuItem(
                        value: partido.idPartidos,
                        child: Text('vs ${partido.equipoRival} - ${partido.formacion}'),
                      )),
                    ],
                    onChanged: (competenciaSeleccionada == null || modoEdicion || partidosUnicos.isEmpty)
                        ? null
                        : onPartidoChanged,
                  ),
                  
                  if (competenciaSeleccionada != null && partidosUnicos.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          border: Border.all(color: Colors.orange.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No hay partidos para esta competencia',
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
                ],
              ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xffe63946).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person, color: Color(0xffe63946), size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Seleccionar Jugador',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffe63946),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Jugador',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                labelStyle: const TextStyle(color: Color(0xffe63946), fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                prefixIcon: const Icon(Icons.person_outline, color: Color(0xffe63946), size: 20),
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
            
            const Divider(),
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