import 'package:flutter/material.dart';
import '../../../controllers/jugador/cronograma_jugador_controller.dart';
import '../../../models/categoria_model.dart';
import '../../../models/competencia_model.dart';
import '../../admin/cronogramas/pagination_widget.dart';

class CronogramaPartidosJugadorSection extends StatelessWidget {
  final CronogramaJugadorController controller;
  final Function(String) onSearch;
  final Function(int) onPageChange;

  const CronogramaPartidosJugadorSection({
    Key? key,
    required this.controller,
    required this.onSearch,
    required this.onPageChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ENCABEZADO (igual que admin)
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.sports_soccer,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Partidos Programados',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  Text(
                    'Consulta los partidos de tu categoría',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Búsqueda (igual que admin)
        TextField(
          decoration: InputDecoration(
            hintText: 'Buscar partido...',
            prefixIcon: const Icon(Icons.search, color: Colors.red),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          onChanged: onSearch,
        ),
        const SizedBox(height: 16),

        // Tabla (igual que admin pero sin acciones)
        _buildPartidosTable(context),

        // Paginación
        if (controller.totalPagesPartido > 1)
          PaginationWidget(
            currentPage: controller.currentPagePartido,
            totalPages: controller.totalPagesPartido,
            onPageChange: onPageChange,
          ),
      ],
    );
  }

  Widget _buildPartidosTable(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.red.shade50),
          dataRowHeight: 65,
          columns: const [
            DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Hora', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Competencia', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Formación', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Rival', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Ubicación', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Cancha', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: controller.paginatedPartidos.isEmpty
              ? [
                  DataRow(cells: [
                    DataCell(
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sports_soccer, size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              Text(
                                controller.searchTermPartido.isEmpty
                                    ? 'No hay partidos programados'
                                    : 'No se encontraron partidos',
                                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                  ])
                ]
              : controller.paginatedPartidos.map((p) {
                  final cronograma = controller.getCronogramaById(p.idCronogramas);
                  
                  if (cronograma == null) {
                    return DataRow(cells: List.generate(8, (index) => const DataCell(Text('Error'))));
                  }

                  final categoria = controller.miCategoria ?? 
                      Categoria(idCategorias: 0, descripcion: 'N/A', tiposCategoria: '');

                  // Buscar competencia (necesitamos cargarlas en el controller)
                  final competencia = Competencia(
                    idCompetencias: cronograma.idCompetencias ?? 0,
                    nombre: 'Competencia',
                    tipoCompetencia: '',
                    ano: 0,
                  );

                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(cronograma.fechaDeEventos),
                          ],
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              cronograma.hora != null && cronograma.hora!.isNotEmpty
                                  ? cronograma.hora!.substring(0, 5)
                                  : '-',
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Text(
                            competencia.nombre,
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            categoria.descripcion,
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(p.formacion)),
                      DataCell(
                        Row(
                          children: [
                            const Icon(Icons.shield, size: 16, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(p.equipoRival, style: const TextStyle(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      DataCell(Text(cronograma.ubicacion)),
                      DataCell(Text(cronograma.canchaPartido ?? '-')),
                    ],
                  );
                }).toList(),
        ),
      ),
    );
  }
}