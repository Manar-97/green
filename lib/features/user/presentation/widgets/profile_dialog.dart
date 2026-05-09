import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/widgets/app_dialog.dart';
import '../cubit/profile_cubit.dart';
import 'custom_text_field.dart';

class ProfileDialog extends StatelessWidget {
  final TextEditingController nameController;
  // final TextEditingController profileController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final VoidCallback onSaved;

  const ProfileDialog({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.onSaved,
    // required this.profileController,
  });

  Future<void> saveProfile(BuildContext context) async {
    debugPrint("📤 [PROFILE] SAVE CLICKED");

    final user = Supabase.instance.client.auth.currentUser;

    debugPrint("👤 user = ${user?.id} / ${user?.email}");

    if (user == null) {
      debugPrint("❌ USER NULL");
      return;
    }

    final phone = phoneController.text.trim();
    debugPrint("📱 phone = $phone");
    debugPrint("🏠 address = ${addressController.text}");
    debugPrint("👤 name = ${nameController.text}");

    try {
      final res = await Supabase.instance.client.from('profiles').upsert({
        "id": user.id,
        "email": user.email ?? '',
        "name": nameController.text.trim(),
        "phone": phone,
        "address": addressController.text.trim(),
        "score": 0,
      }).select();

      debugPrint("🟢 UPSERT RESULT = $res");

      if (!context.mounted) {
        debugPrint("❌ context not mounted");
        return;
      }
      await context.read<ProfileCubit>().loadProfile(user.id);
      debugPrint("🔄 profile reloaded");

      if (!context.mounted) {
        debugPrint("❌ context not mounted");
        return;
      }
      onSaved();
      Navigator.pop(context);
      //
      // showAppDialog(
      //   Navigator.of(context).context,
      //   title: "تمام 🎉",
      //   message: "تم حفظ بياناتك بنجاح",
      //   isSuccess: true,
      // );
      debugPrint("🏁 SAVE DONE");
    } catch (e, st) {
      debugPrint("❌ SAVE PROFILE ERROR = $e");
      debugPrint("📌 STACK = $st");
    }
  }
  // Future<void> saveProfile(BuildContext context) async {
  //   final user = Supabase.instance.client.auth.currentUser;
  //   if (user == null) return;
  //
  //   final phone = phoneController.text.trim();
  //
  //   if (phone.length != 11 || !RegExp(r'^\d{11}$').hasMatch(phone)) {
  //     showAppDialog(
  //       context,
  //       title: "خطأ",
  //       message: "رقم الهاتف لازم يكون 11 رقم",
  //     );
  //     return;
  //   }
  //
  //   await Supabase.instance.client.from('profiles').upsert({
  //     "id": user.id,
  //     "name": nameController.text,
  //     "email": user.email,
  //     "phone": phone,
  //     "address": addressController.text,
  //     "score": 0,
  //   }, onConflict: 'id');
  //
  //   await context.read<ProfileCubit>().loadProfile(user.id);
  //
  //   final navigator = Navigator.of(context);
  //   onSaved();
  //   navigator.pop();
  //
  //   Future.delayed(const Duration(milliseconds: 200), () {
  //     showAppDialog(
  //       navigator.context,
  //       title: "تمام 🎉",
  //       message: "تم حفظ بياناتك بنجاح",
  //       isSuccess: true,
  //     );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
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
              // CustomTextField(
              //   controller: profileController,
              //   label: "الايميل",
              //   icon: Icons.email,
              // ),
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
