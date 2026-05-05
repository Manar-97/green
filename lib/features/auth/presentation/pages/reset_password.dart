import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/widgets/app_dialog.dart';
import '../pages/login.dart';

class ResetPassword extends StatefulWidget {
  static const routeName = "reset-password";

  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  late final AppLinks _appLinks;
  StreamSubscription? _sub;

  bool loading = true;
  bool sessionReady = false;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();

    _appLinks = AppLinks();
    _initDeepLink();
  }

  // ===================== DEEP LINK =====================
  Future<void> _initDeepLink() async {
    try {
      final initialUri = await _appLinks.getInitialLink();

      if (initialUri != null) {
        _handleUri(initialUri);
      }

      _sub = _appLinks.uriLinkStream.listen((uri) {
        if (uri != null) {
          _handleUri(uri);
        }
      });
    } catch (e) {
      print("❌ DeepLink error: $e");
      setState(() {
        loading = false;
        sessionReady = false;
      });
    }
  }

  Future<void> _handleUri(Uri uri) async {
    print("🔗 RESET LINK: $uri");

    try {
      if (uri.host == "reset-callback") {
        await Supabase.instance.client.auth.exchangeCodeForSession(
          uri.toString(),
        );

        setState(() {
          sessionReady = true;
          loading = false;
        });
      } else {
        setState(() {
          sessionReady = false;
          loading = false;
        });
      }
    } catch (e) {
      print("❌ RESET ERROR: $e");

      setState(() {
        sessionReady = false;
        loading = false;
      });
    }
  }

  // ===================== UPDATE PASSWORD =====================
  Future<void> updatePassword() async {
    FocusScope.of(context).unfocus();

    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      showAppDialog(context, title: "Error", message: "Fields required");
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
  void dispose() {
    _sub?.cancel();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!sessionReady) {
      return Scaffold(
        appBar: AppBar(title: const Text("Reset Password")),
        body: const Center(
          child: Text(
            "❌ Invalid or expired reset link",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: EdgeInsets.all(16.h),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password"),
            ),
            SizedBox(height: 24.h),

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
