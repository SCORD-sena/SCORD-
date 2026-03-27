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

  // ====== DATOS DE MENSUALIDAD ======
  Map<String, dynamic>? datosCompletos;

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

      // Verificar autenticacion
      final isLoggedIn = await _authService.estaLogueado();
      if (!isLoggedIn) {
        error = 'Debe iniciar sesion para acceder';
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

      await _obtenerDatosCompletos();

      // Obtener datos deportivos del jugador desde el backend (metodo alternativo)
      await _obtenerDatosJugador();

      // Obtener estadisticas del jugador
      if (jugadorData != null) {
        await _obtenerEstadisticas();
      }

      loading = false;
      error = null;
      onLoadingChanged();

    } catch (e) {
      error = 'Error al cargar los datos: $e';
      loading = false;
      onLoadingChanged();
    }
  }

  /// ====== OBTENER DATOS COMPLETOS DEL JUGADOR CON MENSUALIDAD ======
  Future<void> _obtenerDatosCompletos() async {
    try {
      datosCompletos = await _jugadorService.fetchMisDatos();

      if (datosCompletos != null) {
      } else {
      }
    } catch (e) {
      datosCompletos = null;
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
      } else {
      }
    } catch (e) {
      jugadorData = null;
    }
  }

  /// Obtener estadisticas del jugador
  Future<void> _obtenerEstadisticas() async {
    try {
      if (jugadorData?.idJugadores == null) return;

      estadisticas = await _rendimientoService.obtenerEstadisticasTotales(
        jugadorData!.idJugadores,
      );

      if (estadisticas != null) {
      } else {
      }
    } catch (e) {
      estadisticas = null;
    }
  }

  /// Cerrar sesion
  Future<void> logout() async {
    await _authService.logout();
    onNavigateToLogin();
  }

  /// Verificar si debe mostrar redireccion
  bool shouldShowRedirect() {
    return error != null && 
           (error!.contains('iniciar sesion') || error!.contains('permisos'));
  }

  // ====== GETTERS PARA DATOS DE MENSUALIDAD ======

  DateTime? get fechaIngresoClub {
    if (datosCompletos?['fechaIngresoClub'] == null) return null;
    try {
      return DateTime.parse(datosCompletos!['fechaIngresoClub']);
    } catch (e) {
      return null;
    }
  }

  String? get tiempoEnClubTexto {
    return datosCompletos?['tiempoEnClub']?['texto'];
  }

  DateTime? get fechaVencimientoMensualidad {
    if (datosCompletos?['fechaVencimientoMensualidad'] == null) return null;
    try {
      return DateTime.parse(datosCompletos!['fechaVencimientoMensualidad']);
    } catch (e) {
      return null;
    }
  }

  String? get diasParaVencimientoTexto {
    return datosCompletos?['diasParaVencimiento']?['texto'];
  }

  bool get mensualidadVencida {
    return datosCompletos?['mensualidadVencida'] == true;
  }

  String get estadoPago {
    return datosCompletos?['estadoPago'] ?? 'sin_definir';
  }
}