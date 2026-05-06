import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../auth/presentation/cubit/auth_cubit.dart';
import '../auth/presentation/pages/login.dart';
import '../admin/presentation/pages/admin_home.dart';
import '../auth/presentation/pages/reset_password.dart';
import '../user/presentation/pages/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Splash extends StatefulWidget {
  static const routeName = "/";

  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      context.read<AuthCubit>().start();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (!mounted || _navigated) return;

        if (state is AuthLoggedInUser) {
          _navigated = true;
          Navigator.pushReplacementNamed(context, UserHome.routeName);
          return;
        }

        if (state is AuthLoggedInAdmin) {
          _navigated = true;
          Navigator.pushReplacementNamed(context, AdminHome.routeName);
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
        debugPrint("CURRENT STATE = $state");
        if (state is AuthLoading) {
          debugPrint('AuthLoading');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFFA5D6A7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco, size: 80.sp, color: Colors.white),
                  SizedBox(height: 10.h),
                  Text(
                    "مشروع الطريق الأخضر لعالم أكثر امانا",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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
