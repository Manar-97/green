import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/errors/error_dialog.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_style.dart';
import '../../../admin/presentation/pages/admin_home.dart';
import '../../../user/presentation/pages/home.dart';
import '../cubit/auth_cubit.dart';
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
  bool isSendingReset = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
                  if (state is AuthLoggedInAdmin) {
                    Navigator.pushReplacementNamed(
                      context,
                      AdminHome.routeName,
                    );
                  }
                  if (state is AuthLoggedInUser) {
                    print("STATE = $state");
                    Navigator.pushReplacementNamed(context, UserHome.routeName);
                  }
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
                  if (state is AuthPasswordSent) {
                    showAppDialog(
                      context,
                      title: "Success",
                      message: "Check your email 📩",
                      isSuccess: true,
                    );
                  }
                },
                builder: (context, state) {
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
                            const Text(
                              "مرحبًا بعودتك 👋",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 50.h),

                            TextField(
                              controller: emailController,
                              decoration: AppStyles.inputDecoration.copyWith(
                                labelText: "الإيميل",
                                prefixIcon: const Icon(Icons.email),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            TextField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              decoration: AppStyles.inputDecoration.copyWith(
                                labelText: "كلمة المرور",
                                prefixIcon: const Icon(Icons.lock),
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
                            ),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: isSendingReset
                                    ? () {
                                        showAppDialog(
                                          context,
                                          title: "انتظر",
                                          message: "حاول بعد دقيقة مرة أخرى",
                                        );
                                      }
                                    : () {
                                        FocusScope.of(context).unfocus();
                                        showAppDialog(
                                          context,
                                          title: "Reset Password",
                                          message: "Check your email 📩",
                                        );
                                      },
                                child: const Text("نسيت كلمة المرور؟"),
                              ),
                            ),

                            SizedBox(height: 20.h),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: AppStyles.buttonStyle,
                                onPressed: state is AuthLoading
                                    ? null
                                    : () {
                                        FocusScope.of(context).unfocus();

                                        context.read<AuthCubit>().login(
                                          emailController.text.trim(),
                                          passwordController.text.trim(),
                                        );
                                      },
                                child: state is AuthLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text("تسجيل الدخول"),
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  Register.routeName,
                                );
                              },
                              child: const Text("إنشاء حساب"),
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
