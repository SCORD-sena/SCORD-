import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChange;

  const PaginationWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón anterior
          IconButton(
            onPressed: currentPage > 1 ? () => onPageChange(currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Página anterior',
          ),

          // Números de página
          ...List.generate(totalPages, (index) {
            final page = index + 1;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: () => onPageChange(page),
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentPage == page ? Colors.red : Colors.grey[300],
                  foregroundColor: currentPage == page ? Colors.white : Colors.black,
                  minimumSize: const Size(40, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text('$page'),
              ),
            );
          }),

          // Botón siguiente
          IconButton(
            onPressed: currentPage < totalPages ? () => onPageChange(currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Página siguiente',
          ),
        ],
      ),
    );
  }
}