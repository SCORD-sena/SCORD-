import 'package:flutter/material.dart';
import '../../../models/competencia_model.dart';
import '../../../models/partido_model.dart';

class SeleccionarCompetenciaPartidoDialog extends StatefulWidget {
  final List<Competencia> competencias;
  final Future<List<Partido>> Function(int idCompetencia) onCompetenciaSeleccionada;

  const SeleccionarCompetenciaPartidoDialog({
    super.key,
    required this.competencias,
    required this.onCompetenciaSeleccionada,
  });

  @override
  State<SeleccionarCompetenciaPartidoDialog> createState() =>
      _SeleccionarCompetenciaPartidoDialogState();
}

class _SeleccionarCompetenciaPartidoDialogState
    extends State<SeleccionarCompetenciaPartidoDialog> {
  int? _competenciaSeleccionada;
  int? _partidoSeleccionado;
  List<Partido> _partidos = [];
  bool _loadingPartidos = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Seleccionar Partido a Editar',
        style: TextStyle(
          color: Color(0xffe63946),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🏆 DROPDOWN COMPETENCIAS
            if (widget.competencias.isEmpty)
              // Si no hay competencias, mostrar mensaje
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'No hay competencias disponibles',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            else
              // Si hay competencias, mostrar dropdown
              DropdownButtonFormField<int>(
                value: _competenciaSeleccionada,
                decoration: const InputDecoration(
                  labelText: 'Competencia',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.emoji_events, color: Color(0xffe63946)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                isExpanded: true,
                hint: const Text('Selecciona una competencia'),
                items: widget.competencias.map((comp) {
                  return DropdownMenuItem<int>(
                    value: comp.idCompetencias,
                    child: Text(
                      comp.nombre,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) async {
                  if (value == null) return;

                  setState(() {
                    _competenciaSeleccionada = value;
                    _partidoSeleccionado = null;
                    _loadingPartidos = true;
                    _partidos = [];
                    _errorMessage = null;
                  });

                  try {
                    final partidos = await widget.onCompetenciaSeleccionada(value);
                    setState(() {
                      _partidos = partidos;
                      _loadingPartidos = false;
                    });
                  } catch (e) {
                    setState(() {
                      _loadingPartidos = false;
                      _errorMessage = 'Error al cargar partidos';
                    });
                  }
                },
              ),

            const SizedBox(height: 16),

            // ⚽ DROPDOWN PARTIDOS
            if (_loadingPartidos)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xffe63946),
                      ),
                      SizedBox(height: 8),
                      Text('Cargando partidos...'),
                    ],
                  ),
                ),
              )
            else if (_competenciaSeleccionada != null)
              if (_partidos.isEmpty)
                // Si no hay partidos, mostrar mensaje
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'No hay partidos disponibles para esta competencia',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                // Si hay partidos, mostrar dropdown
                DropdownButtonFormField<int>(
                  value: _partidoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Partido',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.sports_soccer, color: Color(0xffe63946)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  isExpanded: true,
                  hint: const Text('Selecciona un partido'),
                  items: _partidos.map((partido) {
                    return DropdownMenuItem<int>(
                      value: partido.idPartidos,
                      child: Text(
                        'vs ${partido.equipoRival}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _partidoSeleccionado = value;
                    });
                  },
                ),

            // ⚠️ MENSAJE DE ERROR
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffe63946),
            foregroundColor: Colors.white,
            elevation: 2,
            disabledBackgroundColor: Colors.grey.shade300,
          ),
          onPressed: (_competenciaSeleccionada != null && _partidoSeleccionado != null)
              ? () {
                  Navigator.pop(context, {
                    'idCompetencia': _competenciaSeleccionada,
                    'idPartido': _partidoSeleccionado,
                  });
                }
              : null,
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}