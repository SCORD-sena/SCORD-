class RendimientoEliminado {
  final int idRendimientos;
  final int idPartidos;
  final int idJugadores;
  final int goles;
  final int golesDeCabeza;
  final int minutosJugados;
  final int asistencias;
  final int tirosApuerta;
  final int tarjetasRojas;
  final int tarjetasAmarillas;
  final int fuerasDeLugar;
  final int arcoEnCero;
  final String deletedAt;
  
  // Información del jugador
  final JugadorInfo jugador;
  
  // Información del partido
  final PartidoInfo partido;

  RendimientoEliminado({
    required this.idRendimientos,
    required this.idPartidos,
    required this.idJugadores,
    required this.goles,
    required this.golesDeCabeza,
    required this.minutosJugados,
    required this.asistencias,
    required this.tirosApuerta,
    required this.tarjetasRojas,
    required this.tarjetasAmarillas,
    required this.fuerasDeLugar,
    required this.arcoEnCero,
    required this.deletedAt,
    required this.jugador,
    required this.partido,
  });

  factory RendimientoEliminado.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is double) return value.toInt();
      return defaultValue;
    }

    return RendimientoEliminado(
      idRendimientos: toInt(json['IdRendimientos'], 0),
      idPartidos: toInt(json['idPartidos'], 0),
      idJugadores: toInt(json['idJugadores'], 0),
      goles: toInt(json['Goles'], 0),
      golesDeCabeza: toInt(json['GolesDeCabeza'], 0),
      minutosJugados: toInt(json['MinutosJugados'], 0),
      asistencias: toInt(json['Asistencias'], 0),
      tirosApuerta: toInt(json['TirosApuerta'], 0),
      tarjetasRojas: toInt(json['TarjetasRojas'], 0),
      tarjetasAmarillas: toInt(json['TarjetasAmarillas'], 0),
      fuerasDeLugar: toInt(json['FuerasDeLugar'], 0),
      arcoEnCero: toInt(json['ArcoEnCero'], 0),
      deletedAt: json['deleted_at'] ?? '',
      jugador: JugadorInfo.fromJson(json['jugador']),
      partido: PartidoInfo.fromJson(json['partido']),
    );
  }
}

class JugadorInfo {
  final int idJugadores;
  final String dorsal;
  final String posicion;
  final PersonaInfo persona;
  final CategoriaInfo categoria;

  JugadorInfo({
    required this.idJugadores,
    required this.dorsal,
    required this.posicion,
    required this.persona,
    required this.categoria,
  });

  factory JugadorInfo.fromJson(Map<String, dynamic> json) {
    return JugadorInfo(
      idJugadores: json['idJugadores'] ?? 0,
      dorsal: json['Dorsal']?.toString() ?? '',
      posicion: json['Posicion'] ?? '',
      persona: PersonaInfo.fromJson(json['persona']),
      categoria: CategoriaInfo.fromJson(json['categoria']),
    );
  }

  String get nombreCompleto => persona.nombreCompleto;
}

class PersonaInfo {
  final int idPersonas;
  final String nombre1;
  final String nombre2;
  final String apellido1;
  final String apellido2;

  PersonaInfo({
    required this.idPersonas,
    required this.nombre1,
    required this.nombre2,
    required this.apellido1,
    required this.apellido2,
  });

  factory PersonaInfo.fromJson(Map<String, dynamic> json) {
    return PersonaInfo(
      idPersonas: json['idPersonas'] ?? 0,
      nombre1: json['Nombre1'] ?? '',
      nombre2: json['Nombre2'] ?? '',
      apellido1: json['Apellido1'] ?? '',
      apellido2: json['Apellido2'] ?? '',
    );
  }

  String get nombreCompleto {
    final nombres = [nombre1, nombre2].where((n) => n.isNotEmpty).join(' ');
    final apellidos = [apellido1, apellido2].where((a) => a.isNotEmpty).join(' ');
    return '$nombres $apellidos'.trim();
  }
}

class CategoriaInfo {
  final int idCategorias;
  final String descripcion;

  CategoriaInfo({
    required this.idCategorias,
    required this.descripcion,
  });

  factory CategoriaInfo.fromJson(Map<String, dynamic> json) {
    return CategoriaInfo(
      idCategorias: json['idCategorias'] ?? 0,
      descripcion: json['Descripcion'] ?? '',
    );
  }
}

class PartidoInfo {
  final int idPartidos;
  final String equipoRival;
  final String formacion;
  final CronogramaInfo cronograma;

  PartidoInfo({
    required this.idPartidos,
    required this.equipoRival,
    required this.formacion,
    required this.cronograma,
  });

  factory PartidoInfo.fromJson(Map<String, dynamic> json) {
    return PartidoInfo(
      idPartidos: json['idPartidos'] ?? 0,
      equipoRival: json['EquipoRival'] ?? '',
      formacion: json['Formacion'] ?? '',
      cronograma: CronogramaInfo.fromJson(json['cronograma']),
    );
  }
}

class CronogramaInfo {
  final int idCronogramas;
  final String fechaDeEventos;
  final String ubicacion;
  final CompetenciaInfo? competencia;

  CronogramaInfo({
    required this.idCronogramas,
    required this.fechaDeEventos,
    required this.ubicacion,
    this.competencia,
  });

  factory CronogramaInfo.fromJson(Map<String, dynamic> json) {
    return CronogramaInfo(
      idCronogramas: json['idCronogramas'] ?? 0,
      fechaDeEventos: json['FechaDeEventos'] ?? '',
      ubicacion: json['Ubicacion'] ?? '',
      competencia: json['competencia'] != null 
          ? CompetenciaInfo.fromJson(json['competencia'])
          : null,
    );
  }
}

class CompetenciaInfo {
  final int idCompetencias;
  final String nombre;
  final String tipoCompetencia;
  final int ano;

  CompetenciaInfo({
    required this.idCompetencias,
    required this.nombre,
    required this.tipoCompetencia,
    required this.ano,
  });

  factory CompetenciaInfo.fromJson(Map<String, dynamic> json) {
    return CompetenciaInfo(
      idCompetencias: json['idCompetencias'] ?? 0,
      nombre: json['Nombre'] ?? '',
      tipoCompetencia: json['TipoCompetencia'] ?? '',
      ano: json['Ano'] ?? 0,
    );
  }
}