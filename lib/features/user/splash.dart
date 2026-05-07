import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../admin/presentation/pages/admin_home.dart';
import '../auth/presentation/cubit/auth_cubit.dart';
import '../auth/presentation/pages/login.dart';
import '../auth/presentation/pages/reset_password.dart';
import '../user/presentation/pages/home.dart';

class Splash extends StatefulWidget {
  static const routeName = "/";

  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  bool _navigated = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: .7,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return;

      context.read<AuthCubit>().start();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (!mounted || _navigated) return;

        if (state is AuthLoggedInUser) {
          _navigated = true;
          Navigator.pushNamedAndRemoveUntil(
            context,
            UserHome.routeName,
            (route) => false,
          );
          return;
        }

        if (state is AuthLoggedInAdmin) {
          _navigated = true;
          Navigator.pushNamedAndRemoveUntil(
            context,
            AdminHome.routeName,
            (route) => false,
          );
          return;
        }

        if (state is AuthLoggedOut) {
          _navigated = true;
          Navigator.pushReplacementNamed(context, Login.routeName);
          return;
        }

        if (state is AuthPasswordRecovery) {
          _navigated = true;
          Navigator.pushReplacementNamed(context, ResetPasswordPage.routeName);
          return;
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F3D2E),
                  Color(0xFF1B5E20),
                  Color(0xFF66BB6A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                /// circles background
                Positioned(
                  top: -60.h,
                  right: -40.w,
                  child: Container(
                    height: 180.h,
                    width: 180.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Positioned(
                  bottom: -70.h,
                  left: -50.w,
                  child: Container(
                    height: 220.h,
                    width: 220.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.06),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                /// content
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /// logo container
                          Container(
                            padding: EdgeInsets.all(22.r),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.12),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(.2),
                                width: 2.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.15),
                                  blurRadius: 20.r,
                                  offset: Offset(0, 10.h),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.eco_rounded,
                              size: 90.sp,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 35.h),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 25.w),
                            child: Text(
                              "مشروع الطريق الأخضر\nلعالم أكثر أمانًا",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                height: 1.5.h,
                                letterSpacing: 1.w,
                              ),
                            ),
                          ),

                          SizedBox(height: 45.h),

                          if (state is AuthLoading)
                            Column(
                              children: [
                                SizedBox(
                                  width: 28.w,
                                  height: 28.h,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 14.h),
                                Text(
                                  "جاري التحميل...",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
