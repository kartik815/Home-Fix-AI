import 'package:flutter/material.dart';

class   GreetingSection extends StatelessWidget{
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    const String username = "Kartik";
    return const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        children: [
          Text("👋 "),
         SizedBox(width: 8,),
          Text("Good Evening,")
          ]
          ),
      SizedBox(height: 8),
      Text(username),
      SizedBox(height: 4 ),
      Text("What's happening at home today?"),
      
    ],
    );
    }
  }