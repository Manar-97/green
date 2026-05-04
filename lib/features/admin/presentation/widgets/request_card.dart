import 'package:flutter/material.dart';

class RequestCard extends StatelessWidget {
  final String name;
  final String wasteType;
  final String phone;
  final String nationalId;
  final String status;
  final VoidCallback? onApprove;

  const RequestCard({
    super.key,
    required this.name,
    required this.wasteType,
    required this.phone,
    required this.nationalId,
    required this.status,
    this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = status == "approved";

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("المخلفات: $wasteType"),
            Text("الهاتف: $phone"),
            Text("الرقم القومي: $nationalId"),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: isApproved ? null : onApprove,
          style: ElevatedButton.styleFrom(
            backgroundColor: isApproved ? Colors.green : Colors.blue,
          ),
          child: Text(isApproved ? "تم" : "قبول"),
        ),
      ),
    );
  }
}
