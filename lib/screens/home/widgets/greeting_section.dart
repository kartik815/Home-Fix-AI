import 'package:flutter/material.dart';

class   GreetingSection extends StatelessWidget{
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(children: [
      Row(children: [Text("👋 "), Text("Good Evening,")]),
      SizedBox(height: 20),
      Text("Kartik"),
      SizedBox(height: 20),
      Text("What's happening at home today?"),
      
    ],);
    }
  }