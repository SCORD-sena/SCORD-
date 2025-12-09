import 'package:flutter/material.dart';
import '../../../controllers/entrenador/cronograma_entrenador_controller.dart';
import '../../../models/categoria_model.dart';
import '../../../utils/validator.dart';
import '../../admin/cronogramas/pagination_widget.dart';

class CronogramaPartidosSection extends StatelessWidget {
  final CronogramaEntrenadorController controller;
  final GlobalKey<FormState> formKey;
  final VoidCallback onAgregar;
  final VoidCallback onActualizar;
  final Function(int) onEliminar;
  final Function(int) onEditar;
  final VoidCallback onCancelar;
  final Function(String) onSearch;
  final Function(int) onPageChange;
  final Function(int?) onCategoriaChanged;

  const CronogramaPartidosSection({
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Partidos Programados',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Búsqueda
        TextField(
          decoration: const InputDecoration(
            hintText: 'Buscar partido por formación, rival, fecha, ubicación o categoría...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: onSearch,
        ),
        const SizedBox(height: 16),

        // Tabla
        _buildPartidosTable(context),

        // Paginación
        if (controller.totalPagesPartido > 1)
          PaginationWidget(
            currentPage: controller.currentPagePartido,
            totalPages: controller.totalPagesPartido,
            onPageChange: onPageChange,
          ),

        const SizedBox(height: 24),

        // Formulario
        _buildPartidoForm(context),
      ],
    );
  }

  Widget _buildPartidosTable(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.red.shade50),
          columns: const [
            DataColumn(label: Text('Fecha')),
            DataColumn(label: Text('Cancha')),
            DataColumn(label: Text('Ubicación')),
            DataColumn(label: Text('Formación')),
            DataColumn(label: Text('Equipo Rival')),
            DataColumn(label: Text('Categoría')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: controller.paginatedPartidos.isEmpty
              ? [
                  DataRow(cells: [
                    DataCell(Text(controller.searchTermPartido.isEmpty
                        ? 'No hay partidos programados'
                        : 'No se encontraron partidos')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                    const DataCell(Text('')),
                  ])
                ]
              : controller.paginatedPartidos.map((p) {
                  final cronograma = controller.cronogramas.firstWhere(
                    (c) => c.idCronogramas == p.idCronogramas,
                    orElse: () => throw Exception('Cronograma no encontrado'),
                  );

                  final categoria = controller.categoriasAPI.firstWhere(
                    (c) => c.idCategorias == cronograma.idCategorias,
                    orElse: () => Categoria(idCategorias: 0, descripcion: 'N/A'),
                  );

                  return DataRow(cells: [
                    DataCell(Text(cronograma.fechaDeEventos)),
                    DataCell(Text(cronograma.canchaPartido ?? '-')),
                    DataCell(Text(cronograma.ubicacion)),
                    DataCell(Text(p.formacion)),
                    DataCell(Text(p.equipoRival)),
                    DataCell(Text(categoria.descripcion)),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => onEditar(p.idPartidos),
                          tooltip: 'Actualizar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onEliminar(p.idPartidos),
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

  Widget _buildPartidoForm(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.editingId != null && controller.editingType == 'PartidoAPI'
                    ? 'Editar Partido'
                    : 'Agregar Partido',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              if (controller.isLoadingCategorias)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    // Equipo Rival
                    TextFormField(
                      controller: controller.equipoRivalController,
                      decoration: const InputDecoration(
                        labelText: 'Equipo Rival',
                        border: OutlineInputBorder(),
                        hintText: 'Ingrese el nombre del equipo rival',
                      ),
                      validator: Validator.validateEquipoRival,
                    ),
                    const SizedBox(height: 16),

                    // Categoría (solo las del entrenador)
                    DropdownButtonFormField<int>(
                      value: controller.categoriaPartidoSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Seleccione una categoría')),
                        ...controller.categoriasAPI.map((cat) => DropdownMenuItem(
                              value: cat.idCategorias,
                              child: Text(cat.descripcion),
                            )),
                      ],
                      onChanged: onCategoriaChanged,
                      validator: Validator.validateCategoria,
                    ),
                    const SizedBox(height: 16),

                    // Fecha
                    TextFormField(
                      controller: controller.fechaPartidoController,
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
                          controller.fechaPartidoController.text =
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        }
                      },
                      validator: Validator.validateFecha,
                    ),
                    const SizedBox(height: 16),

                    // Ubicación
                    DropdownButtonFormField<String>(
                      value: controller.ubicacionPartidoController.text.isEmpty
                          ? null
                          : controller.ubicacionPartidoController.text,
                      decoration: const InputDecoration(
                        labelText: 'Ubicación',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Seleccione una ubicación')),
                        DropdownMenuItem(value: 'CONEJERA', child: Text('CONEJERA')),
                        DropdownMenuItem(value: 'XCOLI', child: Text('XCOLI')),
                        DropdownMenuItem(value: 'MORENA', child: Text('MORENA')),
                        DropdownMenuItem(value: 'SIBERIA', child: Text('SIBERIA')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.ubicacionPartidoController.text = value;
                        }
                      },
                      validator: (value) => Validator.validateUbicacion(
                        controller.ubicacionPartidoController.text,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Cancha
                    TextFormField(
                      controller: controller.canchaPartidoController,
                      decoration: const InputDecoration(
                        labelText: 'Cancha',
                        border: OutlineInputBorder(),
                        hintText: 'Número de cancha (1-20)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final numero = int.tryParse(value);
                          if (numero == null || numero < 1 || numero > 20) {
                            return 'La cancha debe ser un número entre 1 y 20';
                          }
                        }
                        return Validator.validateCancha(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Formación
                    DropdownButtonFormField<String>(
                      value: controller.formacionController.text.isEmpty
                          ? null
                          : controller.formacionController.text,
                      decoration: const InputDecoration(
                        labelText: 'Formación',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Seleccione una formación')),
                        DropdownMenuItem(value: '4-4-2', child: Text('4-4-2')),
                        DropdownMenuItem(value: '4-3-3', child: Text('4-3-3')),
                        DropdownMenuItem(value: '3-5-2', child: Text('3-5-2')),
                        DropdownMenuItem(value: '4-5-1', child: Text('4-5-1')),
                        DropdownMenuItem(value: '5-3-2', child: Text('5-3-2')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.formacionController.text = value;
                        }
                      },
                      validator: (value) => Validator.validateFormacion(
                        controller.formacionController.text,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botones
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: controller.editingId != null && controller.editingType == 'PartidoAPI'
                              ? onActualizar
                              : onAgregar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(controller.editingId != null && controller.editingType == 'PartidoAPI'
                              ? 'Guardar cambios'
                              : 'Agregar Partido'),
                        ),
                        if (controller.editingId != null && controller.editingType == 'PartidoAPI') ...[
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