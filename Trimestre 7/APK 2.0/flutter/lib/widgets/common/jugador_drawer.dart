import 'package:flutter/material.dart';
import '../../services/logout_service.dart';

class JugadorDrawer extends StatelessWidget {
  final String currentRoute;

  const JugadorDrawer({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header mejorado con botón de logout
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFE63946), Colors.red.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.sports_soccer,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Jugador',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ✅ BOTÓN DE LOGOUT
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Cerrar Sesión',
                        onPressed: () => _handleLogout(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de opciones scrolleable
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: <Widget>[
                _buildDrawerItem(
                  context,
                  'Inicio',
                  Icons.home,
                  '/InicioJugador',
                ),
                _buildDrawerItem(
                  context,
                  'Mis Estadísticas',
                  Icons.bar_chart,
                  '/EstadisticasJugador',
                ),

                _buildDrawerItem(
                  context,
                  'Competencias',
                  Icons.emoji_events,
                  '/CompetenciasJugador',
                ),
                _buildDrawerItem(
                  context,
                  'Resultados',
                  Icons.assessment,
                  '/ResultadosJugador',
                ),
                _buildDrawerItem(
                  context,
                  'Cronograma',
                  Icons.calendar_month,
                  '/CronogramaJugador',
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'SCORD',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ MANEJO DE LOGOUT
  Future<void> _handleLogout(BuildContext context) async {
    // Cerrar el drawer
    Navigator.of(context).pop();
    
    // Ejecutar el logout
    final logoutService = LogoutService();
    await logoutService.logout(context);
  }

  /// 📱 ITEM DEL MENÚ
  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    String routeName,
  ) {
    final isCurrentRoute = currentRoute == routeName;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isCurrentRoute ? const Color(0xFFE63946) : Colors.red,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isCurrentRoute ? FontWeight.bold : FontWeight.normal,
          color: isCurrentRoute ? const Color(0xFFE63946) : Colors.black,
        ),
      ),
      tileColor: isCurrentRoute ? const Color(0xFFE63946).withOpacity(0.1) : null,
      onTap: () {
        Navigator.of(context).pop();
        
        if (currentRoute != routeName) {
          Navigator.of(context).pushNamed(routeName);
        }
      },
    );
  }
}