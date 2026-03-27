import 'package:flutter/material.dart';
import 'NavbarAdmin.dart';



class InicioAdmin extends StatelessWidget {
  const InicioAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio Admin'),
      ),

  drawer: const NavbarAdmin(),  

      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                width: double.infinity,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// TITULO DE BIENVENIDA
                    Text(
                      'Bienvenido(a),',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),

                    Text(
                      'Jose Niño',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// FOTO DE PERFIL
                    Center(
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: const AssetImage('assets/FotoPerfil.webp'),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// TARJETA DE OPCIONES
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Panel Administrativo',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            'Aquí puedes gestionar ligas, equipos, jugadores y más.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// BOTÓN DE EJEMPLO
                    Center(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Ir al Panel'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
