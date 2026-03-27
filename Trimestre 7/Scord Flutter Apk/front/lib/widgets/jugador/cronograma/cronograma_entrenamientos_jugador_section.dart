import 'package:flutter/material.dart';
import '../../../controllers/jugador/cronograma_jugador_controller.dart';
import '../../admin/cronogramas/pagination_widget.dart';

class CronogramaEntrenamientosJugadorSection extends StatelessWidget {
  final CronogramaJugadorController controller;
  final Function(String) onSearch;
  final Function(int) onPageChange;

  const CronogramaEntrenamientosJugadorSection({
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
        // ENCABEZADO
        const Text(
          'Entrenamientos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),

        // Búsqueda
        TextField(
          decoration: InputDecoration(
            hintText: 'Buscar entrenamiento...',
            prefixIcon: const Icon(Icons.search, color: Colors.red),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: onSearch,
        ),
        const SizedBox(height: 20),

        // Tabla mejorada
        _buildEntrenamientosTable(context),

        // Paginación
        if (controller.totalPagesEntrenamiento > 1) ...[
          const SizedBox(height: 16),
          PaginationWidget(
            currentPage: controller.currentPageEntrenamiento,
            totalPages: controller.totalPagesEntrenamiento,
            onPageChange: onPageChange,
          ),
        ],
      ],
    );
  }

  Widget _buildEntrenamientosTable(BuildContext context) {
    if (controller.paginatedEntrenamientos.isEmpty) {
      return Card(
        elevation: 0,
        color: Colors.grey.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.fitness_center, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                controller.searchTermEntrenamiento.isEmpty
                    ? 'No hay entrenamientos programados'
                    : 'No se encontraron entrenamientos',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.red.shade50),
          dataRowMinHeight: 60,
          dataRowMaxHeight: 80,
          horizontalMargin: 20,
          columnSpacing: 24,
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
          dataTextStyle: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
          columns: const [
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Fecha'),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Hora'),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Ubicación'),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Sede'),
              ),
            ),
            DataColumn(
              label: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Descripción'),
              ),
            ),
          ],
          rows: controller.paginatedEntrenamientos.map((e) {
            return DataRow(
              cells: [
                // Fecha con ícono
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          e.fechaDeEventos,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                // Hora con ícono
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          e.hora != null && e.hora!.isNotEmpty
                              ? e.hora!.substring(0, 5)
                              : '-',
                        ),
                      ],
                    ),
                  ),
                ),
                // Ubicación
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(e.ubicacion),
                  ),
                ),
                // Sede con estilo
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Text(
                        e.sedeEntrenamiento ?? '-',
                        style: TextStyle(
                          color: Colors.purple.shade900,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                // Descripción
                DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: 200,
                      child: Text(
                        e.descripcion ?? '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}