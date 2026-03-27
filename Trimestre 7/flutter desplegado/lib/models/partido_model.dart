class Partido {
  final int idPartidos;
  final String? rival; // Mantener por compatibilidad
  final String formacion;
  final String equipoRival;
  final int idCronogramas;

  Partido({
    required this.idPartidos,
    this.rival,
    required this.formacion,
    required this.equipoRival,
    required this.idCronogramas,
  });

  factory Partido.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is double) return value.toInt();
      return defaultValue;
    }

    return Partido(
      idPartidos: toInt(json['idPartidos'], 0),
      rival: json['Rival']?.toString(),
      formacion: json['Formacion']?.toString() ?? '',
      equipoRival: json['EquipoRival']?.toString() ?? json['Rival']?.toString() ?? '',
      idCronogramas: toInt(json['idCronogramas'], 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPartidos': idPartidos,
      'Rival': rival ?? equipoRival,
      'Formacion': formacion,
      'EquipoRival': equipoRival,
      'idCronogramas': idCronogramas,
    };
  }
}