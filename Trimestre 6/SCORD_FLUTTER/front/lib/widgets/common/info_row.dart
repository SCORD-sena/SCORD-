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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: isEditing && editWidget != null
                ? editWidget!
                : Text(
                    value,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.end,
                  ),
          ),
        ],
      ),
    );
  }
}