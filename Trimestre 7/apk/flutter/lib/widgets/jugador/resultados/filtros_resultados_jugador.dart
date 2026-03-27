import 'package:flutter/material.dart';
import '../../../models/competencia_model.dart';
import '../../../models/partido_model.dart';

class FiltrosResultadosJugador extends StatelessWidget {
  final List<Competencia> competenciasFiltradas;
  final List<Partido> partidosFiltrados;
  
  final int? competenciaSeleccionada;
  final int? partidoSeleccionado;
  
  final bool isLoadingPartidos;
  
  final Function(int?) onCompetenciaChanged;
  final Function(int?) onPartidoChanged;

  const FiltrosResultadosJugador({
    super.key,
    required this.competenciasFiltradas,
    required this.partidosFiltrados,
    required this.competenciaSeleccionada,
    required this.partidoSeleccionado,
    required this.isLoadingPartidos,
    required this.onCompetenciaChanged,
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
                  'Filtrar Resultados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffe63946)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Competencia
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Competencia',
                    labelStyle: const TextStyle(color: Color(0xffe63946)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    prefixIcon: const Icon(Icons.emoji_events, color: Color(0xffe63946)),
                    hintText: competenciasFiltradas.isEmpty
                        ? 'No hay competencias disponibles'
                        : 'Selecciona una competencia',
                  ),
                  value: competenciaSeleccionada,
                  items: [
                    const DropdownMenuItem(value: null, child: Text("-- Todas las competencias --")),
                    ...competenciasFiltradas.map((comp) => DropdownMenuItem(
                      value: comp.idCompetencias,
                      child: Text('${comp.nombre} (${comp.ano})'),
                    )),
                  ],
                  onChanged: competenciasFiltradas.isEmpty ? null : onCompetenciaChanged,
                ),
                
                if (competenciasFiltradas.isEmpty)
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
                          const Expanded(
                            child: Text(
                              'No hay competencias para tu categoría',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Partido
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
                      labelText: 'Partido',
                      labelStyle: const TextStyle(color: Color(0xffe63946)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.sports_soccer, color: Color(0xffe63946)),
                      hintText: competenciaSeleccionada == null
                          ? 'Primero selecciona una competencia'
                          : partidosFiltrados.isEmpty
                              ? 'No hay partidos'
                              : 'Selecciona un partido',
                    ),
                    value: partidoSeleccionado,
                    items: [
                      const DropdownMenuItem(value: null, child: Text("-- Todos los partidos --")),
                      ...partidosFiltrados.map((partido) => DropdownMenuItem(
                        value: partido.idPartidos,
                        child: Text('vs ${partido.equipoRival} - ${partido.formacion}'),
                      )),
                    ],
                    onChanged: (competenciaSeleccionada == null || partidosFiltrados.isEmpty)
                        ? null
                        : onPartidoChanged,
                  ),

                  if (competenciaSeleccionada != null && partidosFiltrados.isEmpty)
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
                            const Expanded(
                              child: Text(
                                'No hay partidos para esta competencia',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}