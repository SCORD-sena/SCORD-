enum TipoReportePdf {
  general,
  porCompetencia,
}

class PdfReportConfig {
  final TipoReportePdf tipo;
  final int? idCompetencia;
  final String? nombreCompetencia;

  PdfReportConfig({
    required this.tipo,
    this.idCompetencia,
    this.nombreCompetencia,
  });

  bool get esReporteGeneral => tipo == TipoReportePdf.general;

  @override
  String toString() {
    return 'PdfReportConfig(tipo: $tipo, idCompetencia: $idCompetencia, nombreCompetencia: $nombreCompetencia)';
  }
}