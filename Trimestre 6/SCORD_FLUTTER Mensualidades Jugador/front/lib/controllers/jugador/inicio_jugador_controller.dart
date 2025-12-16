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

      print('🚀 === INICIANDO CARGA DE DATOS DEL JUGADOR ===');

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

      // ====== OBTENER DATOS COMPLETOS INCLUYENDO MENSUALIDAD ======
      print('📡 Llamando a fetchMisDatos()...');
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
      
      print('✅ === CARGA COMPLETA ===');
    } catch (e) {
      print('❌ Error inicializando datos del jugador: $e');
      error = 'Error al cargar los datos: $e';
      loading = false;
      onLoadingChanged();
    }
  }

  /// ====== OBTENER DATOS COMPLETOS DEL JUGADOR CON MENSUALIDAD ======
  Future<void> _obtenerDatosCompletos() async {
    try {
      print('📞 Ejecutando fetchMisDatos()...');
      datosCompletos = await _jugadorService.fetchMisDatos();

      if (datosCompletos != null) {
        print('✅ ✅ ✅ DATOS COMPLETOS OBTENIDOS:');
        print('   - fechaIngresoClub: ${datosCompletos!['fechaIngresoClub']}');
        print('   - tiempoEnClub: ${datosCompletos!['tiempoEnClub']}');
        print('   - fechaVencimientoMensualidad: ${datosCompletos!['fechaVencimientoMensualidad']}');
        print('   - diasParaVencimiento: ${datosCompletos!['diasParaVencimiento']}');
        print('   - estadoPago: ${datosCompletos!['estadoPago']}');
        print('   - mensualidadVencida: ${datosCompletos!['mensualidadVencida']}');
      } else {
        print('⚠️ ⚠️ ⚠️ datosCompletos es NULL');
      }
    } catch (e) {
      print('❌ ❌ ❌ Error en _obtenerDatosCompletos: $e');
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
        print('✅ Datos del jugador cargados: Dorsal ${jugadorData!.dorsal}, Posicion ${jugadorData!.posicion}');
      } else {
        print('⚠️ No se encontro informacion deportiva del jugador');
      }
    } catch (e) {
      print('⚠️ Error obteniendo datos del jugador: $e');
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
        print('✅ Estadisticas cargadas: ${estadisticas!.totales['total_goles']} goles');
      } else {
        print('⚠️ No hay estadisticas registradas');
      }
    } catch (e) {
      print('⚠️ Error obteniendo estadisticas: $e');
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
    print('🔍 GET fechaIngresoClub: ${datosCompletos?['fechaIngresoClub']}');
    if (datosCompletos?['fechaIngresoClub'] == null) return null;
    try {
      return DateTime.parse(datosCompletos!['fechaIngresoClub']);
    } catch (e) {
      print('❌ Error parseando fechaIngresoClub: $e');
      return null;
    }
  }

  String? get tiempoEnClubTexto {
    print('🔍 GET tiempoEnClubTexto: ${datosCompletos?['tiempoEnClub']?['texto']}');
    return datosCompletos?['tiempoEnClub']?['texto'];
  }

  DateTime? get fechaVencimientoMensualidad {
    print('🔍 GET fechaVencimientoMensualidad: ${datosCompletos?['fechaVencimientoMensualidad']}');
    if (datosCompletos?['fechaVencimientoMensualidad'] == null) return null;
    try {
      return DateTime.parse(datosCompletos!['fechaVencimientoMensualidad']);
    } catch (e) {
      print('❌ Error parseando fechaVencimientoMensualidad: $e');
      return null;
    }
  }

  String? get diasParaVencimientoTexto {
    print('🔍 GET diasParaVencimientoTexto: ${datosCompletos?['diasParaVencimiento']?['texto']}');
    return datosCompletos?['diasParaVencimiento']?['texto'];
  }

  bool get mensualidadVencida {
    print('🔍 GET mensualidadVencida: ${datosCompletos?['mensualidadVencida']}');
    return datosCompletos?['mensualidadVencida'] == true;
  }

  String get estadoPago {
    print('🔍 GET estadoPago: ${datosCompletos?['estadoPago']}');
    return datosCompletos?['estadoPago'] ?? 'sin_definir';
  }
}