import 'package:flutter/material.dart';

class ProblemInputField extends StatelessWidget{
  const ProblemInputField({super.key});

  @override
  Widget build(BuildContext context) {
    return const       
        TextField(
        minLines: 1,
        maxLines: 5,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration
      (
        hintText: "Describe your home problem...",
        hintMaxLines: 2
        ),
        );
    }
  }