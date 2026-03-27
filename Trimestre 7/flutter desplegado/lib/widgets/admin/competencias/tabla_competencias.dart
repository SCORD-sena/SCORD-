import 'package:flutter/material.dart';
import '../../../models/competencia_model.dart';

class TablaCompetencias extends StatelessWidget {
  final List<Competencia> competencias;
  final Function(Competencia) onEditar;
  final Function(Competencia) onEliminar;

  const TablaCompetencias({
    super.key,
    required this.competencias,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    if (competencias.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text('No hay competencias registradas'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: competencias.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final comp = competencias[index];
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(comp.ano.toString(), 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            ),
            title: Text(comp.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(comp.tipoCompetencia),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => onEditar(comp),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => onEliminar(comp),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}