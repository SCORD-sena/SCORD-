import 'package:flutter/material.dart';

import '../../../models/categoria_model.dart';
import '../../../models/tipo_documento_model.dart';

/// Widget reutilizable para campos de texto del formulario
class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;
  final bool isNumber;
  final bool isEmail;
  final bool isPassword;
  final String? hintText;
  final String? helperText;
  final TextInputType? keyboardType;
  final int? maxLength;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.required = false,
    this.isNumber = false,
    this.isEmail = false,
    this.isPassword = false,
    this.hintText,
    this.helperText,
    this.keyboardType,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType ?? 
            (isNumber ? TextInputType.number : 
            (isEmail ? TextInputType.emailAddress : TextInputType.text)),
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hintText,
          helperText: helperText,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.all(12),
        ),
        maxLength: maxLength,
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Este campo es obligatorio.';
          }
          if (isEmail && value != null && !value.contains('@') && value.isNotEmpty) {
            return 'Formato de correo invalido.';
          }
          return null;
        },
      ),
    );
  }
}

/// Widget para selector de fecha
class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final VoidCallback onTap;
  final bool required;

  const DatePickerField({
    super.key,
    required this.controller,
    required this.label,
    required this.onTap,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: required ? '$label *' : label,
              hintText: 'YYYY-MM-DD',
              suffixIcon: const Icon(Icons.calendar_today),
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.all(12),
            ),
            validator: (value) => (required && (value == null || value.isEmpty)) 
                ? 'Campo obligatorio.' 
                : null,
          ),
        ),
      ),
    );
  }
}

/// Widget para dropdown de tipo de documento
class TipoDocumentoDropdown extends StatelessWidget {
  final int? value;
  final List<TipoDocumento> tiposDocumento;
  final Function(int?) onChanged;

  const TipoDocumentoDropdown({
    super.key,
    required this.value,
    required this.tiposDocumento,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: const InputDecoration(
          labelText: 'Tipo de Documento *',
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.all(12),
        ),
        items: tiposDocumento.map((tipo) {
          return DropdownMenuItem(
            value: tipo.idTiposDeDocumentos,
            child: Text(tipo.descripcion),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Selecciona un tipo de documento.' : null,
      ),
    );
  }
}

/// Widget para dropdown de género
class GeneroDropdown extends StatelessWidget {
  final String? value;
  final Function(String?) onChanged;

  const GeneroDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          labelText: 'Genero *',
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.all(12),
        ),
        items: const [
          DropdownMenuItem(value: 'M', child: Text('Masculino')),
          DropdownMenuItem(value: 'F', child: Text('Femenino')),
        ],
        onChanged: onChanged,
        validator: (value) => value == null ? 'Selecciona un genero.' : null,
      ),
    );
  }
}

/// Widget para dropdown de categoría
class CategoriaDropdown extends StatelessWidget {
  final int? value;
  final List<Categoria> categorias;
  final Function(int?) onChanged;

  const CategoriaDropdown({
    super.key,
    required this.value,
    required this.categorias,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<int>(
        value: value,
        decoration: const InputDecoration(
          labelText: 'Categoria *',
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.all(12),
        ),
        items: categorias.map((cat) {
          return DropdownMenuItem(
            value: cat.idCategorias,
            child: Text(cat.descripcion),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Selecciona una categoria.' : null,
      ),
    );
  }
}

/// Widget para sección del formulario con título
class FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const FormSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}

/// Botones de acción del formulario
class FormActionButtons extends StatelessWidget {
  final bool loading;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const FormActionButtons({
    super.key,
    required this.loading,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: loading ? null : onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: loading ? null : onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}

/// Diálogo de confirmación
class ConfirmacionDialog extends StatelessWidget {
  final Map<String, String> valores;

  const ConfirmacionDialog({
    super.key,
    required this.valores,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("¿Estas Seguro?"),
      icon: const Icon(Icons.help_outline, color: Colors.blue),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(
              "Documento: ${valores['numeroDocumento']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Nombre: ${valores['primerNombre']} ${valores['segundoNombre'] ?? ''} ${valores['primerApellido']}"),
            Text("Telefono: ${valores['telefono']}"),
            Text("Correo: ${valores['correo']}"),
            const Divider(height: 10),
            Text("Tutor: ${valores['nomTutor1']} ${valores['apeTutor1']}"),
            Text("Dorsal: ${valores['dorsal']} — Posicion: ${valores['posicion']}"),
            Text("Estatura: ${valores['estatura']} cm"),
            if (valores['fechaIngresoClub'] != null && valores['fechaIngresoClub']!.isNotEmpty)
              Text("Fecha Ingreso: ${valores['fechaIngresoClub']}"),
            if (valores['fechaVencimientoMensualidad'] != null && valores['fechaVencimientoMensualidad']!.isNotEmpty)
              Text("Vencimiento Mensualidad: ${valores['fechaVencimientoMensualidad']}"),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Si, crear', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}