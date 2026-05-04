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

    case ErrorType.database:
      icon = Icons.storage;
      color = Colors.deepPurple;
      title = "Database Error";
      break;

    case ErrorType.storage:
      icon = Icons.cloud;
      color = Colors.blue;
      title = "Storage Error";
      break;

    case ErrorType.timeout:
      icon = Icons.timer_off;
      color = Colors.amber;
      title = "Timeout";
      break;

    case ErrorType.unknown:
      icon = Icons.warning;
      color = Colors.grey;
      title = "Unexpected Error";
      break;

    case ErrorType.validation:
      icon = Icons.error_outline;
      color = Colors.teal;
      title = "Validation Error";
      break;

    case ErrorType.functions:
      icon = Icons.settings;
      color = Colors.purple;
      title = "Server Function Error";
      break;

    case ErrorType.realtime:
      icon = Icons.sync;
      color = Colors.indigo;
      title = "Realtime Error";
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

        if (type == ErrorType.network)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // trigger retry callback (لو ضفتها لاحقًا)
            },
            child: const Text("Retry"),
          ),
      ],
    ),
  );
}
