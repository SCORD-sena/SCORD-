import 'package:flutter/material.dart';

class BotonesAccionEntrenador extends StatelessWidget {
  final bool modoEdicion;
  final bool loading;
  final VoidCallback onAgregar;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final VoidCallback onGuardar;
  final VoidCallback onCancelar;

  const BotonesAccionEntrenador({
    super.key,
    required this.modoEdicion,
    required this.loading,
    required this.onAgregar,
    required this.onEditar,
    required this.onEliminar,
    required this.onGuardar,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: onAgregar,
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            label: const Text(
              'Agregar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 36),
            ),
          ),

          if (!modoEdicion) ...[
            ElevatedButton.icon(
              onPressed: onEditar,
              icon: const Icon(Icons.edit, color: Colors.white, size: 16),
              label: const Text(
                'Editar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(0, 36),
              ),
            ),
            ElevatedButton.icon(
              onPressed: onEliminar,
              icon: const Icon(Icons.delete, color: Colors.white, size: 16),
              label: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(0, 36),
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: loading ? null : onGuardar,
              icon: loading 
                ? const SizedBox(
                    width: 16, 
                    height: 16, 
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                  ) 
                : const Icon(Icons.save, color: Colors.white, size: 16),
              label: Text(
                loading ? "Guardando..." : "Guardar",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(0, 36),
              ),
            ),
            ElevatedButton.icon(
              onPressed: loading ? null : onCancelar,
              icon: const Icon(Icons.cancel, color: Colors.white, size: 16),
              label: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(0, 36),
              ),
            ),
          ]
        ],
      ),
    );
  }
}