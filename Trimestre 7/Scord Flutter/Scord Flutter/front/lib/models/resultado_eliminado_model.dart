class ResultadoEliminado {
  final int idResultados;
  final String marcador;
  final int puntosObtenidos;
  final String? observacion;
  final int idPartidos;
  final String deletedAt;
  
  // Información del partido
  final PartidoResultadoInfo partido;

  ResultadoEliminado({
    required this.idResultados,
    required this.marcador,
    required this.puntosObtenidos,
    this.observacion,
    required this.idPartidos,
    required this.deletedAt,
    required this.partido,
  });

  factory ResultadoEliminado.fromJson(Map<String, dynamic> json) {
    return ResultadoEliminado(
      idResultados: json['idResultados'] ?? 0,
      marcador: json['Marcador'] ?? '',
      puntosObtenidos: json['PuntosObtenidos'] ?? 0,
      observacion: json['Observacion'],
      idPartidos: json['idPartidos'] ?? 0,
      deletedAt: json['deleted_at'] ?? '',
      partido: PartidoResultadoInfo.fromJson(json['partido']),
    );
  }
}

class PartidoResultadoInfo {
  final int idPartidos;
  final String equipoRival;
  final String formacion;
  final CronogramaResultadoInfo cronograma;

  PartidoResultadoInfo({
    required this.idPartidos,
    required this.equipoRival,
    required this.formacion,
    required this.cronograma,
  });

  factory PartidoResultadoInfo.fromJson(Map<String, dynamic> json) {
    return PartidoResultadoInfo(
      idPartidos: json['idPartidos'] ?? 0,
      equipoRival: json['EquipoRival'] ?? '',
      formacion: json['Formacion'] ?? '',
      cronograma: CronogramaResultadoInfo.fromJson(json['cronograma']),
    );
  }
}

class CronogramaResultadoInfo {
  final int idCronogramas;
  final String fechaDeEventos;
  final String ubicacion;
  final CompetenciaResultadoInfo? competencia;
  final CategoriaResultadoInfo? categoria;

  CronogramaResultadoInfo({
    required this.idCronogramas,
    required this.fechaDeEventos,
    required this.ubicacion,
    this.competencia,
    this.categoria,
  });

  factory CronogramaResultadoInfo.fromJson(Map<String, dynamic> json) {
    return CronogramaResultadoInfo(
      idCronogramas: json['idCronogramas'] ?? 0,
      fechaDeEventos: json['FechaDeEventos'] ?? '',
      ubicacion: json['Ubicacion'] ?? '',
      competencia: json['competencia'] != null 
          ? CompetenciaResultadoInfo.fromJson(json['competencia'])
          : null,
      categoria: json['categoria'] != null 
          ? CategoriaResultadoInfo.fromJson(json['categoria'])
          : null,
    );
  }
}

class CompetenciaResultadoInfo {
  final int idCompetencias;
  final String nombre;
  final String tipoCompetencia;
  final int ano;

  CompetenciaResultadoInfo({
    required this.idCompetencias,
    required this.nombre,
    required this.tipoCompetencia,
    required this.ano,
  });

  factory CompetenciaResultadoInfo.fromJson(Map<String, dynamic> json) {
    return CompetenciaResultadoInfo(
      idCompetencias: json['idCompetencias'] ?? 0,
      nombre: json['Nombre'] ?? '',
      tipoCompetencia: json['TipoCompetencia'] ?? '',
      ano: json['Ano'] ?? 0,
    );
  }
}

class CategoriaResultadoInfo {
  final int idCategorias;
  final String descripcion;

  CategoriaResultadoInfo({
    required this.idCategorias,
    required this.descripcion,
  });

  factory CategoriaResultadoInfo.fromJson(Map<String, dynamic> json) {
    return CategoriaResultadoInfo(
      idCategorias: json['idCategorias'] ?? 0,
      descripcion: json['Descripcion'] ?? '',
    );
  }
}