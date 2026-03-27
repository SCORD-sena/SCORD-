import 'package:flutter/material.dart';
import '../../models/persona_model.dart';
import '../../services/auth_service.dart';

/// Controlador para la lógica de InicioAdmin
class InicioAdminController {
  final AuthService _authService = AuthService();
  
  // Callbacks para actualizar el estado en el widget
  final VoidCallback onLoadingChanged;
  final VoidCallback onNavigateToLogin;
  
  // Estado
  bool _loading = false;
  Persona? _adminData;
  String? _error;
  
  InicioAdminController({
    required this.onLoadingChanged,
    required this.onNavigateToLogin,
  });
  
  // Getters
  bool get loading => _loading;
  Persona? get adminData => _adminData;
  String? get error => _error;
  
  // Setter para loading con callback
  set loading(bool value) {
    _loading = value;
    onLoadingChanged();
  }
  
  // Setter para error con callback
  set error(String? value) {
    _error = value;
    onLoadingChanged();
  }
  
  // Setter para adminData con callback
  set adminData(Persona? value) {
    _adminData = value;
    onLoadingChanged();
  }
  
  /// Inicializar datos del administrador
  Future<void> initializeAdminData() async {
    try {
      loading = true;
      error = null;

      // Pequeño delay para asegurar que los datos estén guardados
      await Future.delayed(const Duration(milliseconds: 100));

      // Verificar si hay usuario autenticado
      final token = await _authService.obtenerToken();
      final user = await _authService.obtenerUsuario();
<<<<<<< HEAD
=======
      
      print('🔍 TOKEN en InicioAdmin: $token');
      print('🔍 USER DATA en InicioAdmin: ${user?.toJson()}');
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b

      if (token == null || user == null) {
        throw Exception('No hay sesión activa. Por favor inicia sesión.');
      }

      // Verificar que el usuario sea administrador
      final rolId = user.idRoles ?? 0;
<<<<<<< HEAD
=======
      print('🔍 ROL ID VERIFICADO en InicioAdmin: $rolId');
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
      
      if (rolId != 1) {
        throw Exception('No tienes permisos de administrador');
      }

      // Intentar obtener datos actualizados de la API
      try {
        final datosActualizados = await _authService.obtenerDatosActualizados(user.idPersonas);
        adminData = datosActualizados ?? user;
      } catch (apiError) {
        // Si falla la API, usar datos guardados
<<<<<<< HEAD
        adminData = user;
      }
      
      
    } catch (e) {
=======
        print('⚠️ Usando datos guardados: $apiError');
        adminData = user;
      }
      
      print('✅ Admin data cargada: ${adminData?.nombreCompleto}');
      
    } catch (e) {
      print('❌ ERROR en initializeAdminData: $e');
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
      error = e.toString().replaceAll('Exception: ', '');

      // Redirigir al login si no hay sesión
      if (error!.contains('sesión') || error!.contains('permisos')) {
        Future.delayed(const Duration(seconds: 2), () {
          onNavigateToLogin();
        });
      }
    } finally {
      loading = false;
    }
  }
  
  /// Cerrar sesión
  Future<void> logout() async {
    try {
      await _authService.logout();
      onNavigateToLogin();
    } catch (e) {
<<<<<<< HEAD
=======
      print('❌ Error al cerrar sesión: $e');
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
      error = 'Error al cerrar sesión';
    }
  }
  
  /// Verificar si debe mostrar redirección
  bool shouldShowRedirect() {
    return error != null && (error!.contains('sesión') || error!.contains('permisos'));
  }
}