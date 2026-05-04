import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String phone;
  final int score;

  const UserCard({
    super.key,
    required this.name,
    required this.phone,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(name.isNotEmpty ? name[0] : "?"),
        ),
        title: Text(name),
        subtitle: Text(phone),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text("⭐ $score"),
        ),
      ),
    );
  }
}