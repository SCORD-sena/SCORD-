import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/categoria_model.dart';
import '../../models/jugador_model.dart';
import '../../models/rendimiento_model.dart';
import '../../services/rendimiento_service.dart';
import '../../services/api_service.dart';
import '../../utils/validator.dart';


class EstadisticasController extends ChangeNotifier {
  final RendimientoService _rendimientoService = RendimientoService();
  final ApiService _apiService = ApiService();

  // State
  List<Jugador> jugadores = [];
  List<Categoria> categorias = [];
  String? categoriaSeleccionadaId;
  Jugador? jugadorSeleccionado;
  List<Jugador> jugadoresFiltrados = [];
  EstadisticasTotales? estadisticasTotales;
  bool modoEdicion = false;
  bool loading = false;
  UltimoRegistro? ultimoRegistro;

  Map<String, String> formData = {
    'goles': "",
    'golesDeCabeza': "",
    'minutosJugados': "",
    'asistencias': "",
    'tirosApuerta': "",
    'tarjetasRojas': "",
    'tarjetasAmarillas': "",
    'fuerasDeLugar': "",
    'arcoEnCero': "",
  };

  // Inicialización
  Future<void> inicializar() async {
    await cargarDatosIniciales();
  }

  Future<void> cargarDatosIniciales() async {
    await fetchCategorias();
    await fetchJugadores();
  }

  // Filtrado de jugadores
  void filtrarJugadores(String? categoriaId) {
    if (categoriaId != null) {
      final id = int.tryParse(categoriaId);
      jugadoresFiltrados = jugadores.where((j) => j.categoria?.idCategorias == id).toList();
      jugadorSeleccionado = null;
      estadisticasTotales = null;
      modoEdicion = false;
    } else {
      jugadoresFiltrados = [];
      jugadorSeleccionado = null;
      estadisticasTotales = null;
      modoEdicion = false;
    }
    notifyListeners();
  }

