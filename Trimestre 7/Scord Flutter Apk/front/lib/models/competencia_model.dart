class Competencia {
  final int idCompetencias;
  final String nombre;
  final String tipoCompetencia;
  final int ano;

  Competencia({
    required this.idCompetencias,
    required this.nombre,
    required this.tipoCompetencia,
    required this.ano,
    
  });

  factory Competencia.fromJson(Map<String, dynamic> json) {
    return Competencia(
      idCompetencias: json['idCompetencias'],
      nombre: json['Nombre'],
      tipoCompetencia: json['TipoCompetencia'],
      ano: json['Ano'],
    );
  }

  get descripcion => null;

  Map<String, dynamic> toJson() {
    return {
      'Nombre': nombre,
      'TipoCompetencia': tipoCompetencia,
      'Ano': ano,
    };
  }

  Competencia copyWith({
    int? idCompetencias,
    String? nombre,
    String? tipoCompetencia,
    int? ano,
  }) {
    return Competencia(
      idCompetencias: idCompetencias ?? this.idCompetencias,
      nombre: nombre ?? this.nombre,
      tipoCompetencia: tipoCompetencia ?? this.tipoCompetencia,
      ano: ano ?? this.ano,
    );
  }
}