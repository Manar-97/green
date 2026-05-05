import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/widgets/app_dialog.dart';
import '../cubit/profile_cubit.dart';
import 'custom_text_field.dart';

class ProfileDialog extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController nidController;
  final TextEditingController addressController;
  final VoidCallback onSaved;

  const ProfileDialog({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.nidController,
    required this.addressController,
    required this.onSaved,
  });

  Future<void> saveProfile(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await Supabase.instance.client.from('profiles').insert({
      "id": user.id,
      "name": nameController.text,
      "phone": phoneController.text,
      "national_id": nidController.text,
      "address": addressController.text,
      "score": 0,
    });
    // 🟢 أهم سطر
    await context.read<ProfileCubit>().loadProfile(user.id);
    // 🟢 احفظ context قبل ما تقفلي
    final navigator = Navigator.of(context);
    onSaved();
    navigator.pop();

    // 🟢 استخدمي context آمن (root)
    Future.delayed(Duration(milliseconds: 200), () {
      showAppDialog(
        navigator.context,
        title: "تمام 🎉",
        message: "تم حفظ بياناتك بنجاح",
        isSuccess: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(20.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "🌿 أهلاً بيك",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10.h),

              const Text("من فضلك أدخل بياناتك لأول مرة"),

              SizedBox(height: 20.h),

              CustomTextField(
                controller: nameController,
                label: "الاسم",
                icon: Icons.person,
              ),
              CustomTextField(
                controller: nidController,
                label: "الرقم القومي",
                icon: Icons.badge,
                isNumber: true,
              ),
              CustomTextField(
                controller: phoneController,
                label: "الهاتف",
                icon: Icons.phone,
                isNumber: true,
              ),
              CustomTextField(
                controller: addressController,
                label: "العنوان",
                icon: Icons.location_on,
              ),

              SizedBox(height: 20.h),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => saveProfile(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("حفظ 🌱"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
