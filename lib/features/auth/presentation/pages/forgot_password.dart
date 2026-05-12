import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/app_style.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_button.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  static const routeName = "forgot-password";

  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  int cooldown = 0;
  Timer? timer;
  bool _dialogShown = false; // 👈 هنا

  @override
  void initState() {
    super.initState();
    _dialogShown = false; // 👈 reset كل مرة الصفحة تفتح
  }

  @override
  void dispose() {
    emailController.dispose();
    timer?.cancel();
    super.dispose();
  }

  void startCooldown() {
    setState(() => cooldown = 25);

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (cooldown == 0) {
        t.cancel();
      } else {
        setState(() => cooldown--);
      }
    });
  }

  void submit() {
    if (cooldown > 0) return;
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("من فضلك أدخل الإيميل")));
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().sendResetPass(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: AppStyles.gradientBg,
          child: SafeArea(
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthPasswordSent && !_dialogShown) {
                  _dialogShown = true;
                  showAppDialog(
                    context,
                    title: "تم الإرسال",
                    message: "افحص بريدك الإلكتروني 📩",
                    isSuccess: true,
                  );
                }
                if (state is AuthError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                return Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          Text(
                            "نسيت كلمة المرور؟ 🔐",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 40.h),

                          AppTextField(
                            controller: emailController,
                            label: "الإيميل",
                            icon: Icons.email,
                          ),

                          SizedBox(height: 30.h),
                          AuthButton(
                            text: cooldown > 0
                                ? "انتظر $cooldown ثانية"
                                : "إرسال رابط إعادة التعيين",
                            loading: state is AuthLoading,
                            onPressed: cooldown > 0 ? null : submit,
                          ),
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
    );
  }
}
