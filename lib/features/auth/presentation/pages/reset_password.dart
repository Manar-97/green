import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/widgets/app_dialog.dart';
import 'login.dart';

class ResetPassword extends StatefulWidget {
  static const routeName = "reset-password";

  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool loading = false;
  bool sessionReady = false;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _handleDeepLink();
  }

  /// 🔥 أهم جزء: تفعيل session من الرابط
  Future<void> _handleDeepLink() async {
    try {
      final uri = Uri.base;

      final hasRecovery =
          uri.fragment.contains('access_token') ||
          uri.queryParameters.containsKey('access_token') ||
          uri.toString().contains('type=recovery');

      if (hasRecovery) {
        await Supabase.instance.client.auth.exchangeCodeForSession(
          uri.toString(),
        );

        if (mounted) {
          setState(() {
            sessionReady = true;
          });
        }
      } else {
        // لو مفيش token → يعني دخل الصفحة غلط
        setState(() {
          sessionReady = false;
        });
      }
    } catch (e) {
      debugPrint("Deep link error: $e");
      setState(() {
        sessionReady = false;
      });
    }
  }

  Future<void> updatePassword() async {
    if (isUpdating) return;

    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (!sessionReady) {
      showAppDialog(
        context,
        title: "Error",
        message: "Invalid or expired reset session",
      );
      return;
    }

    if (password.isEmpty || confirm.isEmpty) {
      showAppDialog(context, title: "Error", message: "Fill all fields");
      return;
    }

    if (password.length < 6) {
      showAppDialog(
        context,
        title: "Weak Password",
        message: "Password must be at least 6 characters",
      );
      return;
    }

    if (password != confirm) {
      showAppDialog(context, title: "Error", message: "Passwords not match");
      return;
    }

    setState(() => isUpdating = true);

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );

      showAppDialog(
        context,
        title: "Success",
        message: "Password updated 🎉",
        isSuccess: true,
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, Login.routeName);
      });
    } catch (e) {
      showAppDialog(context, title: "Error", message: e.toString());
    }

    setState(() => isUpdating = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!sessionReady) {
      return Scaffold(
        appBar: AppBar(title: const Text("Reset Password")),
        body: const Center(
          child: Text(
            "Invalid or expired reset link ❌",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SizedBox(height: 40.h),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),

            SizedBox(height: 20.h),

            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password"),
            ),

            SizedBox(height: 30.h),

            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: isUpdating ? null : updatePassword,
                child: isUpdating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
