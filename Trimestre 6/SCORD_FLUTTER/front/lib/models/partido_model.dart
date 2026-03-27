class Partido {
  final int idPartidos;
<<<<<<< HEAD
  final String? rival; // Mantener por compatibilidad
  final String formacion;
  final String equipoRival;
  final int idCronogramas;
=======
  final String? rival;
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b

  Partido({
    required this.idPartidos,
    this.rival,
<<<<<<< HEAD
    required this.formacion,
    required this.equipoRival,
    required this.idCronogramas,
=======
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
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
<<<<<<< HEAD
      formacion: json['Formacion']?.toString() ?? '',
      equipoRival: json['EquipoRival']?.toString() ?? json['Rival']?.toString() ?? '',
      idCronogramas: toInt(json['idCronogramas'], 0),
=======
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPartidos': idPartidos,
<<<<<<< HEAD
      'Rival': rival ?? equipoRival,
      'Formacion': formacion,
      'EquipoRival': equipoRival,
      'idCronogramas': idCronogramas,
=======
      'Rival': rival,
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
    };
  }
}