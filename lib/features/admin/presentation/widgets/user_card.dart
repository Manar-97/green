import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green,
          child: Text(name.isNotEmpty ? name[0] : "?"),
        ),
        title: Text(name),
        subtitle: Text(phone),
        trailing: Container(
          padding: EdgeInsets.all(8.h),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text("⭐ $score"),
        ),
      ),
    );
  }
}
