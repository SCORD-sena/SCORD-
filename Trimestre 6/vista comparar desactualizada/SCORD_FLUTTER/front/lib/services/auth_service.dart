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
          
          print('🔍 Token payload: $payloadMap');
          idPersonas = int.tryParse(payloadMap['sub']?.toString() ?? '');
          print('🔍 idPersonas extraído del token: $idPersonas');
        }
      } catch (e) {
        print('⚠️ Error decodificando token: $e');
      }

      // Guardar token
      await _guardarToken(token);
      print('✅ Token guardado');

      final userOriginal = data["user"] as Map<String, dynamic>;
      final userLimpio = <String, dynamic>{};
      
      // ✅ USAR EL ID DEL TOKEN
      if (idPersonas != null) {
        userLimpio['idPersonas'] = idPersonas;
      } else {
        print('⚠️ No se pudo extraer idPersonas del token');
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
      
      print('🔍 Usuario limpio a guardar: $userLimpio');
      
      final userJsonString = jsonEncode(userLimpio);
      await _guardarUsuario(userJsonString);
      print('✅ Usuario guardado');
      
      await _guardarRol(rolId);
      print('✅ Rol guardado: $rolId');
      
    } catch (e, stackTrace) {
      print('❌ ERROR al guardar datos de sesión: $e');
      print('Stack trace: $stackTrace');
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
    
    print('🔍 USER JSON RECUPERADO: $userJson');
    
    if (userJson == null || userJson.isEmpty || userJson == 'null') {
      print('❌ No hay datos de usuario guardados o son inválidos');
      return null;
    }
    
    final userMap = jsonDecode(userJson) as Map<String, dynamic>;
    print('🔍 USER MAP decodificado: $userMap');
    
    final persona = Persona.fromJson(userMap);
    print('✅ Persona creada: ${persona.nombreCompleto}, Rol: ${persona.idRoles}');
    
    return persona;
  } catch (e, stackTrace) {
    print('❌ ERROR en obtenerUsuario: $e');
    print('Stack trace: $stackTrace');
    return null;
  }
}

Future<void> limpiarTodo() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  print('🧹 Todos los datos limpiados');
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
      print('Error obteniendo datos actualizados: $e');
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
  print('🔍 Token para request: $token');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  print('🔍 Headers: $headers');
  return headers;
}
}