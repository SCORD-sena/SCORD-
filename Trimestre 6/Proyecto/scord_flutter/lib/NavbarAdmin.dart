import 'package:flutter/material.dart';

class NavbarAdmin extends StatelessWidget {
  const NavbarAdmin({super.key});

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context); // Cierra el drawer
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.red),
            child: Text(
              "SCORD",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // === OPCIONES DEL MENÚ ===

          ListTile(
            title: const Text("Inicio"),
            onTap: () => _navigate(context, "/InicioAdmin"),
          ),

          ListTile(
            title: const Text("Cronograma"),
            onTap: () => _navigate(context, "/CronogramaAdmin"), // ← CORREGIDO
          ),

          ListTile(
            title: const Text("Perfil Jugador"),
            onTap: () => _navigate(context, "/PerfilJugadorAdmin"),
          ),

          ListTile(
            title: const Text("Estadísticas Jugadores"),
            onTap: () => _navigate(context, "/EstadisticasJugador"),
          ),

          ListTile(
            title: const Text("Perfil Entrenador"),
            onTap: () => _navigate(context, "/PerfilEntrenadorAdmin"),
          ),

          ListTile(
            title: const Text("Evaluar Jugadores"),
            onTap: () => _navigate(context, "/EstJugadorAdmin"),
          ),

          const Divider(),

          // === LOGOUT ===
          ListTile(
            title: const Text(
              "Cerrar Sesión",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _navigate(context, "/CerrarSesion"),
          ),
        ],
      ),
    );
  }
}
