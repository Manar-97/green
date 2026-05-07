import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:green/features/user/presentation/pages/about_us.dart';
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
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.all(10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.r,
            offset: Offset(0, 4),
          ),
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
                    fontWeight: FontWeight.w500,
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
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final user = state.user;
                    if (user == null) {
                      return const Center(child: Text("لا يوجد بيانات"));
                    }

                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: SafeArea(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey[100],
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 5.h),
                            child: Column(
                              children: [
                                SizedBox(height: 5.h),

                                // 👤 Avatar + Name
                                Container(
                                  padding: EdgeInsets.all(6.h),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green.withOpacity(0.1),
                                  ),
                                  child: CircleAvatar(
                                    radius: 40.r,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 40.sp,
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

                                SizedBox(height: 20.h),

                                // 📦 Info Cards (Expanded علشان تملى المساحة)
                                Expanded(
                                  child: ListView(
                                    children: [
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 🟢 About Us
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AboutUsPage.routeName);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10.h),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    color: Colors.green,
                  ),
                  child: Center(
                    child: Text(
                      "من نحن",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                ),
              ),

              // 🔴 Logout
              GestureDetector(
                onTap: () {
                  Supabase.instance.client.auth.signOut();
                  Navigator.pushReplacementNamed(context, Login.routeName);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10.h),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.redAccent],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.white),
                      SizedBox(width: 8.w),
                      Text(
                        "تسجيل الخروج",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
