import 'package:flutter/material.dart';
import '../../../models/jugador_model.dart';
import '../../../utils/validator.dart';

class InfoContactoEntrenadorCard extends StatelessWidget {
  final bool modoEdicion;
  final Jugador? jugadorSeleccionado;
  final Map<String, TextEditingController> controllers;

  const InfoContactoEntrenadorCard({
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
    final persona = jugadorSeleccionado?.persona;

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('📞 Información de Contacto'),
            if (!modoEdicion) ...[
              _buildInfoDisplay('Teléfono:', persona?.telefono ?? '-'),
              _buildInfoDisplay('Dirección:', persona?.direccion ?? '-'),
              _buildInfoDisplay('Email:', persona?.correo ?? '-'),
              _buildInfoDisplay('EPS:', persona?.epsSisben ?? '-'),
            ] else ...[
              _buildEditableField(
                'telefono',
                'Teléfono',
                keyboardType: TextInputType.phone,
                validator: (v) => Validator.validateTelefono(v, 'Teléfono'),
              ),
              const SizedBox(height: 8),
              _buildEditableField(
                'direccion',
                'Dirección',
                validator: (v) => Validator.validateRequired(v, 'Dirección'),
              ),
              const SizedBox(height: 8),
              _buildEditableField(
                'correo',
                'Email',
                keyboardType: TextInputType.emailAddress,
                validator: Validator.validateCorreo,
              ),
              const SizedBox(height: 8),
              _buildEditableField('epsSisben', 'EPS/Sisbén', isOptional: true),
            ],
          ],
        ),
      ),
    );
  }
}