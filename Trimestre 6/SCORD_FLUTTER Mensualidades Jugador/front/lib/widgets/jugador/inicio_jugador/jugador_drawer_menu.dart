import 'package:flutter/material.dart';

class JugadorDrawerMenu extends StatelessWidget {
  final Function(String) onItemTap;
  final Function() onLogout;

  const JugadorDrawerMenu({
    super.key,
    required this.onItemTap,
    required this.onLogout,
  });

  Widget _buildDrawerItem(String title, IconData icon, String routeName) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () => onItemTap(routeName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.red),
            child: Text(
              'Menú de Navegación',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildDrawerItem('Inicio', Icons.home, '/InicioJugador'),
          _buildDrawerItem('Cronograma', Icons.calendar_month, '/Cronograma'),
          _buildDrawerItem('Competencias', Icons.person, '/CompetenciasJugador'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(fontSize: 16)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}