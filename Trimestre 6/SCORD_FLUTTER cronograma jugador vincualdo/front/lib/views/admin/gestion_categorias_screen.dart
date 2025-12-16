import 'package:flutter/material.dart';
import '../../controllers/admin/gestion_categorias_controller.dart';
import '../../models/categoria_model.dart';
import '../../widgets/common/custom_alert.dart';

class GestionCategoriasScreen extends StatefulWidget {
  const GestionCategoriasScreen({super.key});

  @override
  State<GestionCategoriasScreen> createState() => _GestionCategoriasScreenState();
}

class _GestionCategoriasScreenState extends State<GestionCategoriasScreen> {
  late GestionCategoriasController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GestionCategoriasController();
    _controller.addListener(_onControllerChanged);
    _inicializar();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _inicializar() async {
    try {
      await _controller.inicializar();
    } catch (e) {
      if (mounted) {
        CustomAlert.mostrar(
          context,
          'Error',
          'No se pudieron cargar las categorías: ${e.toString()}',
          Colors.red,
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // DIÁLOGOS
  // ============================================================

  Future<void> _mostrarDialogoCrearEditar() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _controller.modoEdicion ? 'Editar Categoría' : 'Nueva Categoría',
          style: const TextStyle(
            color: Color(0xffe63946),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller.descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción * (máx 20 caracteres)',
                  labelStyle: const TextStyle(color: Color(0xffe63946)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.description, color: Color(0xffe63946)),
                  counterText: '${_controller.descripcionController.text.length}/20',
                ),
                maxLength: 20,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller.tiposCategoriaController,
                decoration: InputDecoration(
                  labelText: 'Tipo de Categoría * (máx 30 caracteres)',
                  labelStyle: const TextStyle(color: Color(0xffe63946)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.category, color: Color(0xffe63946)),
                  counterText: '${_controller.tiposCategoriaController.text.length}/30',
                ),
                maxLength: 30,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _controller.limpiarFormulario();
              Navigator.pop(context);
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: _controller.loading ? null : () async {
              try {
                final exito = _controller.modoEdicion
                    ? await _controller.actualizarCategoria()
                    : await _controller.crearCategoria();

                if (exito && mounted) {
                  Navigator.pop(context);
                  CustomAlert.mostrar(
                    context,
                    'Éxito',
                    _controller.modoEdicion
                        ? 'Categoría actualizada correctamente'
                        : 'Categoría creada correctamente',
                    Colors.green,
                  );
                }
              } catch (e) {
                if (mounted) {
                  CustomAlert.mostrar(
                    context,
                    'Error',
                    e.toString().replaceAll('Exception: ', ''),
                    Colors.red,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffe63946),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              _controller.loading ? 'Guardando...' : 'Guardar',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEliminar(Categoria categoria) async {
    final confirmar = await CustomAlert.confirmar(
      context,
      '¿Eliminar Categoría?',
      '¿Estás seguro de eliminar "${categoria.descripcion}"?\nEsta acción no se puede deshacer.',
      'Sí, eliminar',
      Colors.red,
    );

    if (confirmar) {
      try {
        final exito = await _controller.eliminarCategoria(categoria.idCategorias);
        if (exito && mounted) {
          CustomAlert.mostrar(
            context,
            'Éxito',
            'Categoría eliminada correctamente',
            Colors.green,
          );
        }
      } catch (e) {
        if (mounted) {
          CustomAlert.mostrar(
            context,
            'Error',
            'No se pudo eliminar la categoría: ${e.toString()}',
            Colors.red,
          );
        }
      }
    }
  }

  // ============================================================
  // DRAWER
  // ============================================================

  Widget _buildDrawerItem(String title, IconData icon, String routeName) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xffe63946)),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.of(context).pop();
        
        if (routeName == '/Logout') {
          // Lógica de deslogueo
        } else if (ModalRoute.of(context)?.settings.name != routeName) {
          Navigator.of(context).pushNamed(routeName); 
        }
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SCORD - Categorías',
          style: TextStyle(
            color: Color(0xffe63946),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xffe63946)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xffe63946)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(Icons.sports_soccer, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'SCORD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Text(
                    'Menú de Navegación',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem('Inicio', Icons.home, '/InicioAdmin'),
            _buildDrawerItem('Cronograma', Icons.calendar_month, '/CronogramaAdmin'),
            _buildDrawerItem('Perfil Jugador', Icons.person_pin, '/PerfilJugadorAdmin'),
            _buildDrawerItem('Estadísticas Jugadores', Icons.bar_chart, '/EstadisticasJugadores'),
            _buildDrawerItem('Perfil Entrenador', Icons.sports_gymnastics, '/PerfilEntrenadorAdmin'),
            _buildDrawerItem('Evaluar Jugadores', Icons.rule, '/EvaluarJugadores'),
            const Divider(),
            _buildDrawerItem('Cerrar Sesión', Icons.logout, '/Logout'),
          ],
        ),
      ),
      body: _controller.loading && _controller.categorias.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xffe63946)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xffe63946).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.category,
                          color: Color(0xffe63946),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Categorías Actuales',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffe63946),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Botón Nueva Categoría
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _controller.abrirDialogoCrear();
                        _mostrarDialogoCrearEditar();
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Nueva Categoría'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tabla de categorías
                  _buildTabla(),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        color: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: const Text(
          '© 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos reservados',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildTabla() {
    if (_controller.categorias.isEmpty) {
      return Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No hay categorías registradas',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Presiona el botón "Nueva Categoría" para agregar una',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            const Color(0xffe63946).withOpacity(0.1),
          ),
          columns: const [
            DataColumn(
              label: Text(
                'Descripción',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xffe63946)),
              ),
            ),
            DataColumn(
              label: Text(
                'Tipo de Categoría',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xffe63946)),
              ),
            ),
            DataColumn(
              label: Text(
                'Acciones',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xffe63946)),
              ),
            ),
          ],
          rows: _controller.categorias.map((categoria) {
            return DataRow(
              cells: [
                DataCell(Text(categoria.descripcion)),
                DataCell(Text(categoria.tiposCategoria)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón Editar
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Editar',
                        onPressed: () {
                          _controller.abrirDialogoEditar(categoria);
                          _mostrarDialogoCrearEditar();
                        },
                      ),
                      // Botón Eliminar
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Eliminar',
                        onPressed: () => _confirmarEliminar(categoria),
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
}