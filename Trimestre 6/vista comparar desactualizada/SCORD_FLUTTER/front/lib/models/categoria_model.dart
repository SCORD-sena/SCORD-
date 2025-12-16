class Categoria {
  final int idCategorias;
  final String descripcion;

  Categoria({
    required this.idCategorias,
    required this.descripcion,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      idCategorias: json['idCategorias'] as int,
      descripcion: json['Descripcion'] as String,
    );
  }
}