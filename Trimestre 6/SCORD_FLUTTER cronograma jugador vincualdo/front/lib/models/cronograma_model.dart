class Cronograma { 
  final int idCronogramas; 
  final String tipoDeEventos; 
  final String fechaDeEventos; 
  final String? hora; // ← NUEVO
  final String ubicacion; 
  final String? canchaPartido; 
  final String? sedeEntrenamiento; 
  final String? descripcion; 
  final int idCategorias;
  final int? idCompetencias;
 
  Cronograma({ 
    required this.idCronogramas, 
    required this.tipoDeEventos, 
    required this.fechaDeEventos, 
    this.hora, // ← NUEVO
    required this.ubicacion, 
    this.canchaPartido, 
    this.sedeEntrenamiento, 
    this.descripcion, 
    required this.idCategorias,
    this.idCompetencias,
  }); 
 
  factory Cronograma.fromJson(Map<String, dynamic> json) { 
  // Validación para debugging
  if (json['idCategorias'] == null) {
    print('⚠️ WARNING: idCategorias es null en: $json');
  }
  
  return Cronograma( 
    idCronogramas: json['idCronogramas'] as int? ?? 0, 
    tipoDeEventos: json['TipoDeEventos'] as String? ?? '', 
    fechaDeEventos: json['FechaDeEventos'] as String? ?? '', 
    hora: json['Hora'] as String?, 
    ubicacion: json['Ubicacion'] as String? ?? '', 
    canchaPartido: json['CanchaPartido'] as String?, 
    sedeEntrenamiento: json['SedeEntrenamiento'] as String?, 
    descripcion: json['Descripcion'] as String?, 
    idCategorias: json['idCategorias'] as int? ?? 0, // ← Protección temporal
    idCompetencias: json['idCompetencias'] as int?, 
  ); 
}
 
  Map<String, dynamic> toJson() { 
    return {
      'TipoDeEventos': tipoDeEventos, 
      'FechaDeEventos': fechaDeEventos, 
      'Hora': hora, // ← NUEVO
      'Ubicacion': ubicacion, 
      'CanchaPartido': canchaPartido, 
      'SedeEntrenamiento': sedeEntrenamiento ?? '', 
      'Descripcion': descripcion ?? '', 
      'idCategorias': idCategorias,
      'idCompetencias': idCompetencias,
    };
  } 
 
  Cronograma copyWith({ 
    int? idCronogramas, 
    String? tipoDeEventos, 
    String? fechaDeEventos, 
    String? hora, // ← NUEVO
    String? ubicacion, 
    String? canchaPartido, 
    String? sedeEntrenamiento, 
    String? descripcion, 
    int? idCategorias,
    int? idCompetencias,
  }) { 
    return Cronograma( 
      idCronogramas: idCronogramas ?? this.idCronogramas, 
      tipoDeEventos: tipoDeEventos ?? this.tipoDeEventos, 
      fechaDeEventos: fechaDeEventos ?? this.fechaDeEventos, 
      hora: hora ?? this.hora, // ← NUEVO
      ubicacion: ubicacion ?? this.ubicacion, 
      canchaPartido: canchaPartido ?? this.canchaPartido, 
      sedeEntrenamiento: sedeEntrenamiento ?? this.sedeEntrenamiento, 
      descripcion: descripcion ?? this.descripcion, 
      idCategorias: idCategorias ?? this.idCategorias,
      idCompetencias: idCompetencias ?? this.idCompetencias,
    ); 
  } 
}