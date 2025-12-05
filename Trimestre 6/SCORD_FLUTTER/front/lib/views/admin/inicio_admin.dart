import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/persona_model.dart';

class InicioAdmin extends StatefulWidget {
  const InicioAdmin({super.key});

  @override
  State<InicioAdmin> createState() => _InicioAdminState();
}

class _InicioAdminState extends State<InicioAdmin> {
  final AuthService _authService = AuthService();
  Persona? adminData;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _initializeAdminData();
  }

  Future<void> _initializeAdminData() async {
  try {
    setState(() {
      loading = true;
      error = null;
    });

    // ✅ AGREGADO: Pequeño delay para asegurar que los datos estén guardados
    await Future.delayed(const Duration(milliseconds: 100));

    // Verificar si hay usuario autenticado
    final token = await _authService.obtenerToken();
    final user = await _authService.obtenerUsuario();
    
    print('🔍 TOKEN en InicioAdmin: $token');
    print('🔍 USER DATA en InicioAdmin: ${user?.toJson()}');

    if (token == null || user == null) {
      throw Exception('No hay sesión activa. Por favor inicia sesión.');
    }

    // Verificar que el usuario sea administrador
    final rolId = user.idRoles ?? 0;
    print('🔍 ROL ID VERIFICADO en InicioAdmin: $rolId');
    
    if (rolId != 1) {
      throw Exception('No tienes permisos de administrador');
    }

    // Intentar obtener datos actualizados de la API
    try {
      final datosActualizados = await _authService.obtenerDatosActualizados(user.idPersonas);
      if (mounted) {
        setState(() {
          adminData = datosActualizados ?? user;
        });
      }
    } catch (apiError) {
      // Si falla la API, usar datos guardados
      print('⚠️ Usando datos guardados: $apiError');
      if (mounted) {
        setState(() {
          adminData = user;
        });
      }
    }
    
    print('✅ Admin data cargada: ${adminData?.nombreCompleto}');
    
  } catch (e) {
    print('❌ ERROR en _initializeAdminData: $e');
    if (mounted) {
      setState(() {
        error = e.toString().replaceAll('Exception: ', '');
      });

      // Redirigir al login si no hay sesión
      if (error!.contains('sesión') || error!.contains('permisos')) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        });
      }
    }
  } finally {
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }
}

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon, String routeName) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.of(context).pop();
        
        if (routeName == '/Logout') {
          _logout();
        } else if (ModalRoute.of(context)?.settings.name != routeName) {
          Navigator.of(context).pushNamed(routeName);
        }
      },
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificar autenticación antes de renderizar
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                error!,
                style: const TextStyle(fontSize: 18, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              if (error!.contains('sesión')) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(color: Colors.red),
                const SizedBox(height: 8),
                const Text('Redirigiendo al login...'),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SCORD',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.red),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
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
            _buildDrawerItem(context, 'Inicio', Icons.home, '/InicioAdmin'),
            _buildDrawerItem(context, 'Cronograma', Icons.calendar_month, '/Cronograma'),
            _buildDrawerItem(context, 'Perfil Jugador', Icons.person_pin, '/PerfilJugadorAdmin'),
            _buildDrawerItem(context, 'Estadísticas Jugadores', Icons.bar_chart, '/EstadisticasJugadores'),
            _buildDrawerItem(context, 'Perfil Entrenador', Icons.sports_gymnastics, '/PerfilEntrenador'),
            _buildDrawerItem(context, 'Evaluar Jugadores', Icons.rule, '/EvaluarJugadores'),
            const Divider(),
            _buildDrawerItem(context, 'Cerrar Sesión', Icons.logout, '/Logout'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sección de bienvenida
            Container(
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
                  Card(
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
                  ),
                ],
              ),
            ),

            // Carrusel de información
            const SizedBox(height: 32),
            _buildCarousel(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(16),
        child: const Text(
          '© 2025 SCORD | Escuela de Fútbol Quilmes | Todos los derechos reservados',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 12),
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

  Widget _buildCarousel() {
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