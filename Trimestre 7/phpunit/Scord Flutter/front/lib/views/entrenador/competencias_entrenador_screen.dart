import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/entrenador/competencias_entrenador_controller.dart';
import '../../models/competencia_model.dart';
import '../../widgets/common/custom_alert.dart';
import '../../widgets/common/EntrenadorDrawer.dart';

class CompetenciasEntrenadorScreen extends StatefulWidget {
  const CompetenciasEntrenadorScreen({super.key});

  @override
  State<CompetenciasEntrenadorScreen> createState() => _CompetenciasEntrenadorScreenState();
}

class _CompetenciasEntrenadorScreenState extends State<CompetenciasEntrenadorScreen> {
  late CompetenciasEntrenadorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CompetenciasEntrenadorController();
    _controller.addListener(_onControllerChanged);
    _inicializar();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _inicializar() async {
    await _controller.inicializar();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _mostrarDialogoCompetencia({Competencia? competencia}) async {
    if (competencia != null) {
      _controller.prepararEdicion(competencia);
    } else {
      _controller.limpiarFormulario();
    }

    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => _DialogoCompetencia(controller: _controller),
    );

    if (resultado == true && mounted) {
      try {
        bool exito;
        if (_controller.modoEdicion) {
          exito = await _controller.actualizarCompetencia();
        } else {
          exito = await _controller.crearCompetencia();
        }

        if (exito && mounted) {
          await CustomAlert.mostrar(
            context,
            'Éxito',
            _controller.modoEdicion
                ? 'Competencia actualizada correctamente'
                : 'Competencia creada correctamente',
            Colors.green,
          );
        }
      } catch (e) {
        if (mounted) {
          await CustomAlert.mostrar(
            context,
            'Error',
            e.toString().replaceAll('Exception: ', ''),
            Colors.red,
          );
        }
      }
    }
  }

  Future<void> _eliminarCompetencia(Competencia competencia) async {
    final confirmar = await CustomAlert.confirmar(
      context,
      '¿Eliminar Competencia?',
      '¿Estás seguro de eliminar "${competencia.nombre}"?\n\nEsta acción se puede revertir desde la papelera.',
      'Sí, eliminar',
      Colors.red,
    );

    if (confirmar) {
      try {
        final exito = await _controller.eliminarCompetencia(competencia.idCompetencias);
        if (exito && mounted) {
          await CustomAlert.mostrar(
            context,
            'Éxito',
            'Competencia eliminada correctamente',
            Colors.orange,
          );
        }
      } catch (e) {
        if (mounted) {
          await CustomAlert.mostrar(
            context,
            'Error',
            e.toString().replaceAll('Exception: ', ''),
            Colors.red,
          );
        }
      }
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Competencias',
        style: TextStyle(
          color: Color(0xffe63946),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: const IconThemeData(color: Color(0xffe63946)),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
    ),
    drawer: EntrenadorDrawer(currentRoute: '/CompetenciasEntrenador'), // ✅ NUEVO
    body: _controller.loading && _controller.categoriasEntrenador.isEmpty
        ? const Center(child: CircularProgressIndicator(color: Color(0xffe63946)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xffe63946).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.emoji_events, color: Color(0xffe63946), size: 32),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gestión de Competencias',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffe63946),
                            ),
                          ),
                          Text(
                            'Administra las competencias de tus categorías',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Selector de categoría
                if (_controller.categoriasEntrenador.isNotEmpty)
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      labelStyle: const TextStyle(color: Color(0xffe63946)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.group, color: Color(0xffe63946)),
                    ),
                    value: _controller.categoriaSeleccionada,
                    items: _controller.categoriasEntrenador.map((cat) => DropdownMenuItem(
                      value: cat.idCategorias.toString(),
                      child: Text(cat.descripcion),
                    )).toList(),
                    onChanged: (value) => _controller.seleccionarCategoria(value),
                  ),
                const SizedBox(height: 20),

                // Botón agregar
                if (_controller.categoriaSeleccionada != null)
                  ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoCompetencia(),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Agregar Competencia', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffe63946),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                const SizedBox(height: 20),

                // Mensajes de error o sin datos
                if (_controller.errorMessage != null)
                  Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.orange),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _controller.errorMessage!,
                              style: const TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_controller.categoriaSeleccionada != null && _controller.competencias.isEmpty && !_controller.loading)
                  Card(
                    color: Colors.blue.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No hay competencias registradas para esta categoría',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Tabla de competencias
                if (_controller.categoriaSeleccionada != null && _controller.competencias.isNotEmpty)
                  _buildTablaCompetencias(),
              ],
            ),
          ),
  );
}

  Widget _buildTablaCompetencias() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Competencias (${_controller.competencias.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xffe63946),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xffe63946).withOpacity(0.1)),
                columns: const [
                  DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Año', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _controller.competencias.map((competencia) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            const Icon(Icons.emoji_events, color: Color(0xffe63946), size: 16),
                            const SizedBox(width: 8),
                            Text(competencia.nombre),
                          ],
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            competencia.tipoCompetencia,
                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            competencia.ano.toString(),
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                              onPressed: () => _mostrarDialogoCompetencia(competencia: competencia),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              onPressed: () => _eliminarCompetencia(competencia),
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
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DIÁLOGO DE COMPETENCIA
// ============================================================

class _DialogoCompetencia extends StatefulWidget {
  final CompetenciasEntrenadorController controller;

  const _DialogoCompetencia({required this.controller});

  @override
  State<_DialogoCompetencia> createState() => _DialogoCompetenciaState();
}

class _DialogoCompetenciaState extends State<_DialogoCompetencia> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.controller.modoEdicion ? 'Editar Competencia' : 'Nueva Competencia',
        style: const TextStyle(color: Color(0xffe63946), fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Categoría (solo lectura)
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Categoría',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.group, color: Color(0xffe63946)),
              ),
              value: widget.controller.categoriaSeleccionada,
              items: widget.controller.categoriasEntrenador.map((cat) => DropdownMenuItem(
                value: cat.idCategorias.toString(),
                child: Text(cat.descripcion),
              )).toList(),
              onChanged: widget.controller.modoEdicion ? null : (value) {
                setState(() {
                  widget.controller.seleccionarCategoria(value);
                });
              },
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: widget.controller.nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre * (máx 50 caracteres)',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.emoji_events, color: Color(0xffe63946)),
                counterText: '${widget.controller.nombreController.text.length}/50',
              ),
              maxLength: 50,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.controller.tipoController,
              decoration: InputDecoration(
                labelText: 'Tipo * (máx 30 caracteres)',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.category, color: Color(0xffe63946)),
                hintText: 'Ejemplo: Liga, Copa, Torneo',
                counterText: '${widget.controller.tipoController.text.length}/30',
              ),
              maxLength: 30,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.controller.anoController,
              decoration: InputDecoration(
                labelText: 'Año *',
                labelStyle: const TextStyle(color: Color(0xffe63946)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.calendar_today, color: Color(0xffe63946)),
                hintText: 'Ejemplo: 2024',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.controller.limpiarFormulario();
            Navigator.pop(context, false);
          },
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffe63946),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Guardar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}