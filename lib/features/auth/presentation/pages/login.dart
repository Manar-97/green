import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/errors/error_dialog.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_style.dart';
import '../../../admin/presentation/pages/admin_home.dart';
import '../../../user/presentation/pages/home.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_button.dart';
import '../widgets/custom_text_field.dart';
import 'forgot_password.dart';
import 'register.dart';

class Login extends StatefulWidget {
  static const routeName = "login";
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _navigate(AuthState state) {
    if (state is AuthLoggedInAdmin) {
      emailController.clear();
      passwordController.clear();
      Navigator.pushNamedAndRemoveUntil(
        context,
        AdminHome.routeName,
        (route) => false,
      );
    }

    if (state is AuthLoggedInUser) {
      emailController.clear();
      passwordController.clear();
      Navigator.pushNamedAndRemoveUntil(
        context,
        UserHome.routeName,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: AppStyles.gradientBg,
          child: SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  print("STATE = $state");

                  // 🔵 Navigation
                  _navigate(state);

                  // ❌ Errors
                  if (state is AuthError) {
                    final msg = state.message.toLowerCase();

                    if (msg.contains("rate limit")) {
                      showAppDialog(
                        context,
                        title: "Too many requests",
                        message:
                            "Please wait a few minutes before trying again.",
                      );
                    } else {
                      showErrorDialog(
                        context,
                        message: state.message,
                        type: state.type,
                      );
                    }
                  }
                },
                builder: (context, state) {
                  final isLoading =
                      state is AuthLoading || state is AuthGoogleLoading;

                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "مرحبًا بعودتك 👋",
                              style: TextStyle(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 50.h),

                            AppTextField(
                              controller: emailController,
                              label: "الإيميل",
                              icon: Icons.email,
                            ),

                            SizedBox(height: 16.h),

                            AppTextField(
                              controller: passwordController,
                              label: "كلمة المرور",
                              icon: Icons.lock,
                              obscure: obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    ForgotPasswordPage.routeName,
                                  );
                                },
                                child: const Text("نسيت كلمة المرور؟"),
                              ),
                            ),

                            SizedBox(height: 20.h),

                            AuthButton(
                              text: "تسجيل الدخول",
                              loading: isLoading,
                              onPressed: () {
                                FocusScope.of(context).unfocus();

                                context.read<AuthCubit>().login(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );
                              },
                            ),

                            SizedBox(height: 16.h),

                            // Google login
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[100],
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                ),
                                onPressed: () {
                                  context.read<AuthCubit>().loginWithGoogle();
                                },
                                icon: Image.asset('assets/g.png', height: 26.h),
                                label: Text(
                                  "تسجيل باستخدام Gmail",
                                  style: TextStyle(fontSize: 16.sp),
                                ),
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  Register.routeName,
                                );
                              },
                              child: Text(
                                "إنشاء حساب",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ),

                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
