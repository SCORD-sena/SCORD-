import 'package:flutter/material.dart';
import '../../../models/resultado_model.dart';

class TablaResultados extends StatelessWidget {
  final List<Resultado> resultados;
  final int? partidoSeleccionado;
  final Function(Resultado) onEditar;
  final Function(Resultado) onEliminar;

  const TablaResultados({
    super.key,
    required this.resultados,
    required this.partidoSeleccionado,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    if (partidoSeleccionado == null) {
      return _buildSinPartidoSeleccionado();
    }

    if (resultados.isEmpty) {
      return _buildEstadoVacio();
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffe63946).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.assessment, color: Color(0xffe63946)),
                const SizedBox(width: 12),
                const Text(
                  'Resultados del Partido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffe63946),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de resultados
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: resultados.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final resultado = resultados[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    resultado.marcador,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ),
                title: Text(
                  'Puntos: ${resultado.puntosObtenidos}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: resultado.observacion != null && resultado.observacion!.isNotEmpty
                    ? Text(
                        resultado.observacion!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      color: Colors.blue,
                      tooltip: 'Editar',
                      onPressed: () => onEditar(resultado),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20),
                      color: Colors.red,
                      tooltip: 'Eliminar',
                      onPressed: () => onEliminar(resultado),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSinPartidoSeleccionado() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_soccer, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Selecciona un partido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Usa los filtros para seleccionar categoría, competencia y partido',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoVacio() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No hay resultados registrados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Presiona el botón "Agregar Resultado" para registrar uno',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}