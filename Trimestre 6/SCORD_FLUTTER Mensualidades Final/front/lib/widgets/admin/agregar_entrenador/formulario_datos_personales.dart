import 'package:flutter/material.dart';
import '/models/tipo_documento_model.dart';

class FormularioDatosPersonales extends StatelessWidget {
  final TextEditingController numeroDocumentoController;
  final TextEditingController primerNombreController;
  final TextEditingController segundoNombreController;
  final TextEditingController primerApellidoController;
  final TextEditingController segundoApellidoController;
  final List<TipoDocumento> tiposDocumento;
  final int? tipoDocumentoSeleccionado;
  final String? generoSeleccionado;
  final DateTime? fechaNacimiento;
  final Function(int?) onTipoDocumentoChanged;
  final Function(String?) onGeneroChanged;
  final Function() onFechaPressed;

  const FormularioDatosPersonales({
    super.key,
    required this.numeroDocumentoController,
    required this.primerNombreController,
    required this.segundoNombreController,
    required this.primerApellidoController,
    required this.segundoApellidoController,
    required this.tiposDocumento,
    required this.tipoDocumentoSeleccionado,
    required this.generoSeleccionado,
    required this.fechaNacimiento,
    required this.onTipoDocumentoChanged,
    required this.onGeneroChanged,
    required this.onFechaPressed,
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
              'Datos Personales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xffe63946),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: numeroDocumentoController,
              decoration: const InputDecoration(
                labelText: 'Número de Documento *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value?.trim().isEmpty ?? true ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              value: tipoDocumentoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Tipo de Documento *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Seleccionar')),
                ...tiposDocumento.map((tipo) => DropdownMenuItem(
                      value: tipo.idTiposDeDocumentos,
                      child: Text(tipo.descripcion),
                    )),
              ],
              onChanged: onTipoDocumentoChanged,
              validator: (value) => value == null ? 'Selecciona un tipo' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: primerNombreController,
              decoration: const InputDecoration(
                labelText: 'Primer Nombre *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (value) =>
                  value?.trim().isEmpty ?? true ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: segundoNombreController,
              decoration: const InputDecoration(
                labelText: 'Segundo Nombre',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: primerApellidoController,
              decoration: const InputDecoration(
                labelText: 'Primer Apellido *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (value) =>
                  value?.trim().isEmpty ?? true ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: segundoApellidoController,
              decoration: const InputDecoration(
                labelText: 'Segundo Apellido',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: generoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Género *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Seleccionar')),
                DropdownMenuItem(value: 'M', child: Text('Masculino')),
                DropdownMenuItem(value: 'F', child: Text('Femenino')),
              ],
              onChanged: onGeneroChanged,
              validator: (value) => value == null ? 'Selecciona un género' : null,
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: onFechaPressed,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha de Nacimiento *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                child: Text(
                  fechaNacimiento != null
                      ? '${fechaNacimiento!.day.toString().padLeft(2, '0')}/${fechaNacimiento!.month.toString().padLeft(2, '0')}/${fechaNacimiento!.year}'
                      : 'Seleccionar fecha',
                  style: TextStyle(
                    color: fechaNacimiento != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}