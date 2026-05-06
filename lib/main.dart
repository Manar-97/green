import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/di.dart';
import 'core/utils/connectivity_service.dart';
import 'core/utils/deep_link_service.dart';
import 'features/admin/presentation/cubit/admin_cubit.dart';
import 'features/admin/presentation/pages/admin_home.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/forgot_password.dart';
import 'features/auth/presentation/pages/login.dart';
import 'features/auth/presentation/pages/register.dart';
import 'features/auth/presentation/pages/reset_password.dart';
import 'features/user/presentation/cubit/profile_cubit.dart';
import 'features/user/presentation/cubit/request_cubit.dart';
import 'features/user/presentation/pages/about_us.dart';
import 'features/user/presentation/pages/home.dart';
import 'features/user/splash.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> testSupabaseDNS() async {
  try {
    await InternetAddress.lookup('google.com');
    final result = await InternetAddress.lookup(
      'usvpsipxpalvxxkkaqmu.supabase.co',
    );
    print('OK: ${result.first.address}');
  } catch (e) {
    print('DNS FAILED ❌');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://usvpsipxpalvxxkkaqmu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzdnBzaXB4cGFsdnh4a2thcW11Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzcxMTA5NzMsImV4cCI6MjA5MjY4Njk3M30.nqGqJTCYtbYyfBqxcmZAC94nnhpf09B9A2fhtVbCLyo',
  );
  testSupabaseDNS();
  configureDependencies();
  final deepLink = DeepLinkService(navigatorKey);
  await deepLink.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AuthCubit>()),
        BlocProvider(create: (_) => getIt<RequestCubit>()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()),
        BlocProvider(create: (_) => getIt<AdminCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 780),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'الطريق الأخضر',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
              useMaterial3: true,
            ),
            //home: const Splash(), // 🔥 أهم سطر
            routes: {
              Splash.routeName: (_) => const Splash(),
              Login.routeName: (_) => const Login(),
              Register.routeName: (_) => const Register(),
              ResetPasswordPage.routeName: (_) => ResetPasswordPage(),
              ForgotPasswordPage.routeName: (_) => ForgotPasswordPage(),
              UserHome.routeName: (_) => const UserHome(),
              AdminHome.routeName: (_) => const AdminHome(),
              AboutUsPage.routeName: (_) => const AboutUsPage(),
            },
            initialRoute: Splash.routeName,
          );
        },
      ),
    );
  }
}
