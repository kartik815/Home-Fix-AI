import 'package:flutter/material.dart';
import 'problem_input_field.dart';

class SearchSection extends StatelessWidget{
  const SearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [Expanded(child: 
      ProblemInputField()
    ),
    SizedBox(width: 10,)
    ,
    IconButton(onPressed: () {}, icon: Icon(Icons.mic))
        ]
    ,); 
    }
  }