import 'package:flutter/material.dart';
import '../../../models/jugador_model.dart';
import '../../../models/categoria_model.dart';
import '../../../utils/validator.dart';

class InfoDeportivaCard extends StatelessWidget {
  final bool modoEdicion;
  final Jugador? jugadorSeleccionado;
  final Map<String, TextEditingController> controllers;
  final List<Categoria> categorias;
  final int? selectedCategoriaId;
  final Function(int?) onCategoriaChanged;

  const InfoDeportivaCard({
    super.key,
    required this.modoEdicion,
    required this.jugadorSeleccionado,
    required this.controllers,
    required this.categorias,
    required this.selectedCategoriaId,
    required this.onCategoriaChanged,
  });

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xffe63946),
        ),
      ),
    );
  }

  Widget _buildInfoDisplay(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String key,
    String label, {
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controllers[key],
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        suffixText: isOptional ? '(Opcional)' : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  Widget _buildCategoriaDropdown() {
    return DropdownButtonFormField<int>(
      value: selectedCategoriaId,
      hint: const Text('Categoría', style: TextStyle(fontSize: 13)),
      decoration: const InputDecoration(
        labelText: 'Categoría',
        labelStyle: TextStyle(fontSize: 13),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        border: OutlineInputBorder(),
      ),
      items: categorias
          .map((cat) => DropdownMenuItem(
                value: cat.idCategorias,
                child: Text(cat.descripcion, style: const TextStyle(fontSize: 13)),
              ))
          .toList(),
      onChanged: onCategoriaChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('⚽ Información Deportiva'),
            if (!modoEdicion) ...[
              _buildInfoDisplay('Dorsal:', jugadorSeleccionado?.dorsal.toString() ?? '-'),
              _buildInfoDisplay('Posición:', jugadorSeleccionado?.posicion ?? '-'),
              _buildInfoDisplay(
                'Estatura:',
                jugadorSeleccionado != null ? '${jugadorSeleccionado!.estatura} cm' : '-',
              ),
              _buildInfoDisplay('UPZ:', jugadorSeleccionado?.upz ?? '-'),
              _buildInfoDisplay(
                'Categoría:',
                categorias
                    .firstWhere(
                      (c) => c.idCategorias == jugadorSeleccionado?.idCategorias,
                      orElse: () => Categoria(idCategorias: 0, descripcion: '-', tiposCategoria: ''),
                    )
                    .descripcion,
              ),
            ] else ...[
              _buildEditableField(
                'dorsal',
                'Dorsal',
                keyboardType: TextInputType.number,
                validator: Validator.validateDorsal,
              ),
              const SizedBox(height: 8),
              _buildEditableField(
                'posicion',
                'Posición',
                validator: (v) => Validator.validateRequired(v, 'Posición'),
              ),
              const SizedBox(height: 8),
              _buildEditableField(
                'estatura',
                'Estatura (cm)',
                keyboardType: TextInputType.number,
                validator: Validator.validateEstatura,
              ),
              const SizedBox(height: 8),
              _buildEditableField('upz', 'UPZ (Opcional)', isOptional: true),
              const SizedBox(height: 8),
              _buildCategoriaDropdown(),
            ],
          ],
        ),
      ),
    );
  }
}