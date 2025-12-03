// Las funciones de validación ahora devuelven un String con el error o null si es válido.
class Validator {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'El campo "$fieldName" es obligatorio.';
    }
    return null;
  }

  static String? validateTelefono(String? value, String fieldName) {
    if (validateRequired(value, fieldName) != null) return validateRequired(value, fieldName);
    final telRegex = RegExp(r'^3\d{9}$');
    if (!telRegex.hasMatch(value!)) {
      return 'El teléfono debe iniciar con 3 y tener 10 dígitos.';
    }
    return null;
  }

  static String? validateCorreo(String? value) {
    if (validateRequired(value, 'Correo') != null) return validateRequired(value, 'Correo');
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value!)) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  static String? validateContrasena(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length < 8 || value.length > 12) {
        return 'La contraseña debe tener entre 8 y 12 caracteres.';
      }
    }
    return null;
  }

  static String? validateDorsal(String? value) {
    if (validateRequired(value, 'Dorsal') != null) return validateRequired(value, 'Dorsal');
    final dorsal = int.tryParse(value!);
    if (dorsal == null || dorsal < 1 || dorsal > 99) {
      return 'El dorsal debe ser entre 1 y 99.';
    }
    return null;
  }

  static String? validateEstatura(String? value) {
    if (validateRequired(value, 'Estatura') != null) return validateRequired(value, 'Estatura');
    final estatura = double.tryParse(value!);
    if (estatura == null || estatura < 120 || estatura > 220) {
      return 'La estatura debe estar entre 120 y 220 cm.';
    }
    return null;
  }
}