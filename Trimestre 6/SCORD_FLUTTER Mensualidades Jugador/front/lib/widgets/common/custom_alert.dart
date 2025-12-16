import 'package:flutter/material.dart';

class CustomAlert {
  /// Muestra una alerta simple con un botón de aceptar
  static Future<void> mostrar(
    BuildContext context,
    String title,
    String content,
    Color color,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: color)),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Aceptar',
                style: TextStyle(color: Color(0xffe63946))
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Muestra un diálogo de confirmación con botones Cancelar/Confirmar
  static Future<bool> confirmar(
    BuildContext context,
    String title,
    String content,
    String confirmText,
    Color confirmColor,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey)
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                confirmText,
                style: TextStyle(
                  color: confirmColor,
                  fontWeight: FontWeight.bold
                )
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;
  }
}