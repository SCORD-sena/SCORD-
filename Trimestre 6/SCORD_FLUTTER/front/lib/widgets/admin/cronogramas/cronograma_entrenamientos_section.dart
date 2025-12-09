import 'package:flutter/material.dart';
import '../../../controllers/admin/cronograma_admin_controller.dart';
import '../../../models/categoria_model.dart';
import '/../../utils/validator.dart';
import '../cronogramas/pagination_widget.dart';

class CronogramaEntrenamientosSection extends StatelessWidget {
  final CronogramaAdminController controller;
  final GlobalKey<FormState> formKey;
  final VoidCallback onAgregar;
  final VoidCallback onActualizar;
  final Function(int) onEliminar;
  final Function(int) onEditar;
  final VoidCallback onCancelar;
  final Function(String) onSearch;
  final Function(int) onPageChange;
  final Function(int?) onCategoriaChanged;
  final Function(String?) onSedeChanged;

  const CronogramaEntrenamientosSection({
    Key? key,
    required this.controller,
    required this.formKey,
    required this.onAgregar,
    required this.onActualizar,
    required this.onEliminar,
    required this.onEditar,
    required this.onCancelar,
    required this.onSearch,
    required this.onPageChange,
    required this.onCategoriaChanged,
    required this.onSedeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Entrenamientos Programados',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Búsqueda
        TextField(
          decoration: const InputDecoration(
            hintText: 'Buscar entrenamiento por fecha, ubicación, sede o categoría...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: onSearch,
        ),
        const SizedBox(height: 16),

        // Tabla
        _buildEntrenamientosTable(context),

        // Paginación
        if (controller.totalPagesEntrenamiento > 1)
          PaginationWidget(
            currentPage: controller.currentPageEntrenamiento,
            totalPages: controller.totalPagesEntrenamiento,
            onPageChange: onPageChange,
          ),

        const SizedBox(height: 24),

        // Formulario
        _buildEntrenamientoForm(context),
      ],
    );
  }

  Widget _buildEntrenamientosTable(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.red.shade50),
          columns: const [
            DataColumn(label: Text('Fecha')),
            DataColumn(label: Text('Tipo')),
            DataColumn(label: Text('Ubicación')),
            DataColumn(label: Text('Sede')),
            DataColumn(label: Text('Categoría')),
            DataColumn(label: Text('Descripción')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: controller.paginatedEntrenamientos.isEmpty
              ? [
                  DataRow(cells: [
                    DataCell(Text(controller.searchTermEntrenamiento.isEmpty
                        ? 'No hay entrenamientos programados'
                        : 'No se encontraron entrenamientos')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                  ])
                ]
              : controller.paginatedEntrenamientos.map((e) {
                  final categoria = controller.categorias.firstWhere(
                    (c) => c.idCategorias == e.idCategorias,
                    orElse: () => Categoria(idCategorias: 0, descripcion: 'N/A'),
                  );

                  return DataRow(cells: [
                    DataCell(Text(e.fechaDeEventos)),
                    DataCell(Text(e.tipoDeEventos)),
                    DataCell(Text(e.ubicacion)),
                    DataCell(Text(e.sedeEntrenamiento ?? '-')),
                    DataCell(Text(categoria.descripcion)),
                    DataCell(Text(e.descripcion ?? '')),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => onEditar(e.idCronogramas),
                          tooltip: 'Actualizar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onEliminar(e.idCronogramas),
                          tooltip: 'Borrar',
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
        ),
      ),
    );
  }

  Widget _buildEntrenamientoForm(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.editingId != null && controller.editingType == 'Entrenamiento'
                    ? 'Editar Entrenamiento'
                    : 'Agregar Entrenamiento',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              if (controller.isLoadingCategorias)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    // Fecha
                    TextFormField(
                      controller: controller.fechaEntrenamientoController,
                      decoration: const InputDecoration(
                        labelText: 'Fecha',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          controller.fechaEntrenamientoController.text =
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        }
                      },
                      validator: Validator.validateFecha,
                    ),
                    const SizedBox(height: 16),

                    // Ubicación
                    TextFormField(
                      controller: controller.ubicacionEntrenamientoController,
                      decoration: const InputDecoration(
                        labelText: 'Ubicación',
                        border: OutlineInputBorder(),
                      ),
                      validator: Validator.validateUbicacion,
                    ),
                    const SizedBox(height: 16),

                    // Sede
                    DropdownButtonFormField<String>(
                      value: controller.sedeEntrenamientoSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Sede',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Seleccione una sede')),
                        DropdownMenuItem(value: 'TIMIZA', child: Text('TIMIZA')),
                        DropdownMenuItem(value: 'CAYETANO CAÑIZARES', child: Text('CAYETANO CAÑIZARES')),
                        DropdownMenuItem(value: 'FONTIBON', child: Text('FONTIBON')),
                      ],
                      onChanged: onSedeChanged,
                    ),
                    const SizedBox(height: 16),

                    // Categoría
                    DropdownButtonFormField<int>(
                      value: controller.categoriaEntrenamientoSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Seleccione una categoría')),
                        ...controller.categorias.map((cat) => DropdownMenuItem(
                              value: cat.idCategorias,
                              child: Text(cat.descripcion),
                            )),
                      ],
                      onChanged: onCategoriaChanged,
                      validator: Validator.validateCategoria,
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    TextFormField(
                      controller: controller.descripcionEntrenamientoController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) => Validator.validateDescripcion(value),
                    ),
                    const SizedBox(height: 16),

                    // Botones
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: controller.editingId != null && controller.editingType == 'Entrenamiento'
                              ? onActualizar
                              : onAgregar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(controller.editingId != null && controller.editingType == 'Entrenamiento'
                              ? 'Guardar cambios'
                              : 'Agregar Entrenamiento'),
                        ),
                        if (controller.editingId != null && controller.editingType == 'Entrenamiento') ...[
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: onCancelar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}