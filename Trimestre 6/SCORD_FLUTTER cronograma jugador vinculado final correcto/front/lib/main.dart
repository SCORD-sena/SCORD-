import 'package:flutter/material.dart';

import 'views/auth/login_screen.dart';

import 'views/admin/inicio_admin.dart';
import 'views/admin/perfil_jugador_admin_screen.dart';
import 'views/admin/estadisticas_jugador_screen.dart';
import 'views/admin/agregar_jugador_screen.dart';
import 'views/admin/agregar_rendimiento_screen.dart';
import 'views/admin/perfil_entrenador_admin_screen.dart';
import 'views/admin/agregar_entrenador_screen.dart';
import 'views/admin/cronograma_admin_screen.dart';
import 'views/admin/historialesViews/historial_jugadores_screen.dart';
import 'views/admin/historialesViews/historial_entrenadores_screen.dart';
import 'views/admin/gestion_categorias_screen.dart';


import 'views/entrenador/inicio_entrenador.dart';
import 'views/entrenador/perfil_jugador_entrenador.dart';
import 'views/entrenador/estadisticas_entrenador.dart';
import 'views/entrenador/agregar_rendimiento_entrenador_screen.dart';
import 'views/entrenador/cronograma_entrenador_screen.dart';

import 'views/jugador/inicio_jugador_screen.dart';
import 'views/jugador/estadisticas_jugador_screen.dart';
import 'views/jugador/cronograma_jugador_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SCORD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/InicioAdmin': (context) => const InicioAdmin(),
        '/PerfilJugadorAdmin': (context) => const PerfilJugadorAdminScreen(),
        '/AgregarJugador': (context) => const AgregarJugadorScreen(),
         '/PerfilEntrenadorAdmin': (context) => const PerfilEntrenadorAdminScreen(),
        '/AgregarEntrenador': (context) => const AgregarEntrenadorScreen(),
        '/AgregarRendimiento': (context) => const AgregarRendimientoScreen(),
        '/EstadisticasJugadores': (context) => const EstadisticasJugadorScreen(),
        '/CronogramaAdmin': (context) => const CronogramaAdminScreen(),
        '/HistorialJugadores': (context) => const HistorialJugadoresScreen(),
        '/HistorialEntrenadores': (context) => const HistorialEntrenadoresScreen(),
        '/GestionCategorias': (context) => const GestionCategoriasScreen(),
        


        '/InicioEntrenador': (context) => const InicioEntrenador(),       
        '/PerfilJugadorEntrenador': (context) => const PerfilJugadorEntrenadorScreen(),
        '/EstadisticasEntrenador': (context) => const EstadisticasJugadorEntrenadorScreen(),
        '/AgregarEstadisticasEntrenador': (context)=> const AgregarRendimientoEntrenadorScreen(),
        '/CronogramaEntrenador': (context) => const CronogramaEntrenadorScreen(),


        
        '/InicioJugador': (context) => const InicioJugadorScreen(),
        '/EstadisticasJugador': (context) => const EstadisticasIndividualesScreen(),
        '/CronogramaJugador': (context) => const CronogramaJugadorScreen(),
        
      },
    );
  }
}