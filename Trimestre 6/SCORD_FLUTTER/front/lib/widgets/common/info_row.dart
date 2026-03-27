import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditing;
  final Widget? editWidget;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isEditing = false,
    this.editWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
<<<<<<< HEAD
      padding: const EdgeInsets.symmetric(vertical: 6.0),
=======
      padding: const EdgeInsets.symmetric(vertical: 8.0),
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
<<<<<<< HEAD
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xffe63946),
=======
                fontWeight: FontWeight.w600,
                fontSize: 14,
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: isEditing && editWidget != null
                ? editWidget!
                : Text(
                    value,
<<<<<<< HEAD
                    style: const TextStyle(fontSize: 13),
                    textAlign: TextAlign.right,
=======
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.end,
>>>>>>> 77fbf37e833f546a83348df26e99d07ab761018b
                  ),
          ),
        ],
      ),
    );
  }
}