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
        body: BlocBuilder<ProfileCubit, ProfileState>(
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
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.withOpacity(0.1),
                          ),
                          child: const CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.green,
                            ),
                          ),
                        ),

                        SizedBox(height: 5.h),

                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 10.h),

                        // 📦 Info Cards (Expanded علشان تملى المساحة)
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
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

                              SizedBox(height: 10.h),

                              // 🟢 About Us
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AboutUsPage.routeName,
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.green,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "من نحن",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // 🔴 Logout
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
                                    vertical: 10,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: const LinearGradient(
                                      colors: [Colors.red, Colors.redAccent],
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
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
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
