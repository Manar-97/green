import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/errors/error_dialog.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_style.dart';
import '../cubit/auth_cubit.dart';
import 'login.dart';

class Register extends StatefulWidget {
  static const routeName = "register";
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscure1 = true;
  bool obscure2 = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
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
                  if (state is AuthSuccess) {
                    showAppDialog(
                      context,
                      title: "مرحبا",
                      message: "تم تسجيل الدخول",
                      isSuccess: true,
                    );
                  } else if (state is AuthError) {
                    showErrorDialog(
                      context,
                      message: state.message,
                      type: state.type,
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
                              "إنشاء حساب جديد 🌱",
                              style: TextStyle(
                                fontSize: 24,
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
                              obscureText: obscure1,
                              decoration: AppStyles.inputDecoration.copyWith(
                                labelText: "كلمة المرور",
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscure1
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() => obscure1 = !obscure1);
                                  },
                                ),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            TextField(
                              controller: confirmController,
                              obscureText: obscure2,
                              decoration: AppStyles.inputDecoration.copyWith(
                                labelText: "تأكيد كلمة المرور",
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscure2
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() => obscure2 = !obscure2);
                                  },
                                ),
                              ),
                            ),

                            SizedBox(height: 25.h),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: AppStyles.buttonStyle,
                                onPressed: () {
                                  FocusScope.of(context).unfocus();

                                  context.read<AuthCubit>().register(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                  );
                                },
                                child: const Text("تسجيل"),
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, Login.routeName);
                              },
                              child: const Text("لدي حساب"),
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
