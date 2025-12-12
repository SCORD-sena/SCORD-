import 'persona_model.dart';
import 'categoria_model.dart';

class Entrenador {
  final int idEntrenadores;
  final int idPersonas;
  final int anosDeExperiencia;
  final String cargo;
  final Persona? persona;
  final List<Categoria>? categorias;

  Entrenador({
    required this.idEntrenadores,
    required this.idPersonas,
    required this.anosDeExperiencia,
    required this.cargo,
    this.persona,
    this.categorias,
  });

  // Crear desde JSON
  factory Entrenador.fromJson(Map<String, dynamic> json) {
    return Entrenador(
      idEntrenadores: json['idEntrenadores'] ?? 0,
      idPersonas: json['idPersonas'] ?? 0,
      anosDeExperiencia: json['AnosDeExperiencia'] ?? 0,
      cargo: json['Cargo'] ?? '',
      persona: json['persona'] != null ? Persona.fromJson(json['persona']) : null,
      categorias: json['categorias'] != null
          ? (json['categorias'] as List)
              .map((cat) => Categoria.fromJson(cat))
              .toList()
          : null,
    );
  }

  // Convertir a JSON (solo datos básicos, sin relaciones)
  Map<String, dynamic> toJson() {
    return {
      'idEntrenadores': idEntrenadores,
      'idPersonas': idPersonas,
      'AnosDeExperiencia': anosDeExperiencia,
      'Cargo': cargo,
    };
  }

  // Crear copia con modificaciones
  Entrenador copyWith({
    int? idEntrenadores,
    int? idPersonas,
    int? anosDeExperiencia,
    String? cargo,
    Persona? persona,
    List<Categoria>? categorias,
  }) {
    return Entrenador(
      idEntrenadores: idEntrenadores ?? this.idEntrenadores,
      idPersonas: idPersonas ?? this.idPersonas,
      anosDeExperiencia: anosDeExperiencia ?? this.anosDeExperiencia,
      cargo: cargo ?? this.cargo,
      persona: persona ?? this.persona,
      categorias: categorias ?? this.categorias,
    );
  }
}