import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'agregarrendimiento.dart';

// Base URL de tu API
const String baseUrl = "http://127.0.0.1:8000/api";

// -------------------------------------------------------------------
// 1. MODELOS DE DATOS SIMPLIFICADOS
// -------------------------------------------------------------------

class Categoria {
  final int idCategorias;
  final String descripcion;

  Categoria({required this.idCategorias, required this.descripcion});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is double) return value.toInt();
      return defaultValue;
    }

    return Categoria(
      idCategorias: toInt(json['idCategorias'], 0),
      descripcion: json['Descripcion']?.toString() ?? '',
    );
  }
}

class Persona {
  final String nombre1;
  final String? nombre2;
  final String apellido1;
  final String? apellido2;
  final String? fechaDeNacimiento;
  final String? numeroDeDocumento;
  final String? telefono;

  Persona({
    required this.nombre1,
    this.nombre2,
    required this.apellido1,
    this.apellido2,
    this.fechaDeNacimiento,
    this.numeroDeDocumento,
    this.telefono,
  });

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      nombre1: json['Nombre1']?.toString() ?? '',
      nombre2: json['Nombre2']?.toString(),
      apellido1: json['Apellido1']?.toString() ?? '',
      apellido2: json['Apellido2']?.toString(),
      fechaDeNacimiento: json['FechaDeNacimiento']?.toString(),
      numeroDeDocumento: json['NumeroDeDocumento']?.toString(),
      telefono: json['Telefono']?.toString(),
    );
  }
}

class Jugador {
  final int idJugadores;
  final int? dorsal;
  final String? posicion;
  final Persona persona;
  final Categoria categoria;

  Jugador({
    required this.idJugadores,
    this.dorsal,
    this.posicion,
    required this.persona,
    required this.categoria,
  });

  factory Jugador.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is double) return value.toInt();
      return defaultValue;
    }

    int? toIntNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is double) return value.toInt();
      return null;
    }

    return Jugador(
      idJugadores: toInt(json['idJugadores'], 0),
      dorsal: toIntNullable(json['Dorsal']), 
      posicion: json['Posicion']?.toString(),
      persona: Persona.fromJson(json['persona'] ?? {}),
      categoria: Categoria.fromJson(json['categoria'] ?? {}),
    );
  }
}

class EstadisticasTotales {
  final Map<String, dynamic> totales;
  final Map<String, dynamic> promedios;

  EstadisticasTotales({required this.totales, required this.promedios});

  factory EstadisticasTotales.fromJson(Map<String, dynamic> json) {
    return EstadisticasTotales(
      totales: json['totales'] is Map ? Map<String, dynamic>.from(json['totales']) : {},
      promedios: json['promedios'] is Map ? Map<String, dynamic>.from(json['promedios']) : {},
    );
  }
}

class UltimoRegistro {
  final int idRendimientos;
  final int idPartidos;
  final int goles;
  final int golesDeCabeza;
  final int minutosJugados;
  final int asistencias;
  final int tirosApuerta;
  final int tarjetasRojas;
  final int tarjetasAmarillas;
  final int fuerasDeLugar;
  final int arcoEnCero;

  UltimoRegistro({
    required this.idRendimientos,
    required this.idPartidos,
    required this.goles,
    required this.golesDeCabeza,
    required this.minutosJugados,
    required this.asistencias,
    required this.tirosApuerta,
    required this.tarjetasRojas,
    required this.tarjetasAmarillas,
    required this.fuerasDeLugar,
    required this.arcoEnCero,
  });

  factory UltimoRegistro.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is double) return value.toInt();
      return defaultValue;
    }

    return UltimoRegistro(
      idRendimientos: toInt(json['IdRendimientos'], 0),
      idPartidos: toInt(json['idPartidos'], 0),
      goles: toInt(json['Goles'], 0),
      golesDeCabeza: toInt(json['GolesDeCabeza'], 0),
      minutosJugados: toInt(json['MinutosJugados'], 0),
      asistencias: toInt(json['Asistencias'], 0),
      tirosApuerta: toInt(json['TirosApuerta'], 0),
      tarjetasRojas: toInt(json['TarjetasRojas'], 0),
      tarjetasAmarillas: toInt(json['TarjetasAmarillas'], 0),
      fuerasDeLugar: toInt(json['FuerasDeLugar'], 0),
      arcoEnCero: toInt(json['ArcoEnCero'], 0),
    );
  }

  Map<String, dynamic> toUpdateJson(int idJugadores) {
    return {
      'Goles': goles,
      'GolesDeCabeza': golesDeCabeza,
      'MinutosJugados': minutosJugados,
      'Asistencias': asistencias,
      'TirosApuerta': tirosApuerta,
      'TarjetasRojas': tarjetasRojas,
      'TarjetasAmarillas': tarjetasAmarillas,
      'FuerasDeLugar': fuerasDeLugar,
      'ArcoEnCero': arcoEnCero,
      'idPartidos': idPartidos,
      'idJugadores': idJugadores,
    };
  }
}

