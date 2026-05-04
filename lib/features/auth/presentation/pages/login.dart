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

  void showForgotPasswordSheet(BuildContext context, AuthCubit cubit) {
    final emailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // مهم جدًا
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16, // 👈 الكيبورد
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Reset Password",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Enter your email",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      cubit.forgotPassword(emailController.text.trim());
                    },
                    child: const Text("Send Reset Link"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                                  setState(
                                    () => obscurePassword = !obscurePassword,
                                  );
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {
                                  showForgotPasswordSheet(
                                    context,
                                    context.read<AuthCubit>(),
                                  );
                                },
                                child: const Text("نسيت كلمة المرور؟"),
                              ),
                            ),

                            SizedBox(height: 20.h),
                            AuthButton(
                              text: "تسجيل الدخول",
                              loading: state is AuthLoading,
                              onPressed: () {
                                FocusScope.of(
                                  context,
                                ).unfocus(); // يقفل الكيبورد

                                context.read<AuthCubit>().login(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );

                                emailController.clear(); // تنظيف
                                passwordController.clear(); // تنظيف
                              },
                            ),
                            SizedBox(height: 16.h),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                ),
                                onPressed: () {
                                  context.read<AuthCubit>().loginWithGoogle();
                                },
                                icon: Image.network(
                                  'https://cdn-icons-png.flaticon.com/512/281/281764.png',
                                  height: 24,
                                ),
                                label: const Text("تسجيل باستخدام Gmail"),
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
