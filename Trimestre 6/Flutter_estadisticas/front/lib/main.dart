import 'package:flutter/material.dart';
import 'estadisticasjugador.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SCORD App',
      theme: ThemeData(
        // Define aquí tu tema principal
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      // La pantalla principal será tu nuevo widget
      home: const EstadisticasJugadorBasico(),
    );
  }
}