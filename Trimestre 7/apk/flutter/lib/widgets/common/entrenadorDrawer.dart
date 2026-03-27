import 'package:flutter/material.dart';
import '/../services/logout_service.dart';

class EntrenadorDrawer extends StatelessWidget {
  final String currentRoute;
  final LogoutService _logoutService = LogoutService();

  EntrenadorDrawer({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header con diseño similar al AdminDrawer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade700, Colors.red.shade500],
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
                            Icons.sports_gymnastics,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Entrenador',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón de logout en el header
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: 'Cerrar Sesión',
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _logoutService.logout(context);
                        },
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
                  '/InicioEntrenador',
                ),
                _buildDrawerItem(
                  context,
                  'Cronograma',
                  Icons.calendar_month,
                  '/CronogramaEntrenador',
                ),
                _buildDrawerItem(
                  context,
                  'Perfil Jugador',
                  Icons.person_pin,
                  '/PerfilJugadorEntrenador',
                ),
                _buildDrawerItem(
                  context,
                  'Estadísticas Jugadores',
                  Icons.bar_chart,
                  '/EstadisticasEntrenador',
                ),
                _buildDrawerItem(
                  context,
                  'Comparar Jugadores',
                  Icons.rule,
                  '/ComparacionJugadoresEntrenador',
                ),
                _buildDrawerItem(
                  context,
                  'Resultados',
                  Icons.scoreboard,
                  '/GestionResultadosEntrenador',
                ),
                _buildDrawerItem(
                  context,
                  'Competencias',
                  Icons.emoji_events,
                  '/CompetenciasEntrenador',
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

  // Método para items del drawer
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
        color: isCurrentRoute ? Colors.red.shade700 : Colors.red,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isCurrentRoute ? FontWeight.bold : FontWeight.normal,
          color: isCurrentRoute ? Colors.red.shade700 : Colors.black,
        ),
      ),
      tileColor: isCurrentRoute ? Colors.red.shade50 : null,
      onTap: () {
        Navigator.of(context).pop();
        
        if (currentRoute != routeName) {
          Navigator.of(context).pushNamed(routeName);
        }
      },
    );
  }
}