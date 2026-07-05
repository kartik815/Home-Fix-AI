import 'package:flutter/material.dart';
// import 'package:test_app/home_fix_material.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: HomeScreen(),
    );
  }
}
