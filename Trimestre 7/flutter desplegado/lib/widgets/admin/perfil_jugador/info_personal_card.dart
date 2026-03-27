import 'package:flutter/material.dart';
import '../../../models/jugador_model.dart';
import '../../../models/tipo_documento_model.dart';
import '../../../utils/validator.dart';

class InfoPersonalCard extends StatelessWidget {
  final bool modoEdicion;
  final Jugador? jugadorSeleccionado;
  final Map<String, TextEditingController> controllers;
  final List<TipoDocumento> tiposDocumento;
  final int? selectedTipoDocumentoId;
  final String? selectedGenero;
  final DateTime? selectedFechaNacimiento;
  final Function(int?) onTipoDocumentoChanged;
  final Function(String?) onGeneroChanged;
  final Function(DateTime?) onFechaChanged;
  final String Function(DateTime?) calcularEdad;

  const InfoPersonalCard({
    super.key,
    required this.modoEdicion,
    required this.jugadorSeleccionado,
    required this.controllers,
    required this.tiposDocumento,
    required this.selectedTipoDocumentoId,
    required this.selectedGenero,
    required this.selectedFechaNacimiento,
    required this.onTipoDocumentoChanged,
    required this.onGeneroChanged,
    required this.onFechaChanged,
    required this.calcularEdad,
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
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controllers[key],
      keyboardType: keyboardType,
      obscureText: isPassword,
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

  Widget _buildDateField(BuildContext context) {
    Future<void> selectDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedFechaNacimiento ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        onFechaChanged(picked);
      }
    }

    return GestureDetector(
      onTap: selectDate,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controllers['fechaNacimiento'],
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            labelText: 'Fecha de Nacimiento',
            labelStyle: TextStyle(fontSize: 13),
            hintText: 'dd/mm/aaaa',
            suffixIcon: Icon(Icons.calendar_today, size: 18),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            border: OutlineInputBorder(),
          ),
          validator: (v) => Validator.validateRequired(v, 'Fecha de Nacimiento'),
        ),
      ),
    );
  }

  Widget _buildTipoDocumentoDropdown() {
    return DropdownButtonFormField<int>(
      value: selectedTipoDocumentoId,
      hint: const Text('Tipo Doc.', style: TextStyle(fontSize: 13)),
      decoration: const InputDecoration(
        labelText: 'Tipo de Documento',
        labelStyle: TextStyle(fontSize: 13),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        border: OutlineInputBorder(),
      ),
      items: tiposDocumento
          .map((td) => DropdownMenuItem(
                value: td.idTiposDeDocumentos,
                child: Text(td.descripcion, style: const TextStyle(fontSize: 13)),
              ))
          .toList(),
      onChanged: onTipoDocumentoChanged,
    );
  }

  Widget _buildGeneroDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedGenero,
      hint: const Text('Género', style: TextStyle(fontSize: 13)),
      decoration: const InputDecoration(
        labelText: 'Género',
        labelStyle: TextStyle(fontSize: 13),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'M', child: Text('Masculino', style: TextStyle(fontSize: 13))),
        DropdownMenuItem(value: 'F', child: Text('Femenino', style: TextStyle(fontSize: 13))),
      ],
      onChanged: onGeneroChanged,
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
            _buildSectionTitle('👤 Información Personal'),
            if (!modoEdicion) ...[
              _buildInfoDisplay(
                'Nombres:',
                '${persona?.nombre1 ?? ''} ${persona?.nombre2 ?? ''}'.trim().isEmpty
                    ? '-'
                    : '${persona?.nombre1 ?? ''} ${persona?.nombre2 ?? ''}',
              ),
              _buildInfoDisplay(
                'Apellidos:',
                '${persona?.apellido1 ?? ''} ${persona?.apellido2 ?? ''}'.trim().isEmpty
                    ? '-'
                    : '${persona?.apellido1 ?? ''} ${persona?.apellido2 ?? ''}',
              ),
              _buildInfoDisplay('Edad:', calcularEdad(persona?.fechaDeNacimiento)),
              _buildInfoDisplay(
                'Fecha de Nacimiento:',
                persona?.fechaDeNacimiento != null
                    ? '${persona!.fechaDeNacimiento.day.toString().padLeft(2, '0')}/${persona.fechaDeNacimiento.month.toString().padLeft(2, '0')}/${persona.fechaDeNacimiento.year}'
                    : '-',
              ),
              _buildInfoDisplay('Documento:', persona?.numeroDeDocumento ?? '-'),
              _buildInfoDisplay('Tipo de Documento:', persona?.tiposDeDocumentos?.descripcion ?? '-'),
              _buildInfoDisplay(
                'Género:',
                persona?.genero == 'M'
                    ? 'Masculino'
                    : persona?.genero == 'F'
                        ? 'Femenino'
                        : '-',
              ),
            ] else ...[
              _buildEditableField(
                'primerNombre',
                'Primer Nombre',
                validator: (v) => Validator.validateRequired(v, 'Primer Nombre'),
              ),
              const SizedBox(height: 8),
              _buildEditableField('segundoNombre', 'Segundo Nombre', isOptional: true),
              const SizedBox(height: 8),
              _buildEditableField(
                'primerApellido',
                'Primer Apellido',
                validator: (v) => Validator.validateRequired(v, 'Primer Apellido'),
              ),
              const SizedBox(height: 8),
              _buildEditableField('segundoApellido', 'Segundo Apellido', isOptional: true),
              const SizedBox(height: 8),
              _buildDateField(context),
              const SizedBox(height: 8),
              _buildEditableField(
                'numeroDocumento',
                'Documento',
                validator: (v) => Validator.validateRequired(v, 'Número de Documento'),
              ),
              const SizedBox(height: 8),
              _buildTipoDocumentoDropdown(),
              const SizedBox(height: 8),
              _buildGeneroDropdown(),
              const SizedBox(height: 8),
              _buildEditableField(
                'contrasena',
                'Contraseña (Opcional)',
                isOptional: true,
                isPassword: true,
                validator: Validator.validateContrasena,
              ),
            ],
          ],
        ),
      ),
    );
  }
}