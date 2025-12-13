class Cronograma { 
  final int idCronogramas; 
  final String tipoDeEventos; 
  final String fechaDeEventos; 
  final String ubicacion; 
  final String? canchaPartido; 
  final String? sedeEntrenamiento; 
  final String? descripcion; 
  final int idCategorias;
  final int? idCompetencias; // ✅ Nullable
 
  Cronograma({ 
    required this.idCronogramas, 
    required this.tipoDeEventos, 
    required this.fechaDeEventos, 
    required this.ubicacion, 
    this.canchaPartido, 
    this.sedeEntrenamiento, 
    this.descripcion, 
    required this.idCategorias,
    this.idCompetencias, // ✅ Nullable
  }); 
 
  factory Cronograma.fromJson(Map<String, dynamic> json) { 
    return Cronograma( 
      idCronogramas: json['idCronogramas'], 
      tipoDeEventos: json['TipoDeEventos'], 
      fechaDeEventos: json['FechaDeEventos'], 
      ubicacion: json['Ubicacion'], 
      canchaPartido: json['CanchaPartido'], 
      sedeEntrenamiento: json['SedeEntrenamiento'], 
      descripcion: json['Descripcion'], 
      idCategorias: json['idCategorias'],
      idCompetencias: json['idCompetencias'], // Puede ser null
    ); 
  } 
 
  Map<String, dynamic> toJson() { 
    return {
      'TipoDeEventos': tipoDeEventos, 
      'FechaDeEventos': fechaDeEventos, 
      'Ubicacion': ubicacion, 
      'CanchaPartido': canchaPartido, 
      'SedeEntrenamiento': sedeEntrenamiento ?? '', 
      'Descripcion': descripcion ?? '', 
      'idCategorias': idCategorias,
      'idCompetencias': idCompetencias, // ✅ Envía null si es null, o el ID si existe
    };
  } 
 
  Cronograma copyWith({ 
    int? idCronogramas, 
    String? tipoDeEventos, 
    String? fechaDeEventos, 
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
      ubicacion: ubicacion ?? this.ubicacion, 
      canchaPartido: canchaPartido ?? this.canchaPartido, 
      sedeEntrenamiento: sedeEntrenamiento ?? this.sedeEntrenamiento, 
      descripcion: descripcion ?? this.descripcion, 
      idCategorias: idCategorias ?? this.idCategorias,
      idCompetencias: idCompetencias ?? this.idCompetencias,
    ); 
  } 
}