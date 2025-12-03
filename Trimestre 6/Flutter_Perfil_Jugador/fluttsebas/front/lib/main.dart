// front/lib/main.dart

import 'package:flutter/material.dart';

// ⚠️ Asegúrate que tus archivos importados existen en estas rutas:
import './views/perfil_jugador_admin_screen.dart'; 
import './views/agregar_jugador_screen.dart';

void main() {
runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
const MyApp({super.key}); 

@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'SCORD',
theme: ThemeData(
 // Color principal de tu aplicación
 colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red).copyWith(secondary: Colors.redAccent),
 useMaterial3: true,
),
 
 // Definición de Rutas
 initialRoute: '/PerfilJugadorAdmin', // O la ruta inicial que uses
 routes: {
 '/PerfilJugadorAdmin': (context) => const PerfilJugadorAdminScreen(),
 '/AgregarJugador': (context) => const AgregarJugadorScreen(), // Nueva ruta
},
 );
}
}