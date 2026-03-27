import 'package:flutter/material.dart';
import '../../../models/pdf_report_config.dart';

class SeleccionarTipoReporteDialog extends StatelessWidget {
  final List<Map<String, dynamic>> competencias;
  final Function(PdfReportConfig) onSeleccionar;

  const SeleccionarTipoReporteDialog({
    Key? key,
    required this.competencias,
    required this.onSeleccionar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.picture_as_pdf, color: Color(0xffe63946), size: 28),
                const SizedBox(width: 12),
                Text(
                  'Tipo de Reporte',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Opción: Estadísticas Generales
            _OpcionReporte(
              icono: Icons.analytics,
              titulo: 'Estadísticas Generales',
              descripcion: 'Todas las competencias',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                onSeleccionar(PdfReportConfig(
                  tipo: TipoReportePdf.general,
                ));
              },
            ),
            
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            
            // Opción: Por Competencia
            _OpcionReporte(
              icono: Icons.emoji_events,
              titulo: 'Por Competencia',
              descripcion: 'Seleccionar competencia específica',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                _mostrarSelectorCompetencia(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarSelectorCompetencia(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SelectorCompetenciaDialog(
        competencias: competencias,
        onSeleccionar: (competencia) {
          onSeleccionar(PdfReportConfig(
            tipo: TipoReportePdf.porCompetencia,
            idCompetencia: competencia['idCompetencias'],
            nombreCompetencia: competencia['Nombre'],
          ));
        },
      ),
    );
  }
}

class _OpcionReporte extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String descripcion;
  final Color color;
  final VoidCallback onTap;

  const _OpcionReporte({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icono, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descripcion,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _SelectorCompetenciaDialog extends StatelessWidget {
  final List<Map<String, dynamic>> competencias;
  final Function(Map<String, dynamic>) onSeleccionar;

  const _SelectorCompetenciaDialog({
    required this.competencias,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seleccionar Competencia',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (competencias.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No hay competencias disponibles',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: competencias.map((comp) {
                      return ListTile(
                        leading: Icon(Icons.emoji_events, color: Colors.orange),
                        title: Text(comp['Nombre'] ?? 'Sin nombre'),
                        subtitle: comp['Descripcion'] != null 
                            ? Text(comp['Descripcion']) 
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          onSeleccionar(comp);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}