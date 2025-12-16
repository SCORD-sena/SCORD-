import 'package:flutter/material.dart';
import '../../../controllers/admin/cronograma_admin_controller.dart';
import '../../../models/categoria_model.dart';
import '../../../utils/validator.dart';
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
        // 🆕 ENCABEZADO MEJORADO
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: Colors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Entrenamientos Programados',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'Gestiona las sesiones de entrenamiento',
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
            hintText: 'Buscar entrenamiento...',
            prefixIcon: const Icon(Icons.search, color: Colors.green),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.green.shade50),
          dataRowHeight: 65,
          columns: const [
            DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Ubicación', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Sede', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: controller.paginatedEntrenamientos.isEmpty
              ? [
                  DataRow(cells: [
                    DataCell(
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.fitness_center, size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              Text(
                                controller.searchTermEntrenamiento.isEmpty
                                    ? 'No hay entrenamientos programados'
                                    : 'No se encontraron entrenamientos',
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
                  ])
                ]
              : controller.paginatedEntrenamientos.map((e) {
                  final categoria = controller.categorias.firstWhere(
                    (c) => c.idCategorias == e.idCategorias,
                    orElse: () => Categoria(idCategorias: 0, descripcion: 'N/A'),
                  );


                  return DataRow(
                    cells: [
  DataCell(
    Row(
      children: [
        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(e.fechaDeEventos),
      ],
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
  DataCell(Text(e.ubicacion)),
  DataCell(
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        e.sedeEntrenamiento ?? '-',
        style: TextStyle(
          color: Colors.purple.shade900,
          fontSize: 12,
        ),
      ),
    ),
  ),
  DataCell(
    SizedBox(
      width: 150,
      child: Text(
        e.descripcion ?? '',
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    ),
  ),
  DataCell(
    Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
          onPressed: () => onEditar(e.idCronogramas),
          tooltip: 'Editar',
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          onPressed: () => onEliminar(e.idCronogramas),
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

  Widget _buildEntrenamientoForm(BuildContext context) {
    final isEditing = controller.editingId != null && controller.editingType == 'Entrenamiento';

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
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit : Icons.add_circle_outline,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'Editar Entrenamiento' : 'Nuevo Entrenamiento',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1),

              if (controller.isLoadingCategorias || controller.isLoadingCompetencias)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: Colors.green),
                  ),
                )
              else
                Column(
  children: [
    // Categoría
    _buildDropdownField<int?>(
      label: 'Categoría',
      icon: Icons.group,
      hint: 'Seleccione la categoría',
      value: controller.categoriaEntrenamientoSeleccionada,
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

    // Fecha
    _buildDateField(
      controller: controller.fechaEntrenamientoController,
      context: context,
    ),
    const SizedBox(height: 16),

    // Ubicación
    _buildTextField(
      controller: controller.ubicacionEntrenamientoController,
      label: 'Ubicación',
      icon: Icons.location_on,
      validator: Validator.validateUbicacion,
    ),
    const SizedBox(height: 16),

    // Sede
    _buildDropdownField<String?>(
      label: 'Sede de Entrenamiento',
      icon: Icons.stadium,
      hint: 'Seleccione la sede',
      value: controller.sedeEntrenamientoSeleccionada,
      items: const [
        DropdownMenuItem<String?>(value: null, child: Text('Seleccione una sede')),
        DropdownMenuItem<String?>(value: 'TIMIZA', child: Text('TIMIZA')),
        DropdownMenuItem<String?>(value: 'CAYETANO CAÑIZARES', child: Text('CAYETANO CAÑIZARES')),
        DropdownMenuItem<String?>(value: 'FONTIBON', child: Text('FONTIBON')),
      ],
      onChanged: onSedeChanged,
    ),
    const SizedBox(height: 16),

    // Descripción
    _buildTextField(
      controller: controller.descripcionEntrenamientoController,
      label: 'Descripción',
      icon: Icons.description,
      maxLines: 3,
      validator: Validator.validateDescripcion,
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
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
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
        prefixIcon: Icon(icon, color: isDisabled ? Colors.grey : Colors.green),
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
          borderSide: const BorderSide(color: Colors.green, width: 2),
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
        color: isDisabled ? Colors.grey : Colors.green,
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
        labelText: 'Fecha del Entrenamiento',
        prefixIcon: const Icon(Icons.calendar_today, color: Colors.green),
        suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green, width: 2),
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
                  primary: Colors.green,
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
            label: Text(isEditing ? 'Guardar Cambios' : 'Agregar Entrenamiento'),
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