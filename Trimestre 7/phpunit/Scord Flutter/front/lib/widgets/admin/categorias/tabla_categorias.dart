import 'package:flutter/material.dart';
import '../../../models/categoria_model.dart';

class TablaCategorias extends StatelessWidget {
  final List<Categoria> categorias;
  final Function(Categoria) onEditar;
  final Function(Categoria) onEliminar;

  const TablaCategorias({
    super.key,
    required this.categorias,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    if (categorias.isEmpty) {
      return _buildEstadoVacio();
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
          dataRowHeight: 60,
          columns: const [
            DataColumn(
              label: Text(
                'ID',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xffe63946),
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Descripción',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xffe63946),
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Tipo de Categoría',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xffe63946),
                  fontSize: 14,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Acciones',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xffe63946),
                  fontSize: 14,
                ),
              ),
            ),
          ],
          rows: categorias.map((categoria) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    categoria.idCategorias.toString(),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                DataCell(
                  Text(
                    categoria.descripcion,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    categoria.tiposCategoria,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón Editar
                      Tooltip(
                        message: 'Editar categoría',
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          color: Colors.blue,
                          onPressed: () => onEditar(categoria),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botón Eliminar
                      Tooltip(
                        message: 'Eliminar categoría',
                        child: IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          color: Colors.red,
                          onPressed: () => onEliminar(categoria),
                        ),
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
                'No hay categorías registradas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Presiona el botón "Nueva Categoría" para agregar una',
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