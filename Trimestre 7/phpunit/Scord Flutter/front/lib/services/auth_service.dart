import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/persona_model.dart';

class AuthService {
  // Login y guardar token + datos de usuario
 Future<Map<String, dynamic>> login(String correo, String contrasena) async {
  final url = Uri.parse("$baseUrl/login");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "correo": correo,
      "contrasena": contrasena,
    }),
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200 && data["success"] == true) {
    try {
      final token = data["token"] as String;
      
      // ✅ EXTRAER idPersonas del token JWT
      int? idPersonas;
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          // Normalizar el padding base64
          String normalized = payload;
          while (normalized.length % 4 != 0) {
            normalized += '=';
          }
          
          final payloadString = utf8.decode(base64Url.decode(normalized));
          final payloadMap = jsonDecode(payloadString) as Map<String, dynamic>;
          idPersonas = int.tryParse(payloadMap['sub']?.toString() ?? '');
        }
      } catch (e) {
        rethrow;
      }

      // Guardar token
      await _guardarToken(token);

      final userOriginal = data["user"] as Map<String, dynamic>;
      final userLimpio = <String, dynamic>{};
      
      // ✅ USAR EL ID DEL TOKEN
      if (idPersonas != null) {
        userLimpio['idPersonas'] = idPersonas;
      } else {
        userLimpio['idPersonas'] = 0; // Valor por defecto
      }
      
      userLimpio['NumeroDeDocumento'] = userOriginal['NumeroDeDocumento'];
      userLimpio['Nombre1'] = userOriginal['Nombre1'];
      userLimpio['Nombre2'] = userOriginal['Nombre2'];
      userLimpio['Apellido1'] = userOriginal['Apellido1'];
      userLimpio['Apellido2'] = userOriginal['Apellido2'];
      userLimpio['Genero'] = userOriginal['Genero'];
      userLimpio['Telefono'] = userOriginal['Telefono'];
      userLimpio['Direccion'] = userOriginal['Direccion'];
      userLimpio['FechaDeNacimiento'] = userOriginal['FechaDeNacimiento'];
      userLimpio['correo'] = userOriginal['correo'];
      userLimpio['EpsSisben'] = userOriginal['EpsSisben'];
      
      // Solo guardar el ID del tipo de documento
      if (userOriginal['idTiposDeDocumentos'] != null) {
        if (userOriginal['idTiposDeDocumentos'] is Map) {
          userLimpio['idTiposDeDocumentos'] = userOriginal['idTiposDeDocumentos']['idTiposDeDocumentos'];
        } else {
          userLimpio['idTiposDeDocumentos'] = userOriginal['idTiposDeDocumentos'];
        }
      }
      
      // Extraer rol
      int rolId = 0;
      if (userOriginal['Rol'] != null && userOriginal['Rol']['idRoles'] != null) {
        rolId = userOriginal['Rol']['idRoles'] as int;
        userLimpio['idRoles'] = rolId;
      } else if (userOriginal['idRoles'] != null) {
        rolId = userOriginal['idRoles'] as int;
        userLimpio['idRoles'] = rolId;
      }
      
      final userJsonString = jsonEncode(userLimpio);
      await _guardarUsuario(userJsonString);
      
      await _guardarRol(rolId);
      
    } catch (e) {
      throw Exception('Error al guardar los datos de sesión');
    }
  }

  return data;
}

  // Guardar token
  Future<void> _guardarToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Guardar usuario completo
  Future<void> _guardarUsuario(String userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', userData);
  }

  // Guardar rol
  Future<void> _guardarRol(int rol) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('rol', rol);
  }

  // Obtener token
  Future<String?> obtenerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Obtener usuario como objeto Persona
  Future<Persona?> obtenerUsuario() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    
    if (userJson == null || userJson.isEmpty || userJson == 'null') {
      return null;
    }
    
    final userMap = jsonDecode(userJson) as Map<String, dynamic>;
    
    final persona = Persona.fromJson(userMap);
    
    return persona;
  } catch (e) {  
    return null;
  }
}

Future<void> limpiarTodo() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

  // Obtener rol
  Future<int?> obtenerRol() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('rol');
  }

  // Verificar si está logueado
  Future<bool> estaLogueado() async {
    final token = await obtenerToken();
    return token != null;
  }

  // Obtener datos actualizados del usuario desde la API
  Future<Persona?> obtenerDatosActualizados(int idPersona) async {
    try {
      final token = await obtenerToken();
      final url = Uri.parse('$baseUrl/personas/$idPersona');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Persona.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    await prefs.remove('rol');
  }

  // Obtener headers con token para otras peticiones
  Future<Map<String, String>> obtenerHeaders() async {
  final token = await obtenerToken();
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  return headers;
}
}