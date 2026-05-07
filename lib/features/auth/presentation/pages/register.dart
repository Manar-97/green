import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/errors/error_dialog.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_style.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_button.dart';
import '../widgets/custom_text_field.dart';
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
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          showAppDialog(
            context,
            title: "تم إنشاء الحساب",
            message: "افحص الإيميل 📩",
            isSuccess: true,
          );
        }

        if (state is AuthError) {
          showErrorDialog(context, message: state.message, type: state.type);
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoading;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Container(
              decoration: AppStyles.gradientBg,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "إنشاء حساب جديد 🌱",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 40.h),

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
                        obscure: obscure1,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure1 ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => obscure1 = !obscure1),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      AppTextField(
                        controller: confirmController,
                        label: "تأكيد كلمة المرور",
                        icon: Icons.lock,
                        obscure: obscure2,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure2 ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => obscure2 = !obscure2),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      AuthButton(
                        text: "تسجيل",
                        loading: loading,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (passwordController.text !=
                              confirmController.text) {
                            showAppDialog(
                              context,
                              title: "خطأ",
                              message: "كلمات المرور غير متطابقة",
                            );
                            return;
                          }
                          context.read<AuthCubit>().register(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          );
                          emailController.clear();
                          passwordController.clear();
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            Login.routeName,
                          );
                        },
                        child: Text(
                          "لدي حساب",
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
