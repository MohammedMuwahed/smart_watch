import 'package:flutter/material.dart';
import '../utils/index.dart';

class AppTheme {
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );
}
