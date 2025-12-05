import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'dart:convert';
import '../../models/categoria_model.dart';
import '../../models/jugador_model.dart';
import '../../models/partido_model.dart';
import '../../services/rendimiento_service.dart';

class AgregarRendimientoScreen extends StatefulWidget {
  const AgregarRendimientoScreen({super.key});

  @override
  State<AgregarRendimientoScreen> createState() => _AgregarRendimientoScreenState();
}

class _AgregarRendimientoScreenState extends State<AgregarRendimientoScreen> {
  final RendimientoService _rendimientoService = RendimientoService();
  final ApiService _apiService = ApiService();
  
  bool loading = false;
  List<Jugador> jugadores = [];
  List<Categoria> categorias = [];
  List<Partido> partidos = [];
  String? categoriaSeleccionada;
  List<Jugador> jugadoresFiltrados = [];

  final TextEditingController golesController = TextEditingController(text: "0");
  final TextEditingController asistenciasController = TextEditingController(text: "0");
  final TextEditingController minutosJugadosController = TextEditingController(text: "0");
  final TextEditingController golesDeCabezaController = TextEditingController(text: "0");
  final TextEditingController tirosApuertaController = TextEditingController(text: "0");
  final TextEditingController fuerasDeLugarController = TextEditingController(text: "0");
  final TextEditingController tarjetasAmarillasController = TextEditingController(text: "0");
  final TextEditingController tarjetasRojasController = TextEditingController(text: "0");
  final TextEditingController arcoEnCeroController = TextEditingController(text: "0");

  String? jugadorSeleccionado;
  String? partidoSeleccionado;

  @override
void initState() {
  super.initState();
  cargarDatos();
}

 Future<void> cargarDatos() async {
  try {
    final jugadoresRes = await _apiService.get('/jugadores');
    final categoriasRes = await _apiService.get('/categorias');
    final partidosRes = await _apiService.get('/partidos');

    if (jugadoresRes.statusCode == 200 && categoriasRes.statusCode == 200 && partidosRes.statusCode == 200) {
      final jugadoresData = json.decode(jugadoresRes.body);
      final categoriasData = json.decode(categoriasRes.body);
      final partidosData = json.decode(partidosRes.body);

      List<dynamic> jugadoresList;
      if (jugadoresData is Map && jugadoresData.containsKey('data')) {
        jugadoresList = jugadoresData['data'] as List;
      } else {
        jugadoresList = jugadoresData as List;
      }

      setState(() {
        jugadores = jugadoresList.map((j) => Jugador.fromJson(j)).toList();
        categorias = (categoriasData as List).map((c) => Categoria.fromJson(c)).toList();
        partidos = (partidosData as List).map((p) => Partido.fromJson(p)).toList();
      });
    }
  } catch (e) {
    mostrarAlerta('Error', 'No se pudieron cargar los datos necesarios: ${e.toString()}', Colors.red);
  }
}

  void filtrarJugadores(String? categoriaId) {
    if (categoriaId != null) {
      final id = int.tryParse(categoriaId);
     final filtrados = jugadores.where((j) => j.categoria?.idCategorias == id).toList();
      setState(() {
        jugadoresFiltrados = filtrados;
        jugadorSeleccionado = null;
      });
    } else {
      setState(() {
        jugadoresFiltrados = [];
        jugadorSeleccionado = null;
      });
    }
  }

