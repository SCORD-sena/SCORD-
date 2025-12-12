import 'persona_model.dart';
import 'categoria_model.dart';

class Jugador {
  final int idJugadores;
  final int idPersonas;
  final int dorsal;
  final String posicion;
  final String? upz;
  final double estatura;
  final String nomTutor1;
  final String? nomTutor2;
  final String apeTutor1;
  final String? apeTutor2;
  final String telefonoTutor;
  final int idCategorias;
  // Relaciones anidadas
  final Persona persona;
  final Categoria? categoria; // Incluido por si se usa en el futuro (no se usa en la vista de React)

  Jugador({
    required this.idJugadores,
    required this.idPersonas,
    required this.dorsal,
    required this.posicion,
    this.upz,
    required this.estatura,
    required this.nomTutor1,
    this.nomTutor2,
    required this.apeTutor1,
    this.apeTutor2,
    required this.telefonoTutor,
    required this.idCategorias,
    required this.persona,
    this.categoria,
  });

factory Jugador.fromJson(Map<String, dynamic> json) {
    // Definimos una función helper para parsear de forma segura, ya sea String o num
    dynamic safeParse(dynamic value) {
      if (value == null) return null;
      // Usamos .toString() para asegurar que es una cadena antes de parsear
      return value.toString();
    }
    
    return Jugador(
      idJugadores: json['idJugadores'] as int,
      idPersonas: json['idPersonas'] as int,
      
      // ✅ CORRECCIÓN 1: Dorsal (int) - Forzamos a String y luego a int.
      dorsal: int.parse(safeParse(json['Dorsal']) ?? '0'), 
      
      posicion: json['Posicion'] as String,
      upz: json['Upz'] as String?,
      
      // ✅ CORRECCIÓN 2: Estatura (double) - Forzamos a String y luego a double.
      estatura: double.parse(safeParse(json['Estatura']) ?? '0.0'),
      
      nomTutor1: json['NomTutor1'] as String,
      nomTutor2: json['NomTutor2'] as String?,
      apeTutor1: json['ApeTutor1'] as String,
      apeTutor2: json['ApeTutor2'] as String?,
      telefonoTutor: json['TelefonoTutor'] as String,
      idCategorias: json['idCategorias'] as int,
      persona: Persona.fromJson(json['persona']),
      categoria: json['categoria'] != null
          ? Categoria.fromJson(json['categoria'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Dorsal': dorsal,
      'Posicion': posicion,
      'Upz': upz,
      'Estatura': estatura,
      'NomTutor1': nomTutor1,
      'NomTutor2': nomTutor2,
      'ApeTutor1': apeTutor1,
      'ApeTutor2': apeTutor2,
      'TelefonoTutor': telefonoTutor,
      'idCategorias': idCategorias,
    };
  }
}