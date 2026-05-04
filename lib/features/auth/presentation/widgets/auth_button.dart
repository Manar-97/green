import 'package:flutter/material.dart';

import '../../../../core/widgets/app_style.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool loading;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: AppStyles.buttonStyle,
        onPressed: loading ? null : onPressed,
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text),
      ),
    );
  }
}
