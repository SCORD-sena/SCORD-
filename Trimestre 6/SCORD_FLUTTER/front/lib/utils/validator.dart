import 'package:flutter/material.dart';

// Las funciones de validación ahora devuelven un String con el error o null si es válido.
class Validator {
  // ========== VALIDACIONES GENERALES ==========
  
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

  // ========== VALIDACIONES DE ESTADÍSTICAS ==========
  
  /// Valida los datos de estadísticas completos
  static bool validarEstadisticas(Map<String, String> formData, BuildContext context) {
    final camposNumericos = [
      {'key': 'goles', 'label': 'Goles'},
      {'key': 'golesDeCabeza', 'label': 'Goles de Cabeza'},
      {'key': 'minutosJugados', 'label': 'Minutos Jugados'},
      {'key': 'asistencias', 'label': 'Asistencias'},
      {'key': 'tirosApuerta', 'label': 'Tiros a Puerta'},
      {'key': 'tarjetasRojas', 'label': 'Tarjetas Rojas'},
      {'key': 'tarjetasAmarillas', 'label': 'Tarjetas Amarillas'},
      {'key': 'arcoEnCero', 'label': 'Arco en Cero'},
    ];

    for (final campo in camposNumericos) {
      final valor = formData[campo['key']];
      if (valor != null && valor.isNotEmpty) {
        final parsedValue = int.tryParse(valor);
        if (parsedValue == null || parsedValue < 0) {
          _mostrarAlerta(
            context, 
            'Valor inválido', 
            'El campo "${campo['label']}" debe ser un número positivo.', 
            Colors.orange
          );
          return false;
        }
      }
    }

    if (formData['minutosJugados'] != null && formData['minutosJugados']!.isNotEmpty) {
      final minutos = int.tryParse(formData['minutosJugados']!);
      if (minutos != null && minutos > 120) {
        _mostrarAlerta(
          context, 
          'Minutos inválidos', 
          'Los minutos jugados no pueden ser mayores a 120 por partido.', 
          Colors.red
        );
        return false;
      }
    }
    
    return true;
  }

  /// Valida un campo numérico de estadística individual
  static String? validateEstadisticaNumerica(String? value, String fieldName, {int? max}) {
    if (value != null && value.isNotEmpty) {
      final numero = int.tryParse(value);
      if (numero == null || numero < 0) {
        return 'El campo "$fieldName" debe ser un número positivo.';
      }
      if (max != null && numero > max) {
        return 'El campo "$fieldName" no puede ser mayor a $max.';
      }
    }
    return null;
  }

  /// Valida minutos jugados específicamente
  static String? validateMinutosJugados(String? value) {
    if (validateRequired(value, 'Minutos Jugados') != null) {
      return validateRequired(value, 'Minutos Jugados');
    }
    return validateEstadisticaNumerica(value, 'Minutos Jugados', max: 120);
  }

  /// Valida goles
  static String? validateGoles(String? value) {
    if (validateRequired(value, 'Goles') != null) {
      return validateRequired(value, 'Goles');
    }
    return validateEstadisticaNumerica(value, 'Goles');
  }

  /// Valida asistencias
  static String? validateAsistencias(String? value) {
    if (validateRequired(value, 'Asistencias') != null) {
      return validateRequired(value, 'Asistencias');
    }
    return validateEstadisticaNumerica(value, 'Asistencias');
  }

  // ========== MÉTODO PRIVADO PARA MOSTRAR ALERTAS ==========
  
  static Future<void> _mostrarAlerta(
    BuildContext context, 
    String title, 
    String content, 
    Color color
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: color)),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar', style: TextStyle(color: Color(0xffe63946))),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
  // ============================================
// VALIDADORES PARA PERFIL ENTRENADOR
// ============================================

// Validar teléfono colombiano (debe iniciar con 3 y tener 10 dígitos)
static String? validarTelefonoColombia(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El teléfono es obligatorio';
  }
  
  final telRegex = RegExp(r'^3\d{9}$');
  if (!telRegex.hasMatch(value)) {
    return 'El teléfono debe iniciar con 3 y tener 10 dígitos';
  }
  
  return null;
}

// Validar correo electrónico
static String? validarCorreo(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'El correo es obligatorio';
  }
  
  final emailRegex = RegExp(r'\S+@\S+\.\S+');
  if (!emailRegex.hasMatch(value)) {
    return 'Ingresa un correo válido';
  }
  
  return null;
}

// Validar contraseña (8-12 caracteres, opcional)
static String? validarContrasenaOpcional(String? value) {
  if (value == null || value.isEmpty) {
    return null; // Es opcional
  }
  
  if (value.length < 8 || value.length > 12) {
    return 'La contraseña debe tener entre 8 y 12 caracteres';
  }
  
  return null;
}

// Validar años de experiencia (0-50)
static String? validarAnosExperiencia(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Los años de experiencia son obligatorios';
  }
  
  final anos = int.tryParse(value);
  if (anos == null || anos < 0 || anos > 50) {
    return 'Los años de experiencia deben estar entre 0 y 50';
  }
  
  return null;
}

// Validar campo de texto obligatorio
static String? validarCampoObligatorio(String? value, String nombreCampo) {
  if (value == null || value.trim().isEmpty) {
    return 'El campo "$nombreCampo" es obligatorio';
  }
  return null;
}

// Validar que al menos una categoría esté seleccionada
static String? validarCategoriasSeleccionadas(List<int>? categorias) {
  if (categorias == null || categorias.isEmpty) {
    return 'Debes seleccionar al menos una categoría';
  }
  return null;
}

// Validar fecha de nacimiento (no puede ser futura)
static String? validarFechaNacimiento(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'La fecha de nacimiento es obligatoria';
  }
  
  try {
    final fecha = DateTime.parse(value);
    final hoy = DateTime.now();
    
    if (fecha.isAfter(hoy)) {
      return 'La fecha de nacimiento no puede ser futura';
    }
    
    return null;
  } catch (e) {
    return 'Fecha inválida';
  }
}
}