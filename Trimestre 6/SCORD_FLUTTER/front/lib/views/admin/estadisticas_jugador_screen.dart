import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/categoria_model.dart';
import '../../models/jugador_model.dart';
import '../../models/rendimiento_model.dart';
import '../../services/rendimiento_service.dart';
import '../../services/api_service.dart';
import '../../utils/validator.dart';
import 'agregar_rendimiento_screen.dart';

class EstadisticasJugadorScreen extends StatefulWidget {
  const EstadisticasJugadorScreen({super.key});

  @override
  State<EstadisticasJugadorScreen> createState() => _EstadisticasJugadorScreenState();
}

class _EstadisticasJugadorScreenState extends State<EstadisticasJugadorScreen> {
  final RendimientoService _rendimientoService = RendimientoService();
  final ApiService _apiService = ApiService();
  
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

  Future<void> cargarDatosIniciales() async {
    await fetchCategorias();
    await fetchJugadores();
  }

  void filtrarJugadores(String? categoriaId) {
    if (categoriaId != null) {
      final id = int.tryParse(categoriaId);
      final filtrados = jugadores.where((j) => j.categoria?.idCategorias == id).toList();

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
      final res = await _apiService.get('/categorias');
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          categorias = (data as List).map((i) => Categoria.fromJson(i)).toList();
        });
      }
    } catch (e) {
      print('Error cargando categorías: $e');
    }
  }

  Future<void> fetchEstadisticasTotales(int idJugador) async {
    setState(() => loading = true);
    try {
      final estadisticas = await _rendimientoService.obtenerEstadisticasTotales(idJugador);
      if (estadisticas != null) {
        setState(() {
          estadisticasTotales = estadisticas;
        });
      } else {
        mostrarAlerta(context, 'Error', 'No se pudieron cargar las estadísticas', Colors.red);
      }
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
      final registro = await _rendimientoService.obtenerUltimoRegistro(idJugador);

      if (registro != null) {
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
        mostrarAlerta(context, 'Sin registros', 'No hay estadísticas registradas para este jugador', Colors.orange);
      }
    } catch (e) {
      String errorMsg = 'No se pudieron cargar los datos para editar';
      mostrarAlerta(context, 'Error', errorMsg, Colors.red);
    }
  }

  Future<void> guardarCambios() async {
    if (!Validator.validarEstadisticas(formData, context)) return;

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

      final exito = await _rendimientoService.actualizarRendimiento(
        ultimoRegistro!.idRendimientos, 
        dataToUpdate
      );

      if (exito) {
        await fetchEstadisticasTotales(jugadorSeleccionado!.idJugadores);
        cancelarEdicion();
        mostrarAlerta(context, 'Estadísticas actualizadas', 'Los datos se actualizaron correctamente.', Colors.green);
      } else {
        throw Exception('Error al actualizar');
      }
    } catch (e) {
      String errorMsg = 'No se pudo actualizar las estadísticas';
      mostrarAlerta(context, 'Error', e.toString().contains('Exception') ? e.toString().split(':').last.trim() : errorMsg, Colors.red);
    } finally {
      setState(() => loading = false);
    }
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
      final registro = await _rendimientoService.obtenerUltimoRegistro(idJugador);

      if (registro != null) {
        final exito = await _rendimientoService.eliminarRendimiento(registro.idRendimientos);

        if (exito) {
          mostrarAlerta(context, '¡Estadística eliminada!', 'El último registro se eliminó correctamente', Colors.green);
          await fetchEstadisticasTotales(idJugador);
          cancelarEdicion();
        } else {
          throw Exception('Error al eliminar');
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

  String calcularEdad(DateTime? fechaNacimiento) { 
    if (fechaNacimiento == null) {
        return "-";
    }
    
    final hoy = DateTime.now();
    int edad = hoy.year - fechaNacimiento.year;
    final mes = hoy.month - fechaNacimiento.month;
    
    if (mes < 0 || (mes == 0 && hoy.day < fechaNacimiento.day)) {
        edad--;
    }
    
    return edad.toString();
  }

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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$title:', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget buildEstadisticaItem(String label, String statKey, {bool isEditable = false, String? statAverageKey}) {
    final fieldName = statKey.split('_').last; 

    if (isEditable && modoEdicion) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xffe63946), fontSize: 13)),
            ),
            SizedBox(
              width: 70,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(), 
                  isDense: true, 
                  contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6)
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label, 
              style: TextStyle(
                fontWeight: statAverageKey == null ? FontWeight.w600 : FontWeight.normal, 
                color: const Color(0xffe63946),
                fontSize: 13
              )
            ),
          ),
          Text(displayValue, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, String routeName) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.of(context).pop();
        
        if (routeName == '/Logout') {
          // Lógica de deslogueo
        } else if (ModalRoute.of(context)?.settings.name != routeName) {
           Navigator.of(context).pushNamed(routeName); 
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final persona = jugadorSeleccionado?.persona;
    final categoriaJugador = jugadorSeleccionado?.categoria;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SCORD - Estadísticas',
          style: TextStyle(
            color: Color(0xffe63946),
            fontWeight: FontWeight.bold,
            fontSize: 18
          )
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xffe63946)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.red),
              child: Text(
                'Menú de Navegación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            _buildDrawerItem(context, 'Inicio', Icons.home, '/InicioAdmin'),
            _buildDrawerItem(context, 'Cronograma', Icons.calendar_month, '/Cronograma'),
            _buildDrawerItem(context, 'Perfil Jugador', Icons.person_pin, '/PerfilJugadorAdmin'),
            _buildDrawerItem(context, 'Estadísticas Jugadores', Icons.bar_chart, '/EstadisticasJugadores'),
            _buildDrawerItem(context, 'Perfil Entrenador', Icons.sports_gymnastics, '/PerfilEntrenador'),
            _buildDrawerItem(context, 'Evaluar Jugadores', Icons.rule, '/EvaluarJugadores'),
            const Divider(),
            _buildDrawerItem(context, 'Cerrar Sesión', Icons.logout, '/Logout'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Botones más compactos
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AgregarRendimientoScreen()),
                    );
                    if (jugadorSeleccionado != null) {
                      await fetchEstadisticasTotales(jugadorSeleccionado!.idJugadores);
                    }
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 16),
                  label: const Text(
                    'Agregar',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(0, 36),
                  ),
                ),

                if (!modoEdicion) ...[
                  ElevatedButton.icon(
                    onPressed: activarEdicion,
                    icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                    label: const Text(
                      'Editar',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: eliminarEstadistica,
                    icon: const Icon(Icons.delete, color: Colors.white, size: 16),
                    label: const Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: loading ? null : guardarCambios,
                    icon: loading 
                      ? const SizedBox(
                          width: 16, 
                          height: 16, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        ) 
                      : const Icon(Icons.save, color: Colors.white, size: 16),
                    label: Text(
                      loading ? "Guardando..." : "Guardar",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: loading ? null : cancelarEdicion,
                    icon: const Icon(Icons.cancel, color: Colors.white, size: 16),
                    label: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 36),
                    ),
                  ),
                ]
              ],
            ),
          ),
          
          // Contenido en Column vertical en lugar de Row horizontal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card de Información del Jugador
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Seleccionar Categoría',
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(color: Color(0xffe63946), fontSize: 13),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            style: const TextStyle(fontSize: 13, color: Colors.black),
                            value: categoriaSeleccionadaId,
                            items: [
                              const DropdownMenuItem(value: null, child: Text("-- Selecciona categoría --")),
                              ...categorias.map((cat) => DropdownMenuItem(
                                value: cat.idCategorias.toString(),
                                child: Text(cat.descripcion)
                              )),
                            ],
                            onChanged: modoEdicion ? null : (String? newValue) {
                              setState(() {
                                categoriaSeleccionadaId = newValue;
                                jugadorSeleccionado = null;
                              });
                              filtrarJugadores(newValue);
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Seleccionar Jugador',
                              border: OutlineInputBorder(),
                              labelStyle: TextStyle(color: Color(0xffe63946), fontSize: 13),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            style: const TextStyle(fontSize: 13, color: Colors.black),
                            value: jugadorSeleccionado?.idJugadores,
                            items: [
                              const DropdownMenuItem(value: null, child: Text("-- Selecciona jugador --")),
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
                          const SizedBox(height: 16),
                          const Center(child: Icon(Icons.person, size: 80, color: Colors.grey)),
                          const SizedBox(height: 12),

                          const Center(
                            child: Text(
                              'Información Personal',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xffe63946))
                            )
                          ),
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

                          const Divider(height: 24),

                          const Center(
                            child: Text(
                              'Información Deportiva',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xffe63946))
                            )
                          ),
                          const SizedBox(height: 8),
                          buildInfoItem('Categoría', categoriaJugador?.descripcion ?? "-"),
                          buildInfoItem('Dorsal', jugadorSeleccionado?.dorsal.toString() ?? "-"),
                          buildInfoItem('Posición', jugadorSeleccionado?.posicion ?? "-"),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Card de Estadísticas
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Center(
                            child: Text(
                              'Estadísticas',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xffe63946))
                            )
                          ),
                          const Divider(height: 16),
                          if (loading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(color: Color(0xffe63946))
                              )
                            )
                          else if (estadisticasTotales != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Center(
                                  child: Text(
                                    modoEdicion ? "Editar Último Partido" : "Estadísticas Básicas",
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                                  )
                                ),
                                const SizedBox(height: 10),

                                buildEstadisticaItem('⚽ Goles', 'total_goles', isEditable: true),
                                buildEstadisticaItem('🎯 Asistencias', 'total_asistencias', isEditable: true),
                                buildEstadisticaItem('📋 Partidos', 'total_partidos_jugados'),
                                buildEstadisticaItem('⏱️ Minutos', 'total_minutos_jugados', isEditable: true),

                                const Divider(height: 16),

                                const Center(
                                  child: Text(
                                    "Estadísticas Detalladas",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)
                                  )
                                ),
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
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'Selecciona un jugador para ver sus estadísticas',
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            ),
                        ],
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