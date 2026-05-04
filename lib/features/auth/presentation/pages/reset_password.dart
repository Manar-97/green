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

  bool loading = true;
  bool sessionReady = false;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    _initResetFlow();
  }

  Future<void> _initResetFlow() async {
    print("🚀 RESET FLOW STARTED");
    setState(() => loading = true);

    try {
      final uri = Uri.base;

      print("🔗 FULL URI: $uri");
      print("🔍 QUERY PARAMETERS: ${uri.queryParameters}");
      print("🔍 FRAGMENT: ${uri.fragment}");

      // CASE 1: code flow (PKCE)
      if (uri.queryParameters.containsKey('code')) {
        print("🟢 FOUND CODE PARAMETER");

        final code = uri.queryParameters['code'];
        print("🧾 CODE = $code");

        await Supabase.instance.client.auth.exchangeCodeForSession(
          uri.toString(),
        );

        print("✅ exchangeCodeForSession SUCCESS");
        sessionReady = true;
      }

      // CASE 2: access token flow
      else if (uri.fragment.contains('access_token')) {
        print("🟡 FOUND ACCESS TOKEN IN FRAGMENT");

        await Supabase.instance.client.auth.getSessionFromUrl(uri);

        print("✅ getSessionFromUrl SUCCESS");
        sessionReady = true;
      }

      // CASE 3: existing session
      else if (Supabase.instance.client.auth.currentSession != null) {
        print("🟣 EXISTING SESSION FOUND");

        sessionReady = true;
      }

      // CASE 4: nothing found
      else {
        print("🔴 NO VALID RESET DATA FOUND");
        sessionReady = false;
      }
    } catch (e, stack) {
      print("❌ RESET FLOW ERROR: $e");
      print("📛 STACK TRACE: $stack");

      sessionReady = false;
    }

    setState(() => loading = false);

    print("🏁 RESET FLOW END | sessionReady = $sessionReady");
  }

  Future<void> updatePassword() async {
    print("🔐 UPDATE PASSWORD STARTED");

    FocusScope.of(context).unfocus();

    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    print("🧾 PASSWORD LENGTH: ${password.length}");
    print("🧾 CONFIRM LENGTH: ${confirm.length}");

    if (password != confirm) {
      print("❌ PASSWORDS DO NOT MATCH");
      showAppDialog(context, title: "Error", message: "Passwords not match");
      return;
    }

    setState(() => isUpdating = true);

    try {
      print("🚀 CALLING SUPABASE updateUser");

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: password),
      );

      print("✅ PASSWORD UPDATED SUCCESSFULLY");

      showAppDialog(
        context,
        title: "Success",
        message: "Password updated 🎉",
        isSuccess: true,
      );

      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, Login.routeName);
      });
    } catch (e, stack) {
      print("❌ UPDATE PASSWORD ERROR: $e");
      print("📛 STACK: $stack");

      showAppDialog(context, title: "Error", message: e.toString());
    }

    setState(() => isUpdating = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!sessionReady) {
      return Scaffold(
        appBar: AppBar(title: const Text("Reset Password")),
        body: const Center(
          child: Text("❌ Link expired or invalid", textAlign: TextAlign.center),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password"),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isUpdating ? null : updatePassword,
                child: isUpdating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("تعديل كلمة المرور"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