// -------------------------------------------------------------------
// 2. WIDGET PRINCIPAL
// -------------------------------------------------------------------

class EstadisticasJugadorBasico extends StatefulWidget {
  const EstadisticasJugadorBasico({super.key});

  @override
  State<EstadisticasJugadorBasico> createState() => _EstadisticasJugadorBasicoState();
}

class _EstadisticasJugadorBasicoState extends State<EstadisticasJugadorBasico> {
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

  @override
  void initState() {
    super.initState();
    cargarDatosIniciales();
  }

  // -------------------------------------------------------------------
  // 3. LÓGICA Y API
  // -------------------------------------------------------------------

  Future<void> cargarDatosIniciales() async {
    await fetchCategorias();
    await fetchJugadores();
  }

  void filtrarJugadores(String? categoriaId) {
    if (categoriaId != null) {
      final id = int.tryParse(categoriaId);
      final filtrados = jugadores.where((j) => j.categoria.idCategorias == id).toList();

      setState(() {
        jugadoresFiltrados = filtrados;
        jugadorSeleccionado = null;
        estadisticasTotales = null;
        modoEdicion = false;
      });
    } else {
      setState(() {
        jugadoresFiltrados = [];
        jugadorSeleccionado = null;
        estadisticasTotales = null;
        modoEdicion = false;
      });
    }
  }

  Future<void> fetchJugadores() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/jugadores'));
      
      if (res.statusCode == 200) {
        final jsonResponse = json.decode(res.body);
        
        // Maneja diferentes estructuras de respuesta
        List<dynamic> data;
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          data = jsonResponse['data'] as List;
        } else if (jsonResponse is List) {
          data = jsonResponse;
        } else {
          throw Exception('Formato de respuesta inesperado');
        }
        
        // Parsea cada jugador con manejo de errores individual
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
        
        setState(() {
          jugadores = jugadoresParsed;
        });
        
