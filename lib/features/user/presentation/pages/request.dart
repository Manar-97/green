import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:green/core/widgets/app_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/request_cubit.dart';
import '../cubit/request_state.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/waste_type_chip.dart';
import '../widgets/profile_dialog.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({super.key});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  String selectedType = '';

  final nameController = TextEditingController();
  final nidController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkProfile();
  }

  Future<void> checkProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final profile = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (!mounted) return; // 👈 مهم جدًا

    if (profile == null) {
      Future.microtask(() {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => ProfileDialog(
            nameController: nameController,
            phoneController: phoneController,
            nidController: nidController,
            addressController: addressController,
            onSaved: () {
              final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId != null && mounted) {
                context.read<ProfileCubit>().loadProfile(userId);
              }
            },
          ),
        );
      });
    } else {
      loadUserData(profile);
    }
  }

  void loadUserData(Map data) {
    nameController.text = data['name'] ?? '';
    phoneController.text = data['phone'] ?? '';
    nidController.text = data['national_id'] ?? '';
    addressController.text = data['address'] ?? '';
  }

  void submit() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final profile = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (profile == null) {
      showAppDialog(
        context,
        title: "تنبيه",
        message: "من فضلك أدخل بياناتك الأول",
      );
      return;
    }
    if (selectedType.isEmpty) {
      showAppDialog(context, title: "تنبيه", message: "اختار نوع المخلفات");
      return;
    }
    await context.read<RequestCubit>().submitRequest(
      wasteType: selectedType,
      name: nameController.text,
      phone: phoneController.text,
      nationalId: nidController.text,
      address: addressController.text,
    );
    print("📤 SUBMIT CLICKED");
    print("TYPE => $selectedType");
    print("NAME => ${nameController.text}");
    print("PHONE => ${phoneController.text}");
    print("NID => ${nidController.text}");
    print("ADDRESS => ${addressController.text}");
  }

  @override
  void dispose() {
    nameController.dispose();
    nidController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RequestCubit, RequestState>(
      listener: (context, state) {
        if (state.success) {
          showAppDialog(
            context,
            title: "تم",
            message: "تم إرسال الطلب بنجاح",
            isSuccess: true,
          );
          context.read<RequestCubit>().resetStatus(); // ✅ مهم
        }

        if (state.error != null) {
          showAppDialog(context, title: "خطأ", message: state.error!);
          context.read<RequestCubit>().resetStatus(); // ✅ مهم
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.all(15.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.green, Colors.lightGreen],
                      ),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Text(
                      "مشروع الطريق الاخضر لعالم اكثر امانا 🌍",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "اختار نوع المخلفات واملأ البيانات",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 10.w,
                    children: [
                      WasteTypeChip(
                        text: "ورق",
                        isSelected: selectedType == "ورق",
                        onTap: () => setState(() => selectedType = "ورق"),
                      ),
                      WasteTypeChip(
                        text: "بلاستيك",
                        isSelected: selectedType == "بلاستيك",
                        onTap: () => setState(() => selectedType = "بلاستيك"),
                      ),
                      WasteTypeChip(
                        text: "معدن",
                        isSelected: selectedType == "معدن",
                        onTap: () => setState(() => selectedType = "معدن"),
                      ),
                      WasteTypeChip(
                        text: "أخرى",
                        isSelected: selectedType == "أخرى",
                        onTap: () => setState(() => selectedType = "أخرى"),
                      ),
                    ],
                  ),
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
                      onPressed: state.isSubmitting ? null : submit,
                      style: AppStyles.buttonStyle,
                      child: state.isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "إرسال الطلب",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22.sp,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
