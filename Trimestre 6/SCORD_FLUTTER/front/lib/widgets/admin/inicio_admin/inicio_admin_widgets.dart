import 'package:flutter/material.dart';
import '../../../models/persona_model.dart';

/// Widget del menú lateral (Drawer)
class AdminDrawerMenu extends StatelessWidget {
  final Function(String) onItemTap;
  final VoidCallback onLogout;

  const AdminDrawerMenu({
    super.key,
    required this.onItemTap,
    required this.onLogout,
  });

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
          _buildDrawerItem('Inicio', Icons.home, '/InicioAdmin'),
          _buildDrawerItem('Cronograma', Icons.calendar_month, '/CronogramaAdmin'),
          _buildDrawerItem('Perfil Jugador', Icons.person_pin, '/PerfilJugadorAdmin'),
          _buildDrawerItem('Estadísticas Jugadores', Icons.bar_chart, '/EstadisticasJugadores'),
          _buildDrawerItem('Perfil Entrenador', Icons.sports_gymnastics, '/PerfilEntrenadorAdmin'),
          _buildDrawerItem('Evaluar Jugadores', Icons.rule, '/EvaluarJugadores'),
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

  Widget _buildDrawerItem(String title, IconData icon, String routeName) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () => onItemTap(routeName),
    );
  }
}

/// Widget de cabecera con bienvenida y foto de perfil
class AdminWelcomeHeader extends StatelessWidget {
  final Persona? adminData;

  const AdminWelcomeHeader({
    super.key,
    required this.adminData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Text(
            'Bienvenido(a), ${adminData?.nombreCorto ?? "Administrador"}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ClipOval(
            child: Image.asset(
              'assets/Foto_Perfil.webp',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 80, color: Colors.white),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          AdminInfoCard(adminData: adminData),
        ],
      ),
    );
  }
}

/// Card con información del administrador
class AdminInfoCard extends StatelessWidget {
  final Persona? adminData;

  const AdminInfoCard({
    super.key,
    required this.adminData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Nombre:', adminData?.nombreCompleto ?? 'No disponible'),
            const Divider(),
            _buildInfoRow('Edad:', adminData?.edad?.toString() ?? 'No disponible'),
            const Divider(),
            _buildInfoRow('Género:', adminData?.genero ?? 'No disponible'),
            const Divider(),
            _buildInfoRow('Rol:', 'Administrador', valueColor: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carrusel de información institucional
class InstitutionalCarousel extends StatelessWidget {
  const InstitutionalCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: PageView(
        children: [
          _buildCarouselItem(
            title: '¿Quiénes Somos?',
            description:
                'Somos un Club deportivo Fundado en el año 2010, ofrecemos espacios de formación deportiva, integral, enfocados en el Futbol, contribuimos a la formación personal deportiva de los niño, niñas y adolescentes mediante la aplicación de procesos metodológicos y pedagógicos para la enseñanza deportiva, complementada con principios y valores que les permitan un crecimiento como personas integras....',
            imagePath: 'assets/Escudo quilmes.jpg',
          ),
          _buildCarouselItem(
            title: 'Misión',
            description:
                'En Fénix, nuestra misión es formar futbolistas íntegros, promoviendo valores como el respeto, la disciplina y la perseverancia. A través de entrenamientos de alta calidad y participación en torneos, buscamos potenciar el talento de nuestros jugadores y brindarles oportunidades para crecer tanto en lo deportivo como en lo personal.',
            imagePath: 'assets/+3.png',
          ),
          _buildCarouselItem(
            title: 'Visión',
            description:
                'Nos proyectamos como una de las academias más reconocidas de Bogotá, destacándonos por nuestra excelencia en la formación de jugadores y nuestra contribución al desarrollo social. Aspiramos a ser un referente en el fútbol profesional y personal.',
            imagePath: 'assets/Niños-Fiesta.jpg',
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselItem({
    required String title,
    required String description,
    required String imagePath,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, size: 60),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de error
class ErrorDisplay extends StatelessWidget {
  final String error;
  final bool showRedirect;

  const ErrorDisplay({
    super.key,
    required this.error,
    this.showRedirect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: const TextStyle(fontSize: 18, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
          if (showRedirect) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Colors.red),
            const SizedBox(height: 8),
            const Text('Redirigiendo al login...'),
          ],
        ],
      ),
    );
  }
}

/// Widget de footer
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.all(16),
      child: const Text(
        '© 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos reservados',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}