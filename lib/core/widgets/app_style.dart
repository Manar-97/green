import 'package:flutter/material.dart';

class AppStyles {
  static final gradientBg = const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFE8F5E9), Colors.white],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  static final inputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.all(16),
  );

  static final buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    padding: const EdgeInsets.symmetric(vertical: 14),
  );
}