        if (categoriaSeleccionadaId != null) {
          filtrarJugadores(categoriaSeleccionadaId);
        }
      } else {
        mostrarAlerta(context, 'Error', 'No se pudieron cargar los jugadores: ${res.statusCode}', Colors.red);
      }
    } catch (e) {
      mostrarAlerta(context, 'Error', 'No se pudieron cargar los jugadores: $e', Colors.red);
    }
  }

  Future<void> fetchCategorias() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/categorias'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          categorias = (data as List).map((i) => Categoria.fromJson(i)).toList();
        });
      }
    } catch (e) {
      // Manejo de error silencioso
    }
  }

  Future<void> fetchEstadisticasTotales(int idJugador) async {
    setState(() => loading = true);
    try {
      final res = await http.get(Uri.parse('$baseUrl/rendimientospartidos/jugador/$idJugador/totales'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body)['data'];
        if (data != null) {
          setState(() {
            estadisticasTotales = EstadisticasTotales.fromJson(data);
          });
        }
      } else {
        mostrarAlerta(context, 'Error', 'No se pudieron cargar las estadísticas: ${res.statusCode}', Colors.red);
      }
    } catch (e) {
      mostrarAlerta(context, 'Error', 'No se pudieron cargar las estadísticas', Colors.red);
    } finally {
      setState(() => loading = false);
    }
  }

  void activarEdicion() {
    if (jugadorSeleccionado == null) {
      mostrarAlerta(context, 'No hay jugador seleccionado', 'Por favor selecciona un jugador primero', Colors.orange);
      return;
    }
    cargarUltimoRegistroParaEditar();
  }

  Future<void> cargarUltimoRegistroParaEditar() async {
    try {
      final idJugador = jugadorSeleccionado!.idJugadores;
      final res = await http.get(Uri.parse('$baseUrl/rendimientospartidos/jugador/$idJugador/ultimo-registro'));
      final data = json.decode(res.body);

      if (data['success'] == true && data['data'] != null) {
        final registro = UltimoRegistro.fromJson(data['data']);
        setState(() {
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
        });
      } else {
        mostrarAlerta(context, 'Sin registros', data['message'] ?? 'No hay estadísticas registradas para este jugador', Colors.orange);
      }
    } catch (e) {
      String errorMsg = 'No se pudieron cargar los datos para editar';
      if (e is http.Response && e.statusCode == 404) {
        errorMsg = 'No se encontraron registros para este jugador';
      }
      mostrarAlerta(context, 'Error', errorMsg, Colors.red);
    }
  }

  Future<void> guardarCambios() async {
    if (!validarFormulario()) return;

    final confirm = await mostrarConfirmacion(
      context,
      '¿Estás Seguro?',
      'Goles: ${formData['goles']}\nAsistencias: ${formData['asistencias']}\nMinutos Jugados: ${formData['minutosJugados']}',
      'Sí, actualizar',
      Colors.green,
    );

    if (!confirm) return;

    setState(() => loading = true);

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

      final updateRes = await http.put(
        Uri.parse('$baseUrl/rendimientospartidos/${ultimoRegistro!.idRendimientos}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dataToUpdate),
      );

      if (updateRes.statusCode == 200) {
        await fetchEstadisticasTotales(jugadorSeleccionado!.idJugadores);
        cancelarEdicion();
        mostrarAlerta(context, 'Estadísticas actualizadas', 'Los datos se actualizaron correctamente.', Colors.green);
      } else {
        throw Exception('Error en el servidor: ${updateRes.body}');
      }
    } catch (e) {
      String errorMsg = 'No se pudo actualizar las estadísticas';
      mostrarAlerta(context, 'Error', e.toString().contains('Exception') ? e.toString().split(':').last.trim() : errorMsg, Colors.red);
    } finally {
      setState(() => loading = false);
    }
  }

  bool validarFormulario() {
    final camposNumericos = [
      {'key': 'goles', 'label': 'Goles'},
      {'key': 'golesDeCabeza', 'label': 'Goles de Cabeza'},
      {'key': 'minutosJugados', 'label': 'Minutos Jugados'},
      {'key': 'asistencias', 'label': 'Asistencias'},
      {'key': 'tirosApuerta', 'label': 'Tiros a Puerta'},
      {'key': 'tarjetasRojas', 'label': 'Tarjetas Rojas'},
      {'key': 'tarjetasAmarillas', 'label': 'Tarjetas Amarillas'},
      {'key': 'arcoEnCero', 'label': 'Arco en Cero'},
    ];

    for (final campo in camposNumericos) {
      final valor = formData[campo['key']];
      if (valor != null && valor.isNotEmpty) {
        final parsedValue = int.tryParse(valor);
        if (parsedValue == null || parsedValue < 0) {
          mostrarAlerta(context, 'Valor inválido', 'El campo "${campo['label']}" debe ser un número positivo.', Colors.orange);
          return false;
        }
      }
    }

    if (formData['minutosJugados'] != null && formData['minutosJugados']!.isNotEmpty) {
      final minutos = int.tryParse(formData['minutosJugados']!);
      if (minutos != null && minutos > 120) {
        mostrarAlerta(context, 'Minutos inválidos', 'Los minutos jugados no pueden ser mayores a 120 por partido.', Colors.red);
        return false;
      }
    }
    return true;
  }

  void cancelarEdicion() {
    setState(() {
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
    });
  }

  Future<void> eliminarEstadistica() async {
    if (jugadorSeleccionado == null) {
      mostrarAlerta(context, 'No hay jugador seleccionado', 'Por favor selecciona un jugador primero', Colors.orange);
      return;
    }

    final confirm = await mostrarConfirmacion(
      context,
      '¿Estás seguro?',
      'Se eliminará el último registro de estadísticas',
      'Sí, eliminar',
      Colors.red,
    );

    if (!confirm) return;

    setState(() => loading = true);

    try {
      final idJugador = jugadorSeleccionado!.idJugadores;
      final res = await http.get(Uri.parse('$baseUrl/rendimientospartidos/jugador/$idJugador/ultimo-registro'));
      final data = json.decode(res.body);

      if (data['success'] == true && data['data'] != null) {
        final registro = UltimoRegistro.fromJson(data['data']);

        final deleteRes = await http.delete(Uri.parse('$baseUrl/rendimientospartidos/${registro.idRendimientos}'));

        if (deleteRes.statusCode == 200) {
          mostrarAlerta(context, '¡Estadística eliminada!', 'El último registro se eliminó correctamente', Colors.green);
          await fetchEstadisticasTotales(idJugador);
          cancelarEdicion();
        } else {
          throw Exception('Error al eliminar: ${deleteRes.body}');
        }
      } else {
        mostrarAlerta(context, 'Sin registros', 'No hay estadísticas para eliminar para este jugador', Colors.orange);
      }
    } catch (e) {
      mostrarAlerta(context, 'Error', 'No se pudo eliminar la estadística', Colors.red);
    } finally {
      setState(() => loading = false);
    }
  }

  String calcularEdad(String? fechaNacimiento) {
    if (fechaNacimiento == null || fechaNacimiento.isEmpty) return "-";
    try {
      final nacimiento = DateTime.parse(fechaNacimiento);
      final hoy = DateTime.now();
      int edad = hoy.year - nacimiento.year;
      final mes = hoy.month - nacimiento.month;
      if (mes < 0 || (mes == 0 && hoy.day < nacimiento.day)) {
        edad--;
      }
      return edad.toString();
    } catch (e) {
      return "-";
    }
  }

  // -------------------------------------------------------------------
  // 4. WIDGETS AUXILIARES
  // -------------------------------------------------------------------

  Future<void> mostrarAlerta(BuildContext context, String title, String content, Color color) async {
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

  Future<bool> mostrarConfirmacion(
    BuildContext context, 
    String title, 
    String content,
    String confirmText, 
    Color confirmColor
  ) async {
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

  Widget buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$title:', style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget buildEstadisticaItem(String label, String statKey, {bool isEditable = false, String? statAverageKey}) {
    final fieldName = statKey.split('_').last; 

    if (isEditable && modoEdicion) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffe63946))),
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.all(8)),
                controller: TextEditingController(text: formData[fieldName])
                  ..selection = TextSelection.collapsed(offset: formData[fieldName]?.length ?? 0),
                onChanged: (value) => setState(() => formData[fieldName] = value),
              ),
            ),
          ],
        ),
      );
    }

    String displayValue = '0';
    if (estadisticasTotales != null) {
      if (statAverageKey != null) {
        final val = estadisticasTotales!.promedios[statAverageKey];
        displayValue = val != null ? val.toStringAsFixed(2) : '0';
      } else {
        displayValue = estadisticasTotales!.totales[statKey]?.toString() ?? '0';
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: statAverageKey == null ? FontWeight.w600 : FontWeight.normal, color: Color(0xffe63946))),
          Text(displayValue),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // 5. RENDERIZADO PRINCIPAL
  // -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final persona = jugadorSeleccionado?.persona;
    final categoriaJugador = jugadorSeleccionado?.categoria;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SCORD - Estadísticas de Jugador', style: TextStyle(color: Color(0xffe63946), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
     body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AgregarRendimiento()),
                    );
                  }, 
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Agregar Estadísticas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                const SizedBox(width: 8),

                if (!modoEdicion) ...[
                  ElevatedButton.icon(
                    onPressed: activarEdicion,
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('Editar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: eliminarEstadistica,
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Eliminar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: loading ? null : guardarCambios,
                    icon: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save, color: Colors.white),
                    label: Text(loading ? "Guardando..." : "Guardar Cambios", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: loading ? null : cancelarEdicion,
                    icon: const Icon(Icons.cancel, color: Colors.white),
                    label: const Text('Cancelar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                  ),
                ]
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(labelText: 'Seleccionar Categoría', border: OutlineInputBorder(), labelStyle: TextStyle(color: Color(0xffe63946))),
                                value: categoriaSeleccionadaId,
                                items: [
                                  const DropdownMenuItem(value: null, child: Text("-- Selecciona una categoría --")),
                                  ...categorias.map((cat) => DropdownMenuItem(value: cat.idCategorias.toString(), child: Text(cat.descripcion))),
                                ],
                                onChanged: modoEdicion ? null : (String? newValue) {
                                  setState(() {
                                    categoriaSeleccionadaId = newValue;
                                    jugadorSeleccionado = null;
                                  });
                                  filtrarJugadores(newValue);
                                  },
                          ),
                          const SizedBox(height: 15),
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(labelText: 'Seleccionar Jugador', border: OutlineInputBorder(), labelStyle: TextStyle(color: Color(0xffe63946))),
                            value: jugadorSeleccionado?.idJugadores,
                            items: [
                              const DropdownMenuItem(value: null, child: Text("-- Selecciona un jugador --")),
                              ...jugadoresFiltrados.map((jugador) => DropdownMenuItem(
                                value: jugador.idJugadores,
                                child: Text("${jugador.persona.nombre1} ${jugador.persona.apellido1}"),
                              )),
                            ],
                            onChanged: (int? newValue) {
                              if (newValue != null && !modoEdicion) {
                                final jugador = jugadores.firstWhere((j) => j.idJugadores == newValue);
                                setState(() => jugadorSeleccionado = jugador);
                                fetchEstadisticasTotales(newValue);
                              } else if (newValue == null && !modoEdicion) {
                                setState(() {
                                  jugadorSeleccionado = null;
                                  estadisticasTotales = null;
                                });
                              }
                            },
                            disabledHint: const Text("Selecciona un jugador"),
                          ),
                          const SizedBox(height: 20),
                          const Center(child: Icon(Icons.person, size: 100, color: Colors.grey)),
                          const SizedBox(height: 15),

                          const Center(child: Text('Información Personal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffe63946)))),
                          const SizedBox(height: 8),
                          buildInfoItem(
                            'Nombre',
                            persona != null
                                ? "${persona.nombre1} ${persona.nombre2 ?? ''} ${persona.apellido1} ${persona.apellido2 ?? ''}".trim()
                                : "-",
                          ),
                          buildInfoItem('Edad', calcularEdad(persona?.fechaDeNacimiento)),
                          buildInfoItem('Documento', persona?.numeroDeDocumento ?? "-"),
                          buildInfoItem('Contacto', persona?.telefono ?? "-"),

                          const Divider(height: 30),

                          const Center(child: Text('Información Deportiva', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffe63946)))),
                          const SizedBox(height: 8),
                          buildInfoItem('Categoría', categoriaJugador?.descripcion ?? "-"),
                          buildInfoItem('Dorsal', jugadorSeleccionado?.dorsal?.toString() ?? "-"),
                          buildInfoItem('Posición', jugadorSeleccionado?.posicion ?? "-"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(child: Text('Estadísticas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xffe63946)))),
                          const Divider(height: 20),
                          if (loading)
                            const Center(child: CircularProgressIndicator(color: Color(0xffe63946)))
                          else if (estadisticasTotales != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(child: Text(modoEdicion ? "Editar Último Partido" : "Estadísticas Básicas", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                const SizedBox(height: 10),

                                buildEstadisticaItem('⚽ Goles', 'total_goles', isEditable: true),
                                buildEstadisticaItem('🎯 Asistencias', 'total_asistencias', isEditable: true),
                                buildEstadisticaItem('📋 Partidos', 'total_partidos_jugados'),
                                buildEstadisticaItem('⏱️ Minutos', 'total_minutos_jugados', isEditable: true),

                                const Divider(height: 20),

                                const Center(child: Text("Estadísticas Detalladas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                                const SizedBox(height: 10),

                                buildEstadisticaItem('⚽ Goles de Cabeza', 'total_goles_cabeza', isEditable: true),
                                buildEstadisticaItem('📊 Goles por Partido', 'total_goles', statAverageKey: 'goles_por_partido'),
                                buildEstadisticaItem('🎯 Tiros a puerta', 'total_tiros_apuerta', isEditable: true),
                                buildEstadisticaItem('🚩 Fueras de Juego', 'total_fueras_de_lugar', isEditable: true),
                                buildEstadisticaItem('🟨 Tarjetas Amarillas', 'total_tarjetas_amarillas', isEditable: true),
                                buildEstadisticaItem('🟥 Tarjetas Rojas', 'total_tarjetas_rojas', isEditable: true),
                                buildEstadisticaItem('🧤 Arco en cero', 'total_arco_en_cero', isEditable: true),

                              ],
                            )
                          else
                            const Center(child: Text('Selecciona un jugador para ver sus estadísticas', style: TextStyle(color: Colors.grey))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ),
  bottomNavigationBar: Container(
    color: Colors.black87,
    padding: const EdgeInsets.all(16.0),
    child: const Text(
      '© 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos reservados',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white70, fontSize: 12),
    ),
  ),
);
  }
}