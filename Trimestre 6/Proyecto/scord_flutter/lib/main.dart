import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'InicioAdmin.dart';
import 'InicioEntrenador.dart';
//import 'InicioJugador.dart';
import 'CronogramaAdmin.dart';
import 'PerfilJugadorAdmin.dart';




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'assets/SCORD.png',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const LoginScreen(),
      routes: {
        "/InicioAdmin": (_) => const InicioAdmin(),
        "/InicioEntrenador": (_) => const InicioEntrenador(),
        //"/InicioJugador": (_) => const InicioJugador(),
        "/CronogramaAdmin": (_) => const CronogramaAdmin(),
        "/PerfilJugadorAdmin": (_) => const PerfilJugadorAdmin(),

      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores
  final TextEditingController correo = TextEditingController();
  final TextEditingController contrasena = TextEditingController();

  bool loading = false;
  bool showPass = false;
  String error = "";

  Future<void> iniciarSesion() async {
    setState(() {
      loading = true;
      error = "";
    });

    try {
      final url = Uri.parse("http://127.0.0.1:8000/api/login"); 

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "correo": correo.text.trim(),
          "contrasena": contrasena.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        // Guardar token localmente
        // (si quieres se puede usar SharedPreferences)

        final rol = data["user"]["Rol"]["idRoles"];

        if (rol == 1) {
          Navigator.pushReplacementNamed(context, "/InicioAdmin");
        } else if (rol == 2) {
          Navigator.pushReplacementNamed(context, "/InicioEntrenador");
        } else if (rol == 3) {
          Navigator.pushReplacementNamed(context, "/InicioJugador");
        } else {
          setState(() => error = "Rol desconocido");
        }
      } else {
        setState(() {
          error = data["message"] ?? "Error al iniciar sesión";
        });
      }
    } catch (e) {
      setState(() {
        error = "Error de conexión. Intente nuevamente.";
      });
    }

    setState(() {
      loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          // ---------- HEADER ----------
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Image.asset("SCORD.png", height: 60),
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

                      // ---------- ERROR ----------
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

                      // ---------- CORREO ----------
                      TextField(
                        controller: correo,
                        decoration: const InputDecoration(
                          labelText: "Correo",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ---------- CONTRASEÑA ----------
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

                      // ---------- BOTÓN LOGIN ----------
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

          // ---------- FOOTER ----------
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
