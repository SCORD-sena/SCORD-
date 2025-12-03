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
  // La API de React parece incluir el tipo de documento anidado, lo incluimos para la lectura
  final TipoDocumento? tiposDeDocumentos;

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
  });

  factory Persona.fromJson(Map<String, dynamic> json) {
    return Persona(
      idPersonas: json['idPersonas'] as int,
      numeroDeDocumento: json['NumeroDeDocumento'] as String,
      idTiposDeDocumentos: json['idTiposDeDocumentos'] as int,
      nombre1: json['Nombre1'] as String,
      nombre2: json['Nombre2'] as String?,
      apellido1: json['Apellido1'] as String,
      apellido2: json['Apellido2'] as String?,
      genero: json['Genero'] as String,
      telefono: json['Telefono'] as String,
      direccion: json['Direccion'] as String,
      // Manejo de la fecha, asumiendo formato ISO 8601
      fechaDeNacimiento: DateTime.parse(json['FechaDeNacimiento'] as String),
      correo: json['correo'] as String,
      epsSisben: json['EpsSisben'] as String?,
      tiposDeDocumentos: json['tipos_de_documentos'] != null
          ? TipoDocumento.fromJson(json['tipos_de_documentos'])
          : null,
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
      // Formato yyyy-MM-dd para la API (como lo hace React: .split('T')[0])
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
}