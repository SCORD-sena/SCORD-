import 'package:flutter/material.dart';
import 'CronogramaController.dart';   // tu controlador real

class CronogramaAdmin extends StatefulWidget {
  const CronogramaAdmin({super.key});

  @override
  State<CronogramaAdmin> createState() => _CronogramaAdminState();
}

class _CronogramaAdminState extends State<CronogramaAdmin> {
  final controller = CronogramaController();

  bool loading = true;

  List cronogramas = [];
  List partidos = [];
  List categorias = [];

  @override
  void initState() {
    super.initState();
    cargarTodo();
  }

  Future<void> cargarTodo() async {
    setState(() => loading = true);

    cronogramas = await controller.getCronogramas();
    partidos = await controller.getPartidos();
    categorias = await controller.getCategorias();

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gestión de Cronograma",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // =============================
                  // LISTA DE ENTRENAMIENTOS
                  // =============================
                  const Text(
                    "Entrenamientos",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...cronogramas
                      .where((e) => e["TipoDeEventos"] == "Entrenamiento")
                      .map((e) => Card(
                            child: ListTile(
                              title: Text("Cancha: ${e['NumeroCancha']}"),
                              subtitle: Text(
                                  "Fecha: ${e['FechaYHora']}\nCategoría: ${e['idCategorias']}"),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await controller.borrarCronograma(e["idCronogramas"]);
                                  cargarTodo();
                                },
                              ),
                            ),
                          )),

                  const SizedBox(height: 40),

                  // =============================
                  // LISTA DE PARTIDOS
                  // =============================
                  const Text(
                    "Partidos",
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...partidos.map((p) => Card(
                        child: ListTile(
                          title: Text("Partido: ${p['EquipoLocal']} vs ${p['EquipoVisitante']}"),
                          subtitle: Text("Categoría: ${p['idCategorias']}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await controller.borrarPartido(p["idPartidos"]);
                              cargarTodo();
                            },
                          ),
                        ),
                      )),
                ],
              ),
            ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
        onPressed: () {
          // Aquí podrás luego abrir tu formulario
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Agregar evento"),
              content: const Text("Aquí irá tu formulario próximamente."),
              actions: [
                TextButton(
                  child: const Text("Cerrar"),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
