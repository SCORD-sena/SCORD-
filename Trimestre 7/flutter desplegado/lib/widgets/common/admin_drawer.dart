import 'package:flutter/material.dart';
import '../../services/logout_service.dart';

class AdminDrawer extends StatelessWidget {
  final String currentRoute;

  const AdminDrawer({
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
                            Icons.admin_panel_settings,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Administrador',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ✅ BOTÓN DE LOGOUT MEJORADO
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
                _buildDrawerItem(context, 'Inicio', Icons.home, '/InicioAdmin'),
                _buildDrawerItem(context, 'Cronograma', Icons.calendar_month, '/CronogramaAdmin'),
                _buildDrawerItem(context, 'Perfil Jugador', Icons.person_pin, '/PerfilJugadorAdmin'),
                _buildDrawerItem(context, 'Estadísticas Jugadores', Icons.bar_chart, '/EstadisticasJugadores'),
                _buildDrawerItem(context, 'Perfil Entrenador', Icons.sports_gymnastics, '/PerfilEntrenadorAdmin'),
                _buildDrawerItem(context, 'Comparar Jugadores', Icons.rule, '/ComparacionJugadores'),
                _buildDrawerItem(context, 'Categorías', Icons.category, '/GestionCategorias'),
                _buildDrawerItem(context, 'Resultados', Icons.scoreboard, '/GestionResultados'),
                _buildDrawerItem(context, 'Competencias', Icons.emoji_events, '/GestionCompetencias'),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(thickness: 1),
                ),
                
                // Menú desplegable de Historial
                ExpansionTile(
                  leading: const Icon(Icons.history, color: Colors.red),
                  title: const Text(
                    'Historial',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildDrawerSubItem(context, 'Jugadores Eliminados', Icons.person_off, '/HistorialJugadores'),
                    _buildDrawerSubItem(context, 'Entrenadores Eliminados', Icons.sports, '/HistorialEntrenadores'),
                    _buildDrawerSubItem(context, 'Categorías Eliminadas', Icons.category, '/HistorialCategorias'),
                    _buildDrawerSubItem(context, 'Entrenamientos Eliminados', Icons.fitness_center, '/HistorialEntrenamientos'),
                    _buildDrawerSubItem(context, 'Partidos Eliminados', Icons.sports_soccer, '/HistorialPartidos'),
                    _buildDrawerSubItem(context, 'Rendimientos Eliminados', Icons.assessment, '/HistorialRendimientos'),
                    _buildDrawerSubItem(context, 'Resultados Eliminados', Icons.scoreboard, '/HistorialResultados'),
                    _buildDrawerSubItem(context, 'Competencias Eliminadas', Icons.emoji_events, '/HistorialCompetencias'),
                  ],
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

Future<void> _handleLogout(BuildContext context) async {
  // Cerrar el drawer
  Navigator.of(context).pop();
  
  // Ejecutar el logout inmediatamente
  // (El servicio ya tiene el navigator capturado desde el inicio)
  final logoutService = LogoutService();
  await logoutService.logout(context);
}

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

  Widget _buildDrawerSubItem(
    BuildContext context,
    String title,
    IconData icon,
    String routeName,
  ) {
    final isCurrentRoute = currentRoute == routeName;
    
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Icon(
          icon,
          color: isCurrentRoute ? Colors.red.shade700 : Colors.red,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isCurrentRoute ? FontWeight.bold : FontWeight.normal,
          color: isCurrentRoute ? Colors.red.shade700 : Colors.black,
        ),
      ),
      tileColor: isCurrentRoute ? Colors.red.shade50 : null,
      contentPadding: const EdgeInsets.only(left: 32, right: 16),
      onTap: () {
        Navigator.of(context).pop();
        
        if (currentRoute != routeName) {
          Navigator.of(context).pushNamed(routeName);
        }
      },
    );
  }
}