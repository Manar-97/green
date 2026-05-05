import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../auth/presentation/cubit/auth_cubit.dart';
import '../auth/presentation/pages/login.dart';
import '../admin/presentation/pages/admin_home.dart';
import '../user/presentation/pages/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Splash extends StatefulWidget {
  static const routeName = "/";

  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  late final AppLinks appLinks;
  StreamSubscription? _sub;

  bool _isDeepLinkHandled = false;

  @override
  void initState() {
    super.initState();

    final cubit = context.read<AuthCubit>();

    cubit.checkLogin();
    cubit.start();

    appLinks = AppLinks();

    _sub = appLinks.uriLinkStream.listen((uri) {
      if (_isDeepLinkHandled) return;

      if (uri == null) return;

      // 🔥 RESET PASSWORD FLOW
      if (uri.host == "reset-callback") {
        _isDeepLinkHandled = true;

        Navigator.pushReplacementNamed(
          context,
          "/reset-password",
          arguments: uri.queryParameters['code'],
        );

        return;
      }

      // 🔥 LOGIN CALLBACK
      if (uri.host == "login-callback") {
        _isDeepLinkHandled = true;
        cubit.checkLogin();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) return;

        if (state is AuthLoggedInUser) {
          Navigator.pushReplacementNamed(context, UserHome.routeName);
        }

        if (state is AuthLoggedInAdmin) {
          Navigator.pushReplacementNamed(context, AdminHome.routeName);
        }

        if (state is AuthLoggedOut) {
          Navigator.pushReplacementNamed(context, Login.routeName);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFFA5D6A7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              return Center(
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
              );
            },
          ),
        ),
      ),
    );
  }
}
