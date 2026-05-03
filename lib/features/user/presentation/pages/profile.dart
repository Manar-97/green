import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/pages/login.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        context.read<ProfileCubit>().loadProfile(userId);
      }
    });
  }

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.withOpacity(0.1),
            child: Icon(icon, color: Colors.green),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("ملفي الشخصي"),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final user = state.user;
            if (user == null) {
              return const Center(child: Text("لا يوجد بيانات"));
            }
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    // 👤 Avatar
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withOpacity(0.1),
                      ),
                      child: const CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "User Profile",
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                    ),
                    SizedBox(height: 25.h),
                    // 📦 Info Cards
                    buildInfoCard(
                      icon: Icons.home,
                      title: "العنوان",
                      value: user.address,
                    ),

                    buildInfoCard(
                      icon: Icons.phone,
                      title: "الهاتف",
                      value: user.phone,
                    ),

                    buildInfoCard(
                      icon: Icons.badge,
                      title: "الرقم القومي",
                      value: user.nationalId,
                    ),

                    buildInfoCard(
                      icon: Icons.star,
                      title: "النقاط",
                      value: user.score.toString(),
                    ),
                    GestureDetector(
                      onTap: () {
                        Supabase.instance.client.auth.signOut();
                        Navigator.pushReplacementNamed(
                          context,
                          Login.routeName,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [Colors.red, Colors.redAccent],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.logout, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "تسجيل الخروج",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
