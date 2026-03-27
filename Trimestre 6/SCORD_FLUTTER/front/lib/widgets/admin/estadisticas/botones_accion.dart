import 'package:flutter/material.dart';

class BotonesAccion extends StatelessWidget {
  final bool modoEdicion;
  final bool loading;
  final VoidCallback onAgregar;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final VoidCallback onGuardar;
  final VoidCallback onCancelar;

  const BotonesAccion({
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
<<<<<<< HEAD
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          // Botón Agregar
          ElevatedButton.icon(
            onPressed: loading ? null : onAgregar,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar', style: TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          // Mostrar Editar/Eliminar o Guardar/Cancelar
          if (!modoEdicion) ...[
            ElevatedButton.icon(
              onPressed: loading ? null : onEditar,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Editar', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: loading ? null : onEliminar,
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('Eliminar', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
=======
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
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
              ),
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: loading ? null : onGuardar,
<<<<<<< HEAD
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save, size: 18),
              label: Text(
                loading ? 'Guardando...' : 'Guardar',
                style: const TextStyle(fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
=======
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
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
              ),
            ),
            ElevatedButton.icon(
              onPressed: loading ? null : onCancelar,
<<<<<<< HEAD
              icon: const Icon(Icons.cancel, size: 18),
              label: const Text('Cancelar', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
=======
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
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
        ],
      ),
    );
  }
}