  // Fetch de datos
  Future<void> fetchJugadores() async {
    try {
      final res = await _apiService.get('/jugadores');
      
      if (res.statusCode == 200) {
        final jsonResponse = json.decode(res.body);
        
        List<dynamic> data;
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          data = jsonResponse['data'] as List;
        } else if (jsonResponse is List) {
          data = jsonResponse;
        } else {
          throw Exception('Formato de respuesta inesperado');
        }
        
        final jugadoresParsed = <Jugador>[];
        for (var i = 0; i < data.length; i++) {
          try {
            final jugador = Jugador.fromJson(data[i] as Map<String, dynamic>);
            jugadoresParsed.add(jugador);
          } catch (e) {
            print('Error parseando jugador en índice $i: $e');
            continue;
          }
        }
        
        jugadores = jugadoresParsed;
        
        if (categoriaSeleccionadaId != null) {
          filtrarJugadores(categoriaSeleccionadaId);
        }
        notifyListeners();
      }
    } catch (e) {
      print('Error cargando jugadores: $e');
      rethrow;
    }
  }

  Future<void> fetchCategorias() async {
    try {
      final res = await _apiService.get('/categorias');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        categorias = (data as List).map((i) => Categoria.fromJson(i)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error cargando categorías: $e');
    }
  }

  Future<void> fetchEstadisticasTotales(int idJugador) async {
    loading = true;
    notifyListeners();
    
    try {
      final estadisticas = await _rendimientoService.obtenerEstadisticasTotales(idJugador);
      if (estadisticas != null) {
        estadisticasTotales = estadisticas;
      }
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Edición
  void activarEdicion() {
    if (jugadorSeleccionado == null) {
      throw Exception('No hay jugador seleccionado');
    }
    cargarUltimoRegistroParaEditar();
  }

  Future<void> cargarUltimoRegistroParaEditar() async {
    try {
      final idJugador = jugadorSeleccionado!.idJugadores;
      final registro = await _rendimientoService.obtenerUltimoRegistro(idJugador);

      if (registro != null) {
        ultimoRegistro = registro;
        formData = {
          'goles': registro.goles.toString(),
          'golesDeCabeza': registro.golesDeCabeza.toString(),
          'minutosJugados': registro.minutosJugados.toString(),
          'asistencias': registro.asistencias.toString(),
          'tirosApuerta': registro.tirosApuerta.toString(),
          'tarjetasRojas': registro.tarjetasRojas.toString(),
          'tarjetasAmarillas': registro.tarjetasAmarillas.toString(),
          'fuerasDeLugar': registro.fuerasDeLugar.toString(),
          'arcoEnCero': registro.arcoEnCero.toString(),
        };
        modoEdicion = true;
        notifyListeners();
      } else {
        throw Exception('No hay estadísticas registradas para este jugador');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> guardarCambios(BuildContext context) async {
    if (!Validator.validarEstadisticas(formData, context)) return false;

    loading = true;
    notifyListeners();

    try {
      if (ultimoRegistro == null || jugadorSeleccionado == null) {
        throw Exception("No se encontró el registro o el jugador para actualizar.");
      }

      final dataToUpdate = UltimoRegistro(
        idRendimientos: ultimoRegistro!.idRendimientos,
        idPartidos: ultimoRegistro!.idPartidos,
        goles: int.tryParse(formData['goles']!) ?? 0,
        golesDeCabeza: int.tryParse(formData['golesDeCabeza']!) ?? 0,
        minutosJugados: int.tryParse(formData['minutosJugados']!) ?? 0,
        asistencias: int.tryParse(formData['asistencias']!) ?? 0,
        tirosApuerta: int.tryParse(formData['tirosApuerta']!) ?? 0,
        tarjetasRojas: int.tryParse(formData['tarjetasRojas']!) ?? 0,
        tarjetasAmarillas: int.tryParse(formData['tarjetasAmarillas']!) ?? 0,
        fuerasDeLugar: int.tryParse(formData['fuerasDeLugar']!) ?? 0,
        arcoEnCero: int.tryParse(formData['arcoEnCero']!) ?? 0,
      ).toUpdateJson(jugadorSeleccionado!.idJugadores);

      final exito = await _rendimientoService.actualizarRendimiento(
        ultimoRegistro!.idRendimientos, 
        dataToUpdate
      );

      if (exito) {
        await fetchEstadisticasTotales(jugadorSeleccionado!.idJugadores);
        cancelarEdicion();
        return true;
      } else {
        throw Exception('Error al actualizar');
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void cancelarEdicion() {
    modoEdicion = false;
    ultimoRegistro = null;
    formData = {
      'goles': "",
      'golesDeCabeza': "",
      'minutosJugados': "",
      'asistencias': "",
      'tirosApuerta': "",
      'tarjetasRojas': "",
      'tarjetasAmarillas': "",
      'fuerasDeLugar': "",
      'arcoEnCero': "",
    };
    notifyListeners();
  }

  Future<bool> eliminarEstadistica() async {
    if (jugadorSeleccionado == null) {
      throw Exception('No hay jugador seleccionado');
    }

    loading = true;
    notifyListeners();

    try {
      final idJugador = jugadorSeleccionado!.idJugadores;
      final registro = await _rendimientoService.obtenerUltimoRegistro(idJugador);

      if (registro != null) {
        final exito = await _rendimientoService.eliminarRendimiento(registro.idRendimientos);

        if (exito) {
          await fetchEstadisticasTotales(idJugador);
          cancelarEdicion();
          return true;
        } else {
          throw Exception('Error al eliminar');
        }
      } else {
        throw Exception('No hay estadísticas para eliminar');
      }
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Seleccionar jugador
  void seleccionarJugador(int? idJugador) {
    if (idJugador != null) {
      jugadorSeleccionado = jugadores.firstWhere((j) => j.idJugadores == idJugador);
      fetchEstadisticasTotales(idJugador);
    } else {
      jugadorSeleccionado = null;
      estadisticasTotales = null;
    }
    notifyListeners();
  }

  void seleccionarCategoria(String? categoriaId) {
    categoriaSeleccionadaId = categoriaId;
    filtrarJugadores(categoriaId);
  }

  // Actualizar campo del formulario
  void actualizarCampo(String campo, String valor) {
    formData[campo] = valor;
    notifyListeners();
  }

  // Helper para calcular edad
  String calcularEdad(DateTime? fechaNacimiento) { 
    if (fechaNacimiento == null) return "-";
    
    final hoy = DateTime.now();
    int edad = hoy.year - fechaNacimiento.year;
    final mes = hoy.month - fechaNacimiento.month;
    
    if (mes < 0 || (mes == 0 && hoy.day < fechaNacimiento.day)) {
      edad--;
    }
    
    return edad.toString();
  }

  @override
  void dispose() {
    super.dispose();
  }
}