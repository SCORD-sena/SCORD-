class Categoria {
  final int idCategorias;
  final String descripcion;
  final String tiposCategoria;

  Categoria({
    required this.idCategorias,
    required this.descripcion,
    required this.tiposCategoria,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      idCategorias: json['idCategorias'] ?? 0,
      descripcion: json['Descripcion'] ?? '',
      tiposCategoria: json['TiposCategoria'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCategorias': idCategorias,
      'Descripcion': descripcion,
      'TiposCategoria': tiposCategoria,
    };
  }

  Categoria copyWith({
    int? idCategorias,
    String? descripcion,
    String? tiposCategoria,
  }) {
    return Categoria(
      idCategorias: idCategorias ?? this.idCategorias,
      descripcion: descripcion ?? this.descripcion,
      tiposCategoria: tiposCategoria ?? this.tiposCategoria,
    );
  }
}