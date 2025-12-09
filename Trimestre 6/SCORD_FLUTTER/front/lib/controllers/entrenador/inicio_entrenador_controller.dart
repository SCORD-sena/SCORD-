import '../../services/auth_service.dart';
import '../../services/entrenador_service.dart';
import '../../models/persona_model.dart';

class InicioEntrenadorController {
  final AuthService _authService = AuthService();
  final EntrenadorService _entrenadorService = EntrenadorService();

  // Callbacks
  final Function() onLoadingChanged;
  final Function() onNavigateToLogin;

  // Estado
  bool loading = true;
  String? error;
  Persona? entrenadorData;
  String? categoriaEntrenador;

  InicioEntrenadorController({
    required this.onLoadingChanged,
    required this.onNavigateToLogin,
  });

  /// Inicializar datos del entrenador
  Future<void> initializeEntrenadorData() async {
    try {
      loading = true;
      error = null;
      onLoadingChanged();

      // Verificar autenticación
      final isLoggedIn = await _authService.estaLogueado();
      if (!isLoggedIn) {
        error = 'Debe iniciar sesión para acceder';
        loading = false;
        onLoadingChanged();
        await Future.delayed(const Duration(seconds: 2));
        onNavigateToLogin();
        return;
      }

      // Verificar rol de entrenador (idRoles = 2)
      final rol = await _authService.obtenerRol();
      print('🔍 Rol obtenido: $rol');

      if (rol != 2) {
        error = 'No tiene permisos de entrenador';
        loading = false;
        onLoadingChanged();
        await Future.delayed(const Duration(seconds: 2));
        onNavigateToLogin();
        return;
      }

      // Obtener datos del entrenador desde SharedPreferences
      entrenadorData = await _authService.obtenerUsuario();

      if (entrenadorData == null) {
        error = 'No se pudieron cargar los datos del entrenador';
        loading = false;
        onLoadingChanged();
        return;
      }

      print('✅ Datos del entrenador cargados: ${entrenadorData!.nombreCompleto}');

      // Obtener categoría del entrenador desde el backend
      await _obtenerCategoriaEntrenador();

      loading = false;
      error = null;
      onLoadingChanged();
    } catch (e) {
      print('❌ Error inicializando datos del entrenador: $e');
      error = 'Error al cargar los datos: $e';
      loading = false;
      onLoadingChanged();
    }
  }

  /// Obtener categoría del entrenador desde el API
  Future<void> _obtenerCategoriaEntrenador() async {
    try {
      if (entrenadorData?.idPersonas == null) return;

      final categoria = await _entrenadorService.obtenerCategoriaEntrenador(
        entrenadorData!.idPersonas,
      );

      categoriaEntrenador = categoria;
      print('✅ Categoría del entrenador: $categoriaEntrenador');
    } catch (e) {
      print('⚠️ Error obteniendo categoría del entrenador: $e');
      categoriaEntrenador = 'No asignada';
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    await _authService.logout();
    onNavigateToLogin();
  }

  /// Verificar si debe mostrar redirección
  bool shouldShowRedirect() {
    return error != null && 
           (error!.contains('iniciar sesión') || error!.contains('permisos'));
  }
}