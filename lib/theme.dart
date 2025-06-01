import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF3101F2);
  static const primaryDark = Color(0xFF23087A);
  static const accent = Color(0xFF8597F7);
  static const bgLight = Color(0xFFF0F4FA);
  static const bgCard = Color(0xFFF1F1F7);
}

class AppTextStyle {
  static const title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryDark,
  );
  static const subtitle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
