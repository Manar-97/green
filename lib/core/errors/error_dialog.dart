import 'package:flutter/material.dart';
import '../errors/exceptions.dart';

void showErrorDialog(
  BuildContext context, {
  required String message,
  required ErrorType type,
}) {
  IconData icon;
  Color color;
  String title;

  switch (type) {
    case ErrorType.network:
      icon = Icons.wifi_off;
      color = Colors.orange;
      title = "No Internet";
      break;

    case ErrorType.auth:
      icon = Icons.lock;
      color = Colors.red;
      title = "Authentication Error";
      break;

    case ErrorType.server:
      icon = Icons.error;
      color = Colors.deepPurple;
      title = "Server Error";
      break;

    case ErrorType.unknown:
      icon = Icons.warning;
      color = Colors.grey;
      title = "Unexpected Error";
      break;
  }

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
