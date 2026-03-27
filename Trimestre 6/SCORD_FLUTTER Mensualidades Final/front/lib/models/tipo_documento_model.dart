class TipoDocumento {
  final int idTiposDeDocumentos;
  final String descripcion;

  TipoDocumento({
    required this.idTiposDeDocumentos,
    required this.descripcion,
  });

  factory TipoDocumento.fromJson(Map<String, dynamic> json) {
    return TipoDocumento(
      idTiposDeDocumentos: json['idTiposDeDocumentos'] as int,
      descripcion: json['Descripcion'] as String,
    );
  }
}