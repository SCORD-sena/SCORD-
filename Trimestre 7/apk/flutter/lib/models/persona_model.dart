import 'tipo_documento_model.dart';

class Persona {
  final int idPersonas;
  final String numeroDeDocumento;
  final int idTiposDeDocumentos;
  final String nombre1;
  final String? nombre2;
  final String apellido1;
  final String? apellido2;
  final String genero;
  final String telefono;
  final String direccion;
  final DateTime fechaDeNacimiento;
  final String correo;
  final String? epsSisben;
  final TipoDocumento? tiposDeDocumentos;
  final int? idRoles; // ⭐ AGREGADO para manejar el rol

  Persona({
    required this.idPersonas,
    required this.numeroDeDocumento,
    required this.idTiposDeDocumentos,
    required this.nombre1,
    this.nombre2,
    required this.apellido1,
    this.apellido2,
    required this.genero,
    required this.telefono,
    required this.direccion,
    required this.fechaDeNacimiento,
    required this.correo,
    this.epsSisben,
    this.tiposDeDocumentos,
    this.idRoles, // ⭐ AGREGADO
  });

  factory Persona.fromJson(Map<String, dynamic> json) {
  
  // Obtener idRoles de forma segura
  int? idRoles;
  if (json['idRoles'] != null) {
    idRoles = int.tryParse(json['idRoles'].toString());
  } else if (json['Rol'] != null && json['Rol']['idRoles'] != null) {
    idRoles = int.tryParse(json['Rol']['idRoles'].toString());
  }

  // ✅ OBTENER idTiposDeDocumentos correctamente
  int idTiposDeDocumentos;
  if (json['idTiposDeDocumentos'] is int) {
    idTiposDeDocumentos = json['idTiposDeDocumentos'];
  } else if (json['idTiposDeDocumentos'] is Map) {
    // Si es un objeto, extraer el id del objeto
    idTiposDeDocumentos = json['idTiposDeDocumentos']['idTiposDeDocumentos'] as int;
  } else {
    idTiposDeDocumentos = int.parse(json['idTiposDeDocumentos'].toString());
  }

  return Persona(
    idPersonas: int.parse(json['idPersonas'].toString()),
    numeroDeDocumento: json['NumeroDeDocumento'].toString(),
    idTiposDeDocumentos: idTiposDeDocumentos, // ✅ Usar la variable procesada
    nombre1: json['Nombre1'] as String,
    nombre2: json['Nombre2'] as String?,
    apellido1: json['Apellido1'] as String,
    apellido2: json['Apellido2'] as String?,
    genero: json['Genero'] as String,
    telefono: json['Telefono'].toString(),
    direccion: json['Direccion'] as String,
    fechaDeNacimiento: DateTime.parse(json['FechaDeNacimiento'] as String),
    correo: json['correo'] as String,
    epsSisben: json['EpsSisben'] as String?,
    tiposDeDocumentos: json['tipos_de_documentos'] != null
    ? TipoDocumento.fromJson(json['tipos_de_documentos'])
    : (json['idTiposDeDocumentos'] is Map
        ? TipoDocumento.fromJson(json['idTiposDeDocumentos'])
        : null),
    idRoles: idRoles,
  );
}
  Map<String, dynamic> toJson({String? contrasena}) {
    final data = {
      'NumeroDeDocumento': numeroDeDocumento,
      'Nombre1': nombre1,
      'Nombre2': nombre2,
      'Apellido1': apellido1,
      'Apellido2': apellido2,
      'correo': correo,
      'FechaDeNacimiento': fechaDeNacimiento.toIso8601String().split('T')[0],
      'Genero': genero,
      'Telefono': telefono,
      'Direccion': direccion,
      'EpsSisben': epsSisben,
      'idTiposDeDocumentos': idTiposDeDocumentos,
    };
    if (contrasena != null && contrasena.isNotEmpty) {
      data['contrasena'] = contrasena;
    }
    return data;
  }

  // ⭐ MÉTODOS ÚTILES AGREGADOS
  String get nombreCompleto {
    return '$nombre1 ${nombre2 ?? ''} $apellido1 ${apellido2 ?? ''}'
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String get nombreCorto {
    return '$nombre1 $apellido1'.trim();
  }

  int? get edad {
  try {
    final hoy = DateTime.now();
    int edad = hoy.year - fechaDeNacimiento.year;
    final mes = hoy.month - fechaDeNacimiento.month;
    if (mes < 0 || (mes == 0 && hoy.day < fechaDeNacimiento.day)) {
      edad--;
    }
    return edad;
  } catch (e) {
    print('Error calculando edad: $e');
    return null;
  }
}
}