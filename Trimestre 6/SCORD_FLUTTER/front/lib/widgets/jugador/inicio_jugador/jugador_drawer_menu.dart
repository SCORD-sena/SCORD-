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
      leading: Icon(icon, color: const Color(0xffe63946)),
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
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xffe63946)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.sports_soccer, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'SCORD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Jugador',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem('Inicio', Icons.home, '/InicioJugador'),
          _buildDrawerItem('Mis Estadísticas', Icons.bar_chart, '/EstadisticasJugador'),
          _buildDrawerItem('Cronograma', Icons.calendar_month, '/Cronograma'),
          _buildDrawerItem('Competencias', Icons.emoji_events, '/CompetenciasJugador'),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xffe63946)),
            title: const Text('Cerrar Sesión', style: TextStyle(fontSize: 16)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}