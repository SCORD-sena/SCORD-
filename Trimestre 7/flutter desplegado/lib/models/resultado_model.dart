class Resultado {
  final int idResultados;
  final String marcador;
  final int puntosObtenidos;
  final String? observacion;
  final int idPartidos;

  Resultado({
    required this.idResultados,
    required this.marcador,
    required this.puntosObtenidos,
    this.observacion,
    required this.idPartidos,
  });

  factory Resultado.fromJson(Map<String, dynamic> json) {
    return Resultado(
      idResultados: json['idResultados'] ?? 0,
      marcador: json['Marcador'] ?? '',
      puntosObtenidos: json['PuntosObtenidos'] ?? 0,
      observacion: json['Observacion'],
      idPartidos: json['idPartidos'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Marcador': marcador,
      'PuntosObtenidos': puntosObtenidos,
      'Observacion': observacion,
      'idPartidos': idPartidos,
    };
  }

  Resultado copyWith({
    int? idResultados,
    String? marcador,
    int? puntosObtenidos,
    String? observacion,
    int? idPartidos,
  }) {
    return Resultado(
      idResultados: idResultados ?? this.idResultados,
      marcador: marcador ?? this.marcador,
      puntosObtenidos: puntosObtenidos ?? this.puntosObtenidos,
      observacion: observacion ?? this.observacion,
      idPartidos: idPartidos ?? this.idPartidos,
    );
  }
}