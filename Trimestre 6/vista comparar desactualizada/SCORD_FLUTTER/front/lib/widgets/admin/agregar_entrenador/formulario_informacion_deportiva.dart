import 'package:flutter/material.dart';
import '/models/categoria_model.dart';

class FormularioInformacionDeportiva extends StatelessWidget {
  final TextEditingController anosExperienciaController;
  final TextEditingController cargoController;
  final List<Categoria> categorias;
  final List<int> categoriasSeleccionadas;
  final Function(int, bool) onCategoriaChanged;

  const FormularioInformacionDeportiva({
    super.key,
    required this.anosExperienciaController,
    required this.cargoController,
    required this.categorias,
    required this.categoriasSeleccionadas,
    required this.onCategoriaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Deportiva',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xffe63946),
              ),
            ),
            const SizedBox(height: 12),

            // Años de Experiencia
            TextFormField(
              controller: anosExperienciaController,
              decoration: const InputDecoration(
                labelText: 'Años de Experiencia *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) return 'Campo obligatorio';
                final anos = int.tryParse(value!);
                if (anos == null || anos < 0 || anos > 50) {
                  return 'Debe estar entre 0 y 50';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Cargo
            TextFormField(
              controller: cargoController,
              decoration: const InputDecoration(
                labelText: 'Cargo *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (value) =>
                  value?.trim().isEmpty ?? true ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 12),

            // Categorías
            const Text(
              'Categorías * (Selecciona una o más)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xffe63946),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: categorias.map((cat) {
                  return CheckboxListTile(
                    title: Text(
                      cat.descripcion,
                      style: const TextStyle(fontSize: 14),
                    ),
                    value: categoriasSeleccionadas.contains(cat.idCategorias),
                    dense: true,
                    onChanged: (value) => onCategoriaChanged(cat.idCategorias, value ?? false),
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