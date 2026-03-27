import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:http/http.dart' as http;

class LogoutService {
  final AuthService _authService = AuthService();

  Future<void> logout(BuildContext context, {bool showConfirmation = true}) async {
    
    final navigator = Navigator.of(context, rootNavigator: true);
    
    bool confirmar = true;

    // Si se requiere confirmación, mostrar el diálogo
    if (showConfirmation) {
      confirmar = await _showConfirmationDialog(context) ?? false;
    }

    if (confirmar) {
      try {
  
        await _authService.limpiarTodo();
        await navigator.pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
        
      } catch (e) {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Error al cerrar sesión');
        }
      }
    } else {
    }
  }

  /// 💬 Mostrar diálogo de confirmación
  Future<bool?> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE63946).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout,
                color: Color(0xFFE63946),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Cerrar Sesión'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE63946),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  /// ⚠ Mostrar mensaje de error
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}