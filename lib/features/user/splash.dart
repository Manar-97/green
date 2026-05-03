import 'package:flutter/material.dart';
import '../auth/presentation/cubit/auth_cubit.dart';
import '../auth/presentation/pages/login.dart';
import '../admin/presentation/pages/admin_home.dart';
import '../user/presentation/pages/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Splash extends StatefulWidget {
  static const routeName = "splash";

  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      context.read<AuthCubit>().checkLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoggedInAdmin) {
            Navigator.pushReplacementNamed(context, AdminHome.routeName);
          }

          if (state is AuthLoggedInUser) {
            Navigator.pushReplacementNamed(context, UserHome.routeName);
          }

          if (state is AuthLoggedOut) {
            Navigator.pushReplacementNamed(context, Login.routeName);
          }
        },
        child: Container(
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
                const Icon(Icons.eco, size: 80, color: Colors.white),
                const SizedBox(height: 10),
                const Text(
                  "الطريق الاخضر",
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
