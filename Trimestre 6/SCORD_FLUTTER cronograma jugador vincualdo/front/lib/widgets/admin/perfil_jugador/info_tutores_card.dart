import 'package:flutter/material.dart';
import '../../../models/jugador_model.dart';
import '../../../utils/validator.dart';

class InfoTutoresCard extends StatelessWidget {
  final bool modoEdicion;
  final Jugador? jugadorSeleccionado;
  final Map<String, TextEditingController> controllers;

  const InfoTutoresCard({
    super.key,
    required this.modoEdicion,
    required this.jugadorSeleccionado,
    required this.controllers,
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('👨‍👩‍👦 Información de Tutores'),
            if (!modoEdicion) ...[
              _buildInfoDisplay(
                'Nombre del Tutor:',
                '${jugadorSeleccionado?.nomTutor1 ?? ''} ${jugadorSeleccionado?.apeTutor1 ?? ''}'
                        .trim()
                        .isEmpty
                    ? '-'
                    : '${jugadorSeleccionado?.nomTutor1 ?? ''} ${jugadorSeleccionado?.apeTutor1 ?? ''}',
              ),
              _buildInfoDisplay('Teléfono del Tutor:', jugadorSeleccionado?.telefonoTutor ?? '-'),
            ] else ...[
              _buildEditableField(
                'nomTutor1',
                'Nom. Tutor 1',
                validator: (v) => Validator.validateRequired(v, 'Nombre Tutor 1'),
              ),
              const SizedBox(height: 8),
              _buildEditableField(
                'apeTutor1',
                'Ape. Tutor 1',
                validator: (v) => Validator.validateRequired(v, 'Apellido Tutor 1'),
              ),
              const SizedBox(height: 8),
              _buildEditableField('nomTutor2', 'Nom. Tutor 2', isOptional: true),
              const SizedBox(height: 8),
              _buildEditableField('apeTutor2', 'Ape. Tutor 2', isOptional: true),
              const SizedBox(height: 8),
              _buildEditableField(
                'telefonoTutor',
                'Teléfono Tutor',
                keyboardType: TextInputType.phone,
                validator: (v) => Validator.validateTelefono(v, 'Teléfono del Tutor'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}