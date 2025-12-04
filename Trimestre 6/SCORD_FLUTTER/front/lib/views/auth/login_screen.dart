import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController correo = TextEditingController();
  final TextEditingController contrasena = TextEditingController();

  bool loading = false;
  bool showPass = false;
  String error = "";

  @override
  void dispose() {
    correo.dispose();
    contrasena.dispose();
    super.dispose();
  }

Future<void> iniciarSesion() async {
  setState(() {
    loading = true;
    error = "";
  });

  try {
    final data = await _authService.login(
      correo.text.trim(),
      contrasena.text.trim(),
    );

    print('🔍 RESPUESTA COMPLETA: $data');

    if (data["success"] == true) {
      final user = data["user"];
      
      if (user == null) {
        throw Exception("Datos de usuario no disponibles");
      }

      // Obtener el rol de forma segura
      int? rol;
      
      if (user["idRoles"] != null) {
        rol = int.tryParse(user["idRoles"].toString());
      } else if (user["Rol"] != null && user["Rol"]["idRoles"] != null) {
        rol = int.tryParse(user["Rol"]["idRoles"].toString());
      }

      print('🔍 ROL OBTENIDO: $rol (tipo: ${rol.runtimeType})');

      if (rol == null) {
        throw Exception("No se pudo determinar el rol del usuario");
      }

      // ✅ AGREGADO: Esperar a que se guarden los datos
      await Future.delayed(const Duration(milliseconds: 300));
      
      // ✅ AGREGADO: Verificar que se guardaron correctamente
      final tokenGuardado = await _authService.obtenerToken();
      final usuarioGuardado = await _authService.obtenerUsuario();
      
      print('✅ Token guardado: ${tokenGuardado != null}');
      print('✅ Usuario guardado: ${usuarioGuardado != null}');
      print('✅ Rol del usuario guardado: ${usuarioGuardado?.idRoles}');

      // Navegación según el rol
      if (!mounted) return;
      
      switch (rol) {
        case 1:
          Navigator.pushReplacementNamed(context, "/InicioAdmin");
          break;
        case 2:
          Navigator.pushReplacementNamed(context, "/InicioEntrenador");
          break;
        case 3:
          Navigator.pushReplacementNamed(context, "/InicioJugador");
          break;
        default:
          setState(() => error = "Rol desconocido: $rol");
      }
    } else {
      setState(() {
        error = data["message"] ?? "Error al iniciar sesión";
      });
    }
  } catch (e) {
    print('❌ ERROR EN LOGIN: $e');
    setState(() {
      error = "Error de conexión. Intente nuevamente.";
    });
  } finally {
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Image.asset("assets/SCORD.png", height: 60),
                const SizedBox(width: 12),
                const Text(
                  "SCORD",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: 500,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 8,
                        color: Colors.black26,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Iniciar Sesión",
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      if (error.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  error,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              )
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: correo,
                        decoration: const InputDecoration(
                          labelText: "Correo",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: contrasena,
                        obscureText: !showPass,
                        decoration: InputDecoration(
                          labelText: "Contraseña",
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showPass
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                showPass = !showPass;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : iniciarSesion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Iniciar Sesión",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "¿Olvidó su contraseña?",
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black,
            child: const Text(
              "© 2025 SCORD | Escuela de Fútbol Quilmes",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}