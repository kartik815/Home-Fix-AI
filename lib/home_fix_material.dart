import 'package:flutter/material.dart';

class HomeFixMaterial extends StatelessWidget{
  const HomeFixMaterial({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
    onTap: () {
      FocusScope.of(context).unfocus();
    },
    child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 27, 27, 27),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [Text("Home Fix", style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        fontSize: 50.0,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        height: 5.0,
                          ),
                        ),
                        TextField(
                          autofocus: false,
                          style: TextStyle(color: const Color.fromRGBO(255, 255, 255, 1)), 
                          decoration: InputDecoration(
                            hintText: "Enter your problem: ", 
                            hintStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.report_problem_outlined),
                            prefixIconColor: Colors.red,
                            hintFadeDuration: Duration(seconds: 4),
                            fillColor: const Color.fromARGB(241, 72, 72, 72),
                            filled: true,
                            // focusedBorder: OutlineInputBorder(borderSide: 
                            focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: const Color.fromARGB(255, 255, 0, 0), width: 5), 
                            borderRadius: BorderRadius.circular(40.0)
                            ), 
                            enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white, width: 5), 
                            borderRadius: BorderRadius.circular(40.0)
                            ), 
                            ),
                            ),
                      ],
            )
          ),
        ),
      );
    }



}   