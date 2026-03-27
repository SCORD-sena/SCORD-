import 'package:flutter/material.dart';
import '../../controllers/admin/gestion_competencias_controller.dart';
import '../../models/competencia_model.dart';
import '../../widgets/admin/competencias/dialogo_competencia.dart';
import '../../widgets/admin/competencias/tabla_competencias.dart';
import '../../widgets/common/custom_alert.dart';
import '../../widgets/common/admin_drawer.dart';

class GestionCompetenciasScreen extends StatefulWidget {
  const GestionCompetenciasScreen({super.key});

  @override
  State<GestionCompetenciasScreen> createState() => _GestionCompetenciasScreenState();
}

class _GestionCompetenciasScreenState extends State<GestionCompetenciasScreen> {
  late GestionCompetenciasController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GestionCompetenciasController();
    _controller.addListener(() => setState(() {}));
    _controller.inicializar();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleNueva() async {
    _controller.abrirDialogoCrear();
    final resultado = await showDialog<bool>(
      context: context,
      builder: (_) => DialogoCompetencia(controller: _controller),
    );

    if (resultado == true) {
      try {
        await _controller.crearCompetencia();
        if (mounted) await CustomAlert.mostrar(context, 'Éxito', 'Competencia creada', Colors.green);
      } catch (e) {
        if (mounted) await CustomAlert.mostrar(context, 'Error', e.toString().replaceAll('Exception: ', ''), Colors.red);
      }
    }
  }

  Future<void> _handleEditar(Competencia comp) async {
    _controller.abrirDialogoEditar(comp);
    final resultado = await showDialog<bool>(
      context: context,
      builder: (_) => DialogoCompetencia(controller: _controller),
    );

    if (resultado == true) {
      try {
        await _controller.actualizarCompetencia();
        if (mounted) await CustomAlert.mostrar(context, 'Éxito', 'Competencia actualizada', Colors.green);
      } catch (e) {
        if (mounted) await CustomAlert.mostrar(context, 'Error', e.toString().replaceAll('Exception: ', ''), Colors.red);
      }
    }
  }

  Future<void> _handleEliminar(Competencia comp) async {
    final confirmar = await CustomAlert.confirmar(
      context,
      '¿Eliminar?',
      '¿Eliminar "${comp.nombre}"?',
      'Sí, eliminar',
      Colors.red,
    );

    if (confirmar) {
      try {
        await _controller.eliminarCompetencia(comp.idCompetencias);
        if (mounted) await CustomAlert.mostrar(context, 'Éxito', 'Competencia eliminada', Colors.green);
      } catch (e) {
        if (mounted) await CustomAlert.mostrar(context, 'Error', e.toString(), Colors.red);
      }
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'SCORD - Competencias',
        style: TextStyle(
          color: Color(0xffe63946),
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Color(0xffe63946)),
    ),
    
    // ✅ SOLO ESTA LÍNEA CAMBIA:
    drawer: AdminDrawer(currentRoute: '/GestionCompetencias'),
    
    body: _controller.loading
        ? const Center(child: CircularProgressIndicator(color: Color(0xffe63946)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.emoji_events, color: Colors.orange, size: 32),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Competencias',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffe63946),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _handleNueva,
                  icon: const Icon(Icons.add),
                  label: const Text('Nueva Competencia'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 20),
                TablaCompetencias(
                  competencias: _controller.competencias,
                  onEditar: _handleEditar,
                  onEliminar: _handleEliminar,
                ),
              ],
            ),
          ),
  );
}
}