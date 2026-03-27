import 'package:flutter/material.dart';
import '../../../controllers/admin/cronograma_admin_controller.dart';
import '../../../models/categoria_model.dart';
import '../../../models/competencia_model.dart';
import '../../../utils/validator.dart';
import '../cronogramas/pagination_widget.dart';

class CronogramaPartidosSection extends StatelessWidget {
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
  final Function(int?) onCompetenciaChanged;

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
    required this.onCompetenciaChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ENCABEZADO
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
                    'Gestiona los partidos y competencias',
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

        // Búsqueda
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.red.shade50),
          dataRowHeight: 65,
          columns: const [
            DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Competencia', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Formación', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Rival', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Ubicación', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Cancha', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
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
                  final cronograma = controller.cronogramas.firstWhere(
                    (c) => c.idCronogramas == p.idCronogramas,
                  );

                  final categoria = controller.categorias.firstWhere(
                    (c) => c.idCategorias == cronograma.idCategorias,
                    orElse: () => Categoria(idCategorias: 0, descripcion: 'N/A'),
                  );

                  final competencia = controller.competencias.firstWhere(
                    (c) => c.idCompetencias == cronograma.idCompetencias,
                    orElse: () => Competencia(
                      idCompetencias: 0,
                      nombre: 'N/A',
                      tipoCompetencia: '',
                      ano: 0,
                      idEquipos: 0,
                    ),
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
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                              onPressed: () => onEditar(p.idPartidos),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => onEliminar(p.idPartidos),
                              tooltip: 'Eliminar',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
        ),
      ),
    );
  }

  Widget _buildPartidoForm(BuildContext context) {
    final isEditing = controller.editingId != null && controller.editingType == 'PartidoAPI';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del formulario
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit : Icons.add_circle_outline,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Editar Partido' : 'Nuevo Partido',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1),

              if (controller.isLoadingCategorias || controller.isLoadingCompetencias)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                )
              else
                Column(
                  children: [
                    // PRIMERO: Categoría
                    _buildDropdownField<int?>(
                      label: 'Categoría',
                      icon: Icons.group,
                      hint: 'Seleccione primero la categoría',
                      value: controller.categoriaPartidoSeleccionada,
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Seleccione una categoría'),
                        ),
                        ...controller.categorias.map((cat) => DropdownMenuItem<int?>(
                              value: cat.idCategorias,
                              child: Text(cat.descripcion),
                            )),
                      ],
                      onChanged: onCategoriaChanged,
                      validator: Validator.validateCategoria,
                    ),
                    const SizedBox(height: 16),

                    // ✅ SEGUNDO: Competencia (filtrada) - VERSIÓN MEJORADA
                    Builder(
                      builder: (context) {
                        // Verificar si hay categoría seleccionada
                        final hayCategoriaSeleccionada = controller.categoriaPartidoSeleccionada != null;
                        
                        // Verificar si hay competencias disponibles
                        final hayCompetenciasDisponibles = controller.competenciasFiltradas.isNotEmpty;
                        
                        // Verificar si la competencia seleccionada existe en las filtradas
                        final competenciaValida = controller.competenciaPartidoSeleccionada != null &&
                            controller.competenciasFiltradas.any(
                              (c) => c.idCompetencias == controller.competenciaPartidoSeleccionada,
                            );

                        // Si no es válida, usar null
                        final valueToUse = competenciaValida ? controller.competenciaPartidoSeleccionada : null;

                        // Determinar si el dropdown debe estar habilitado
                        final isEnabled = hayCategoriaSeleccionada && hayCompetenciasDisponibles;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDropdownField<int?>(
                              label: 'Competencia',
                              icon: Icons.emoji_events,
                              hint: !hayCategoriaSeleccionada
                                  ? 'Primero seleccione una categoría'
                                  : !hayCompetenciasDisponibles
                                      ? 'No hay competencias disponibles para esta categoría'
                                      : 'Seleccione la competencia',
                              value: valueToUse,
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Seleccione una competencia'),
                                ),
                                ...controller.competenciasFiltradas.map((comp) => DropdownMenuItem<int?>(
                                      value: comp.idCompetencias,
                                      child: Text('${comp.nombre} (${comp.ano})'),
                                    )),
                              ],
                              onChanged: isEnabled ? onCompetenciaChanged : null,
                              validator: (value) => value == null ? 'Seleccione una competencia' : null,
                            ),
                            // ⚠️ MENSAJE DE ALERTA cuando no hay competencias
                            if (hayCategoriaSeleccionada && !hayCompetenciasDisponibles)
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
                                          'No hay competencias creadas para esta categoría. Cree una competencia primero.',
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
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fecha
                    _buildDateField(
                      controller: controller.fechaPartidoController,
                      context: context,
                    ),
                    const SizedBox(height: 16),

                    // Ubicación
                    _buildTextField(
                      controller: controller.ubicacionPartidoController,
                      label: 'Ubicación',
                      icon: Icons.location_on,
                      validator: Validator.validateUbicacion,
                    ),
                    const SizedBox(height: 16),

                    // Cancha
                    _buildTextField(
                      controller: controller.canchaPartidoController,
                      label: 'Cancha',
                      icon: Icons.sports_soccer,
                      validator: Validator.validateCancha,
                    ),
                    const SizedBox(height: 16),

                    // Equipo Rival
                    _buildTextField(
                      controller: controller.equipoRivalController,
                      label: 'Equipo Rival',
                      icon: Icons.shield,
                      validator: Validator.validateEquipoRival,
                    ),
                    const SizedBox(height: 16),

                    // Formación
                    _buildTextField(
                      controller: controller.formacionController,
                      label: 'Formación Táctica',
                      icon: Icons.grid_on,
                      validator: Validator.validateFormacion,
                    ),
                    const SizedBox(height: 24),

                    // Botones de acción
                    _buildActionButtons(isEditing),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 Widgets reutilizables para campos

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required String hint,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?)? onChanged,
    String? Function(T?)? validator,
  }) {
    final isDisabled = onChanged == null;

    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: isDisabled ? Colors.grey : Colors.red),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDisabled ? Colors.grey.shade300 : Colors.grey.shade400,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: isDisabled,
        fillColor: isDisabled ? Colors.grey.shade100 : null,
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      icon: Icon(
        Icons.arrow_drop_down,
        color: isDisabled ? Colors.grey : Colors.red,
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required BuildContext context,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Fecha del Partido',
        prefixIcon: const Icon(Icons.calendar_today, color: Colors.red),
        suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.red),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.red,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          controller.text =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        }
      },
      validator: Validator.validateFecha,
    );
  }

  Widget _buildActionButtons(bool isEditing) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isEditing ? onActualizar : onAgregar,
            icon: Icon(isEditing ? Icons.save : Icons.add),
            label: Text(isEditing ? 'Guardar Cambios' : 'Agregar Partido'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        if (isEditing) ...[
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onCancelar,
              icon: const Icon(Icons.cancel),
              label: const Text('Cancelar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}