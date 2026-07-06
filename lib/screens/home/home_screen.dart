import 'package:flutter/material.dart';
// import '/core/theme/app_theme.dart';
import 'widgets/greeting_section.dart';
import 'widgets/search_section.dart';
import 'widgets/quick_services_section.dart';
import 'widgets/recent_section.dart';
import '../../core/theme/app_theme.dart';
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    ),
  );
}

class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            GreetingSection(),
            SizedBox(height: 30),
            SearchSection(),
            SizedBox(height: 30),
            QuickServiceSection(),
            SizedBox(height: 30),
            RecentSection(),
          ],
        )))
    );    
  }
}
