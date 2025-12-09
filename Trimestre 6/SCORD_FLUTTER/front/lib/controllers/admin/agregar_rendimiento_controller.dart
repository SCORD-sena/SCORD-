import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/categoria_model.dart';
import '../../models/jugador_model.dart';
import '../../models/partido_model.dart';
import '../../services/rendimiento_service.dart';
import '../../services/api_service.dart';

class AgregarRendimientoController extends ChangeNotifier {
  final RendimientoService _rendimientoService = RendimientoService();
  final ApiService _apiService = ApiService();

  // State
  bool loading = false;
  List<Jugador> jugadores = [];
  List<Categoria> categorias = [];
  List<Partido> partidos = [];
  String? categoriaSeleccionada;
  List<Jugador> jugadoresFiltrados = [];
  String? jugadorSeleccionado;
  String? partidoSeleccionado;

  // Controllers de texto
  final TextEditingController golesController = TextEditingController(text: "0");
  final TextEditingController asistenciasController = TextEditingController(text: "0");
  final TextEditingController minutosJugadosController = TextEditingController(text: "0");
  final TextEditingController golesDeCabezaController = TextEditingController(text: "0");
  final TextEditingController tirosApuertaController = TextEditingController(text: "0");
  final TextEditingController fuerasDeLugarController = TextEditingController(text: "0");
  final TextEditingController tarjetasAmarillasController = TextEditingController(text: "0");
  final TextEditingController tarjetasRojasController = TextEditingController(text: "0");
  final TextEditingController arcoEnCeroController = TextEditingController(text: "0");

  // Inicialización
  Future<void> inicializar() async {
    await cargarDatos();
  }

  Future<void> cargarDatos() async {
    try {
      final jugadoresRes = await _apiService.get('/jugadores');
      final categoriasRes = await _apiService.get('/categorias');
      final partidosRes = await _apiService.get('/partidos');

      if (jugadoresRes.statusCode == 200 && 
          categoriasRes.statusCode == 200 && 
          partidosRes.statusCode == 200) {
        
        final jugadoresData = json.decode(jugadoresRes.body);
        final categoriasData = json.decode(categoriasRes.body);
        final partidosData = json.decode(partidosRes.body);

        List<dynamic> jugadoresList;
        if (jugadoresData is Map && jugadoresData.containsKey('data')) {
          jugadoresList = jugadoresData['data'] as List;
        } else {
          jugadoresList = jugadoresData as List;
        }

        jugadores = jugadoresList.map((j) => Jugador.fromJson(j)).toList();
        categorias = (categoriasData as List).map((c) => Categoria.fromJson(c)).toList();
        partidos = (partidosData as List).map((p) => Partido.fromJson(p)).toList();
        
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Filtrado de jugadores
  void filtrarJugadores(String? categoriaId) {
    if (categoriaId != null) {
      final id = int.tryParse(categoriaId);
      jugadoresFiltrados = jugadores.where((j) => j.categoria?.idCategorias == id).toList();
      jugadorSeleccionado = null;
    } else {
      jugadoresFiltrados = [];
      jugadorSeleccionado = null;
    }
    notifyListeners();
  }

  // Selección
  void seleccionarCategoria(String? value) {
    categoriaSeleccionada = value;
    filtrarJugadores(value);
  }

  void seleccionarJugador(String? value) {
    jugadorSeleccionado = value;
    notifyListeners();
  }

  void seleccionarPartido(String? value) {
    partidoSeleccionado = value;
    notifyListeners();
  }

  // Validación
  String? validarFormulario() {
    if (categoriaSeleccionada == null || categoriaSeleccionada!.isEmpty) {
      return 'Debes seleccionar una categoría';
    }

    if (jugadorSeleccionado == null || jugadorSeleccionado!.isEmpty) {
      return 'Debes seleccionar un jugador';
    }

    if (partidoSeleccionado == null || partidoSeleccionado!.isEmpty) {
      return 'Debes seleccionar un partido';
    }

    final camposObligatorios = [
      {'controller': golesController, 'label': 'Goles'},
      {'controller': asistenciasController, 'label': 'Asistencias'},
      {'controller': minutosJugadosController, 'label': 'Minutos Jugados'},
    ];

    for (final campo in camposObligatorios) {
      final controller = campo['controller'] as TextEditingController;
      final label = campo['label'] as String;
      final valor = controller.text;

      if (valor.isEmpty) {
        return 'El campo "$label" es obligatorio';
      }

      final numero = int.tryParse(valor);
      if (numero == null || numero < 0) {
        return 'El campo "$label" debe ser un número positivo';
      }
    }

    final minutos = int.tryParse(minutosJugadosController.text);
    if (minutos != null && minutos > 120) {
      return 'Los minutos jugados no pueden ser mayores a 120';
    }

    return null;
  }

  // Crear estadística
  Future<bool> crearEstadistica() async {
    final error = validarFormulario();
    if (error != null) {
      throw Exception(error);
    }

    loading = true;
    notifyListeners();

    try {
      final estadisticaData = {
        'Goles': int.tryParse(golesController.text) ?? 0,
        'GolesDeCabeza': int.tryParse(golesDeCabezaController.text) ?? 0,
        'MinutosJugados': int.tryParse(minutosJugadosController.text) ?? 0,
        'Asistencias': int.tryParse(asistenciasController.text) ?? 0,
        'TirosApuerta': int.tryParse(tirosApuertaController.text) ?? 0,
        'TarjetasRojas': int.tryParse(tarjetasRojasController.text) ?? 0,
        'TarjetasAmarillas': int.tryParse(tarjetasAmarillasController.text) ?? 0,
        'FuerasDeLugar': int.tryParse(fuerasDeLugarController.text) ?? 0,
        'ArcoEnCero': int.tryParse(arcoEnCeroController.text) ?? 0,
        'idPartidos': int.parse(partidoSeleccionado!),
        'idJugadores': int.parse(jugadorSeleccionado!),
      };

      final exito = await _rendimientoService.crearRendimiento(estadisticaData);

      if (!exito) {
        throw Exception('Error al guardar la estadística');
      }

      return true;
    } catch (e) {
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // Limpiar recursos
  @override
  void dispose() {
    golesController.dispose();
    asistenciasController.dispose();
    minutosJugadosController.dispose();
    golesDeCabezaController.dispose();
    tirosApuertaController.dispose();
    fuerasDeLugarController.dispose();
    tarjetasAmarillasController.dispose();
    tarjetasRojasController.dispose();
    arcoEnCeroController.dispose();
    super.dispose();
  }
}