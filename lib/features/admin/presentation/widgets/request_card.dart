import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class RequestCard extends StatelessWidget {
  final String name;
  final String wasteType;
  final String phone;
  final String requestDate;
  final String status;
  final VoidCallback? onApprove;

  const RequestCard({
    super.key,
    required this.name,
    required this.wasteType,
    required this.phone,
    required this.requestDate,
    required this.status,
    this.onApprove,
  });

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('yyyy/MM/dd - hh:mm a').format(parsed);
    } catch (e) {
      return date; // fallback لو حصل error
    }
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = status == "approved";

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("المخلفات: $wasteType"),
            Text("الهاتف: $phone"),
            Text("الوقت: ${formatDate(requestDate)}"),
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
