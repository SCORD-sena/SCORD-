class Partido {
  final int idPartidos;
  final String? rival;

  Partido({
    required this.idPartidos,
    this.rival,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPartidos': idPartidos,
      'Rival': rival,
    };
  }
}