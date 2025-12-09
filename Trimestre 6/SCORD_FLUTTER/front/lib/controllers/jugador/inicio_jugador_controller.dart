import '/../services/auth_service.dart';
import '/../services/jugador_service.dart';
import '/../services/rendimiento_service.dart';
import '/../models/persona_model.dart';
import '/../models/jugador_model.dart';
import '/../models/rendimiento_model.dart';

class InicioJugadorController {
  final AuthService _authService = AuthService();
  final JugadorService _jugadorService = JugadorService();
  final RendimientoService _rendimientoService = RendimientoService();

  // Callbacks
  final Function() onLoadingChanged;
  final Function() onNavigateToLogin;

  // Estado
  bool loading = true;
  String? error;
  Persona? jugadorPersona;
  Jugador? jugadorData;
  EstadisticasTotales? estadisticas;

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
      print('🔍 Rol obtenido: $rol');

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

      print('✅ Datos de persona cargados: ${jugadorPersona!.nombreCompleto}');

      // Obtener datos deportivos del jugador desde el backend
      await _obtenerDatosJugador();

      // Obtener estadísticas del jugador
      if (jugadorData != null) {
        await _obtenerEstadisticas();
      }

      loading = false;
      error = null;
      onLoadingChanged();
    } catch (e) {
      print('❌ Error inicializando datos del jugador: $e');
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
        print('✅ Datos del jugador cargados: Dorsal ${jugadorData!.dorsal}, Posición ${jugadorData!.posicion}');
      } else {
        print('⚠️ No se encontró información deportiva del jugador');
      }
    } catch (e) {
      print('⚠️ Error obteniendo datos del jugador: $e');
      jugadorData = null;
    }
  }

  /// Obtener estadísticas del jugador
  Future<void> _obtenerEstadisticas() async {
    try {
      if (jugadorData?.idJugadores == null) return;

      estadisticas = await _rendimientoService.obtenerEstadisticasTotales(
        jugadorData!.idJugadores,
      );

      if (estadisticas != null) {
        print('✅ Estadísticas cargadas: ${estadisticas!.totales['total_goles']} goles');
      } else {
        print('⚠️ No hay estadísticas registradas');
      }
    } catch (e) {
      print('⚠️ Error obteniendo estadísticas: $e');
      estadisticas = null;
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