import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/auth_cubit.dart';
import '../../../../core/widgets/app_style.dart';
import '../widgets/auth_button.dart';
import '../widgets/custom_text_field.dart';
import 'login.dart';

class ResetPasswordPage extends StatefulWidget {
  static const routeName = "reset-password";

  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscurePassword1 = true;
  bool obscurePassword2 = true;
  bool isSendingReset = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void submit() {
    final pass = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (pass.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("من فضلك املأ كل الحقول")));
      return;
    }

    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("كلمتا المرور غير متطابقتين")),
      );
      return;
    }

    context.read<AuthCubit>().updatePass(pass);
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
                if (state is AuthSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم تحديث كلمة المرور بنجاح"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Login.routeName,
                    (route) => false,
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
                            "إعادة تعيين كلمة المرور 🔐",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 40.h),

                          AppTextField(
                            controller: passwordController,
                            label: "كلمة المرور الجديدة",
                            icon: Icons.lock,
                            obscure: obscurePassword1,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword1
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(
                                  () => obscurePassword1 = !obscurePassword1,
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 16.h),

                          AppTextField(
                            controller: confirmController,
                            label: "تأكيد كلمة المرور الجديدة",
                            icon: Icons.lock,
                            obscure: obscurePassword2,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword2
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(
                                  () => obscurePassword2 = !obscurePassword2,
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 30.h),

                          AuthButton(
                            text: "تحديث كلمة المرور",
                            loading: state is AuthLoading,
                            onPressed: submit,
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
