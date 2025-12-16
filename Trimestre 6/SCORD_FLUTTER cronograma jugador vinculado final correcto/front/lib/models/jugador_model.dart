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
  final Categoria? categoria;

  // ====== NUEVO CAMPO DE STATUS ======
  final String? status; // 'activo', 'inactivo', 'retirado'

  // ====== CAMPOS DE MENSUALIDAD ======
  final DateTime? fechaIngresoClub;
  final TiempoEnClub? tiempoEnClub;
  final DateTime? fechaVencimientoMensualidad;
  final DiasParaVencimiento? diasParaVencimiento;
  final bool? mensualidadVencida;
  final String? estadoPago; // 'al_dia', 'por_vencer', 'no_pagado', 'sin_definir'

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
    // Nuevo parámetro
    this.status,
    // Parámetros de mensualidad
    this.fechaIngresoClub,
    this.tiempoEnClub,
    this.fechaVencimientoMensualidad,
    this.diasParaVencimiento,
    this.mensualidadVencida,
    this.estadoPago,
  });

  factory Jugador.fromJson(Map<String, dynamic> json) {
    // Helper para parsear de forma segura
    dynamic safeParse(dynamic value) {
      if (value == null) return null;
      return value.toString();
    }
    
    return Jugador(
      idJugadores: json['idJugadores'] as int,
      idPersonas: json['idPersonas'] as int,
      dorsal: int.parse(safeParse(json['Dorsal']) ?? '0'), 
      posicion: json['Posicion'] as String,
      upz: json['Upz'] as String?,
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
      
      // ====== PARSEAR STATUS ======
      status: json['status'] as String?,
      
      // ====== PARSEAR CAMPOS DE MENSUALIDAD ======
      fechaIngresoClub: json['fechaIngresoClub'] != null
          ? DateTime.parse(json['fechaIngresoClub'])
          : null,
      tiempoEnClub: json['tiempo_en_club'] != null
          ? TiempoEnClub.fromJson(json['tiempo_en_club'])
          : null,
      fechaVencimientoMensualidad: json['fechaVencimientoMensualidad'] != null
          ? DateTime.parse(json['fechaVencimientoMensualidad'])
          : null,
      diasParaVencimiento: json['dias_para_vencimiento'] != null
          ? DiasParaVencimiento.fromJson(json['dias_para_vencimiento'])
          : null,
      mensualidadVencida: json['mensualidadVencida'] as bool?,
      estadoPago: json['estadoPago'] as String?,
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

// ====== CLASES AUXILIARES PARA MENSUALIDAD ======

class TiempoEnClub {
  final int anios;
  final int meses;
  final int dias;
  final int totalDias;
  final String texto;

  TiempoEnClub({
    required this.anios,
    required this.meses,
    required this.dias,
    required this.totalDias,
    required this.texto,
  });

  factory TiempoEnClub.fromJson(Map<String, dynamic> json) {
    return TiempoEnClub(
      anios: json['años'] as int? ?? 0,
      meses: json['meses'] as int? ?? 0,
      dias: json['dias'] as int? ?? 0,
      totalDias: json['total_dias'] as int? ?? 0,
      texto: json['texto'] as String? ?? '',
    );
  }
}

class DiasParaVencimiento {
  final int dias;
  final bool vencido;
  final String texto;

  DiasParaVencimiento({
    required this.dias,
    required this.vencido,
    required this.texto,
  });

  factory DiasParaVencimiento.fromJson(Map<String, dynamic> json) {
    return DiasParaVencimiento(
      dias: json['dias'] as int? ?? 0,
      vencido: json['vencido'] as bool? ?? false,
      texto: json['texto'] as String? ?? '',
    );
  }
}