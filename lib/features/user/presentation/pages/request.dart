import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:green/core/widgets/app_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
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
  Set<String> selectedType = {};

  final nameController = TextEditingController();
  // final profileController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  bool isProfileIncomplete(Map? profile) {
    if (profile == null) return true;

    final phone = profile['phone'];
    final address = profile['address'];
    final name = profile['name'];

    return phone == null ||
        phone.toString().trim().isEmpty ||
        address == null ||
        address.toString().trim().isEmpty ||
        name == null ||
        name.toString().trim().isEmpty;
  }

  @override
  void initState() {
    super.initState();
    checkProfile();
  }

  Future<void> checkProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final profile = await context.read<AuthCubit>().getProfile(user.id);

    if (!mounted) return;

    if (isProfileIncomplete(profile)) {
      Future.microtask(() {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => ProfileDialog(
            nameController: nameController,
            phoneController: phoneController,
            addressController: addressController,
            onSaved: () {},
          ),
        );
      });
    } else {
      loadUserData(profile!);
    }
  } // Future<void> checkProfile() async {
  //   final user = Supabase.instance.client.auth.currentUser;
  //   if (user == null) return;
  //
  //   final profile = await Supabase.instance.client
  //       .from('profiles')
  //       .select()
  //       .eq('id', user.id)
  //       .maybeSingle();
  //
  //   if (!mounted) return; // 👈 مهم جدًا
  //
  //   if (profile == null) {
  //     Future.microtask(() {
  //       showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (_) => ProfileDialog(
  //           nameController: nameController,
  //           // profileController: profileController,
  //           phoneController: phoneController,
  //           addressController: addressController,
  //           onSaved: () {
  //             final userId = Supabase.instance.client.auth.currentUser?.id;
  //             if (userId != null && mounted) {
  //               context.read<ProfileCubit>().loadProfile(userId);
  //             }
  //           },
  //         ),
  //       );
  //     });
  //   } else {
  //     loadUserData(profile);
  //   }
  // }

  void loadUserData(Map data) {
    nameController.text = data['name'] ?? '';
    // profileController.text = data['email'] ?? '';
    phoneController.text = data['phone'] ?? '';
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
    final wasteTypesString = selectedType.join(', ');

    await context.read<RequestCubit>().submitRequest(
      wasteType: wasteTypesString,
      name: nameController.text,
      phone: phoneController.text,
      address: addressController.text,
    );
    print("📤 SUBMIT CLICKED");
    print("TYPE => $wasteTypesString");
    print("NAME => ${nameController.text}");
    print("PHONE => ${phoneController.text}");
    print("ADDRESS => ${addressController.text}");
  }

  @override
  void dispose() {
    nameController.dispose();
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
                    runSpacing: 10.h,
                    children: [
                      WasteTypeChip(
                        text: "ورق",
                        isSelected: selectedType.contains("ورق"),
                        onTap: () {
                          setState(() {
                            if (selectedType.contains("ورق")) {
                              selectedType.remove("ورق");
                            } else {
                              selectedType.add("ورق");
                            }
                          });
                        },
                      ),

                      WasteTypeChip(
                        text: "بلاستيك",
                        isSelected: selectedType.contains("بلاستيك"),
                        onTap: () {
                          setState(() {
                            if (selectedType.contains("بلاستيك")) {
                              selectedType.remove("بلاستيك");
                            } else {
                              selectedType.add("بلاستيك");
                            }
                          });
                        },
                      ),

                      WasteTypeChip(
                        text: "معدن",
                        isSelected: selectedType.contains("معدن"),
                        onTap: () {
                          setState(() {
                            if (selectedType.contains("معدن")) {
                              selectedType.remove("معدن");
                            } else {
                              selectedType.add("معدن");
                            }
                          });
                        },
                      ),

                      WasteTypeChip(
                        text: "أخرى",
                        isSelected: selectedType.contains("أخرى"),
                        onTap: () {
                          setState(() {
                            if (selectedType.contains("أخرى")) {
                              selectedType.remove("أخرى");
                            } else {
                              selectedType.add("أخرى");
                            }
                          });
                        },
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
