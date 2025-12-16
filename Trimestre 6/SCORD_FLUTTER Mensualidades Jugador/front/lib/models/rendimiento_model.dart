class UltimoRegistro {
  final int idRendimientos;
  final int idPartidos;
  final int goles;
  final int golesDeCabeza;
  final int minutosJugados;
  final int asistencias;
  final int tirosApuerta;
  final int tarjetasRojas;
  final int tarjetasAmarillas;
  final int fuerasDeLugar;
  final int arcoEnCero;

  UltimoRegistro({
    required this.idRendimientos,
    required this.idPartidos,
    required this.goles,
    required this.golesDeCabeza,
    required this.minutosJugados,
    required this.asistencias,
    required this.tirosApuerta,
    required this.tarjetasRojas,
    required this.tarjetasAmarillas,
    required this.fuerasDeLugar,
    required this.arcoEnCero,
  });

  factory UltimoRegistro.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is double) return value.toInt();
      return defaultValue;
    }

    return UltimoRegistro(
      idRendimientos: toInt(json['IdRendimientos'], 0),
      idPartidos: toInt(json['idPartidos'], 0),
      goles: toInt(json['Goles'], 0),
      golesDeCabeza: toInt(json['GolesDeCabeza'], 0),
      minutosJugados: toInt(json['MinutosJugados'], 0),
      asistencias: toInt(json['Asistencias'], 0),
      tirosApuerta: toInt(json['TirosApuerta'], 0),
      tarjetasRojas: toInt(json['TarjetasRojas'], 0),
      tarjetasAmarillas: toInt(json['TarjetasAmarillas'], 0),
      fuerasDeLugar: toInt(json['FuerasDeLugar'], 0),
      arcoEnCero: toInt(json['ArcoEnCero'], 0),
    );
  }

  Map<String, dynamic> toUpdateJson(int idJugadores) {
    return {
      'Goles': goles,
      'GolesDeCabeza': golesDeCabeza,
      'MinutosJugados': minutosJugados,
      'Asistencias': asistencias,
      'TirosApuerta': tirosApuerta,
      'TarjetasRojas': tarjetasRojas,
      'TarjetasAmarillas': tarjetasAmarillas,
      'FuerasDeLugar': fuerasDeLugar,
      'ArcoEnCero': arcoEnCero,
      'idPartidos': idPartidos,
      'idJugadores': idJugadores,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'IdRendimientos': idRendimientos,
      'idPartidos': idPartidos,
      'Goles': goles,
      'GolesDeCabeza': golesDeCabeza,
      'MinutosJugados': minutosJugados,
      'Asistencias': asistencias,
      'TirosApuerta': tirosApuerta,
      'TarjetasRojas': tarjetasRojas,
      'TarjetasAmarillas': tarjetasAmarillas,
      'FuerasDeLugar': fuerasDeLugar,
      'ArcoEnCero': arcoEnCero,
    };
  }
}

class EstadisticasTotales {
  final Map<String, dynamic> totales;
  final Map<String, dynamic> promedios;

  EstadisticasTotales({
    required this.totales,
    required this.promedios,
  });

  factory EstadisticasTotales.fromJson(Map<String, dynamic> json) {
    return EstadisticasTotales(
      totales: json['totales'] is Map 
          ? Map<String, dynamic>.from(json['totales']) 
          : {},
      promedios: json['promedios'] is Map 
          ? Map<String, dynamic>.from(json['promedios']) 
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totales': totales,
      'promedios': promedios,
    };
  }
}