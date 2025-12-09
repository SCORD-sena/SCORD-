import 'package:flutter/material.dart';

class InicioEntrenador extends StatelessWidget {
  const InicioEntrenador({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Column(
        children: [
          // --------------------------------------------------------------------
          // HEADER (Logo + Título + Navbar)
          // --------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 5, color: Colors.black26),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 15),
                        Image.asset("assets/logo.jpg", height: 50),
                        const SizedBox(width: 10),
                        const Text(
                          "SCORD",
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.menu, size: 32, color: Colors.red),
                    ),
                  ],
                ),

                // ---------------- NAVBAR ENTRENADOR ----------------
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      navItem("Inicio"),
                      navItem("Mi Equipo"),
                      navItem("Asistencias"),
                      navItem("Torneos"),
                      navItem("Cerrar Sesión", color: Colors.red),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --------------------------------------------------------------------
          // CONTENIDO SCROLLABLE
          // --------------------------------------------------------------------
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 25),

                  // --------------------------------------------------------------
                  // BIENVENIDA + INFO USUARIO
                  // --------------------------------------------------------------
                  const Text(
                    "Bienvenido(a), Andres Prada",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),

                  const SizedBox(height: 15),

                  CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage("assets/FotoPerfil.png"),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 6,
                            color: Colors.black.withOpacity(0.15)),
                      ],
                      color: Colors.white,
                    ),
                    child: Column(
                      children: const [
                        infoRow("Nombre:", "Andres Prada"),
                        Divider(),
                        infoRow("Edad:", "24"),
                        Divider(),
                        infoRow("Género:", "Masculino"),
                        Divider(),
                        infoRow("Entrenador Categoría:", "2007"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // --------------------------------------------------------------
                  // CARRUSEL
                  // --------------------------------------------------------------
                  SizedBox(
                    height: 420,
                    child: PageView(
                      children: [
                        carouselPage(
                          title: "¿Quiénes Somos?",
                          text:
                              "Somos Fénix, una escuela de fútbol apasionada por la formación deportiva y el desarrollo integral de nuestros jugadores...",
                          img: "assets/Escudo_Quilmes.jpg",
                        ),
                        carouselPage(
                          title: "Misión",
                          text:
                              "Nuestra misión es formar futbolistas íntegros promoviendo respeto, disciplina y perseverancia...",
                          img: "assets/mas3.png",
                        ),
                        carouselPage(
                          title: "Visión",
                          text:
                              "Aspiramos a ser una de las academias más reconocidas por nuestra excelencia deportiva...",
                          img: "assets/Niños-Fiesta.jpg",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),
                ],
              ),
            ),
          ),

          // --------------------------------------------------------------------
          // FOOTER
          // --------------------------------------------------------------------
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: const [
                Text(
                  "SCORD",
                  style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "Sistema de control y organización deportiva",
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 10),
                Text(
                  "Escuela Quilmes — Formando talentos",
                  style: TextStyle(color: Colors.white70),
                ),
                SizedBox(height: 10),
                Divider(color: Colors.white24),
                SizedBox(height: 10),
                Text(
                  "© 2025 SCORD | Todos los derechos reservados",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------
// COMPONENTES REUTILIZABLES
// --------------------------------------------------------------------
Widget navItem(String text, {Color color = Colors.black}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Text(
      text,
      style: TextStyle(
          fontSize: 16, color: color, fontWeight: FontWeight.w600),
    ),
  );
}

class infoRow extends StatelessWidget {
  final String label;
  final String value;

  const infoRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

Widget carouselPage({
  required String title,
  required String text,
  required String img,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: const [
        BoxShadow(blurRadius: 10, color: Colors.black26),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
              color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Text(
          text,
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            img,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ],
    ),
  );
}
