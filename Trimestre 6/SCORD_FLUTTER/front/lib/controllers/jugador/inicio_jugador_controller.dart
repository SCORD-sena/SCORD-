import '/../services/auth_service.dart';
import '/../services/jugador_service.dart';
import '/../models/persona_model.dart';
import '/../models/jugador_model.dart';

class InicioJugadorController {
  final AuthService _authService = AuthService();
  final JugadorService _jugadorService = JugadorService();

  // Callbacks
  final Function() onLoadingChanged;
  final Function() onNavigateToLogin;

  // Estado
  bool loading = true;
  String? error;
  Persona? jugadorPersona;
  Jugador? jugadorData;

  InicioJugadorController({
    required this.onLoadingChanged,
    required this.onNavigateToLogin,
  });

  /// Inicializar datos del jugador
  Future<void> initializeJugadorData() async {
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

      // Verificar rol de jugador (idRoles = 3)
      final rol = await _authService.obtenerRol();

      if (rol != 3) {
        error = 'No tiene permisos de jugador';
        loading = false;
        onLoadingChanged();
        await Future.delayed(const Duration(seconds: 2));
        onNavigateToLogin();
        return;
      }

      // Obtener datos de la persona desde SharedPreferences
      jugadorPersona = await _authService.obtenerUsuario();

      if (jugadorPersona == null) {
        error = 'No se pudieron cargar los datos del usuario';
        loading = false;
        onLoadingChanged();
        return;
      }


      // Obtener datos deportivos del jugador desde el backend
      await _obtenerDatosJugador();

      loading = false;
      error = null;
      onLoadingChanged();
    } catch (e) {
      error = 'Error al cargar los datos: $e';
      loading = false;
      onLoadingChanged();
    }
  }

  /// Obtener datos deportivos del jugador desde el API
  Future<void> _obtenerDatosJugador() async {
    try {
      if (jugadorPersona?.idPersonas == null) return;

      jugadorData = await _jugadorService.fetchJugadorByPersonaId(
        jugadorPersona!.idPersonas,
      );

      if (jugadorData != null) {
      }
    } catch (e) {
      jugadorData = null;
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