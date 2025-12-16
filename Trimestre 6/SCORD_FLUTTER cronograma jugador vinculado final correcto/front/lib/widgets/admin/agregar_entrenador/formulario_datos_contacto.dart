import 'package:flutter/material.dart';

class FormularioDatosContacto extends StatelessWidget {
  final TextEditingController telefonoController;
  final TextEditingController direccionController;
  final TextEditingController correoController;
  final TextEditingController contrasenaController;
  final TextEditingController epsSisbenController;

  const FormularioDatosContacto({
    super.key,
    required this.telefonoController,
    required this.direccionController,
    required this.correoController,
    required this.contrasenaController,
    required this.epsSisbenController,
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
              'Datos de Contacto',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xffe63946),
              ),
            ),
            const SizedBox(height: 12),

            // Teléfono
            TextFormField(
              controller: telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono *',
                border: OutlineInputBorder(),
                isDense: true,
                hintText: '3XXXXXXXXX',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) return 'Campo obligatorio';
                if (!RegExp(r'^3\d{9}$').hasMatch(value!)) {
                  return 'Debe iniciar con 3 y tener 10 dígitos';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Dirección
            TextFormField(
              controller: direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección *',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              validator: (value) =>
                  value?.trim().isEmpty ?? true ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 12),

            // Correo
            TextFormField(
              controller: correoController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico *',
                border: OutlineInputBorder(),
                isDense: true,
                hintText: 'ejemplo@correo.com',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) return 'Campo obligatorio';
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value!)) {
                  return 'Correo inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Contraseña
            TextFormField(
              controller: contrasenaController,
              decoration: const InputDecoration(
                labelText: 'Contraseña *',
                border: OutlineInputBorder(),
                isDense: true,
                helperText: '8–12 caracteres',
              ),
              obscureText: true,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) return 'Campo obligatorio';
                if (value!.length < 8 || value.length > 12) {
                  return 'Debe tener entre 8 y 12 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // EPS/Sisben
            TextFormField(
              controller: epsSisbenController,
              decoration: const InputDecoration(
                labelText: 'EPS/Sisben',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}