  Future<void> crearEstadistica() async {
    if (!validarFormulario()) return;

    final confirm = await mostrarConfirmacion(
      '¿Guardar Estadística?',
      'Goles: ${golesController.text}\nAsistencias: ${asistenciasController.text}\nMinutos Jugados: ${minutosJugadosController.text}',
      'Sí, guardar',
      Colors.green,
    );

    if (!confirm) return;

    setState(() => loading = true);

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

      if (exito) {
        await mostrarAlerta('Estadística guardada', 'Los datos se registraron correctamente.', Colors.green);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        throw Exception('Error al guardar');
      }
    } catch (e) {
      String errorMsg = 'No se pudo guardar la estadística';
      mostrarAlerta('Error', errorMsg, Colors.red);
    } finally {
      setState(() => loading = false);
    }
  }

  bool validarFormulario() {
    if (categoriaSeleccionada == null || categoriaSeleccionada!.isEmpty) {
      mostrarAlerta('Categoría requerida', 'Debes seleccionar una categoría', Colors.orange);
      return false;
    }

    if (jugadorSeleccionado == null || jugadorSeleccionado!.isEmpty) {
      mostrarAlerta('Jugador requerido', 'Debes seleccionar un jugador', Colors.orange);
      return false;
    }

    if (partidoSeleccionado == null || partidoSeleccionado!.isEmpty) {
      mostrarAlerta('Partido requerido', 'Debes seleccionar un partido', Colors.orange);
      return false;
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
        mostrarAlerta('Campo vacío', 'El campo "$label" es obligatorio', Colors.orange);
        return false;
      }

      final numero = int.tryParse(valor);
      if (numero == null || numero < 0) {
        mostrarAlerta('Valor inválido', 'El campo "$label" debe ser un número positivo', Colors.red);
        return false;
      }
    }

    final minutos = int.tryParse(minutosJugadosController.text);
    if (minutos != null && minutos > 120) {
      mostrarAlerta('Minutos inválidos', 'Los minutos jugados no pueden ser mayores a 120', Colors.red);
      return false;
    }

    return true;
  }

  Future<void> mostrarAlerta(String title, String content, Color color) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: color)),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar', style: TextStyle(color: Color(0xffe63946))),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<bool> mostrarConfirmacion(String title, String content, String confirmText, Color confirmColor) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(confirmText, style: TextStyle(color: confirmColor, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Widget buildTextField(String label, TextEditingController controller, {bool required = false, int? max}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          labelStyle: const TextStyle(color: Color(0xffe63946)),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Campo obligatorio';
          }
          if (value != null && value.isNotEmpty) {
            final numero = int.tryParse(value);
            if (numero == null || numero < 0) {
              return 'Debe ser un número positivo';
            }
            if (max != null && numero > max) {
              return 'No puede ser mayor a $max';
            }
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SCORD', style: TextStyle(color: Color(0xffe63946), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xffe63946)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Text(
                'Agregar Registro Estadístico',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xffe63946)),
              ),
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seleccionar Jugador y Partido',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xffe63946)),
                    ),
                    const SizedBox(height: 16),
                    
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Categoría *',
                        labelStyle: TextStyle(color: Color(0xffe63946)),
                        border: OutlineInputBorder(),
                      ),
                      value: categoriaSeleccionada,
                      items: [
                        const DropdownMenuItem(value: null, child: Text("Seleccionar categoría")),
                        ...categorias.map((cat) => DropdownMenuItem(
                          value: cat.idCategorias.toString(),
                          child: Text(cat.descripcion),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => categoriaSeleccionada = value);
                        filtrarJugadores(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Jugador *',
                        labelStyle: TextStyle(color: Color(0xffe63946)),
                        border: OutlineInputBorder(),
                      ),
                      value: jugadorSeleccionado,
                      items: [
                        const DropdownMenuItem(value: null, child: Text("Seleccionar jugador")),
                        ...jugadoresFiltrados.map((jug) {
                          final nombre = '${jug.persona.nombre1} ${jug.persona.apellido1}';
                          return DropdownMenuItem(
                            value: jug.idJugadores.toString(),
                            child: Text(nombre),
                          );
                        }),
                      ],
                      onChanged: categoriaSeleccionada == null ? null : (value) {
                        setState(() => jugadorSeleccionado = value);
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Partido *',
                        labelStyle: TextStyle(color: Color(0xffe63946)),
                        border: OutlineInputBorder(),
                      ),
                      value: partidoSeleccionado,
                      items: [
                        const DropdownMenuItem(value: null, child: Text("Seleccionar partido")),
                        ...partidos.map((partido) => DropdownMenuItem(
                          value: partido.idPartidos.toString(),
                          child: Text(partido.rival ?? 'Partido #${partido.idPartidos}'),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => partidoSeleccionado = value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      buildTextField('⚽ Goles', golesController, required: true),
                      buildTextField('🎯 Asistencias', asistenciasController, required: true),
                      buildTextField('⏱ Minutos Jugados', minutosJugadosController, required: true, max: 120),
                      buildTextField('⚽ Goles de Cabeza', golesDeCabezaController),
                      buildTextField('🎯 Tiros a puerta', tirosApuertaController),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      buildTextField('🚩 Fueras de Juego', fuerasDeLugarController),
                      buildTextField('🟨 Tarjetas Amarillas', tarjetasAmarillasController),
                      buildTextField('🟥 Tarjetas Rojas', tarjetasRojasController),
                      buildTextField('🧤 Arco en cero', arcoEnCeroController),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: loading ? null : crearEstadistica,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: Text(
                    loading ? 'Guardando...' : 'Guardar',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: loading ? null : () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffe63946),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: const Text(
          '© 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos reservados',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
