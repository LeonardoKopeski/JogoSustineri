import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sustineri/home/form.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  Widget buildHorizontal(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double buttonWidth = min(width - height - 100, 500);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          Image.asset("assets/logo.jpg",
            height: height,
            width: height,
            fit: BoxFit.fitHeight,
          ),
          MenuForm(
            buttonWidth: buttonWidth
          )
        ],
      )
    );
  }

  Widget buildVertical(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double buttonWidth = width - 100;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Image.asset("assets/logo.jpg",
            width: min(width / 2, height - 200),
            fit: BoxFit.fitWidth,
          ),
          MenuForm(
            buttonWidth: buttonWidth
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    double aspectRatio = MediaQuery.of(context).size.aspectRatio;

    if(aspectRatio > 1.75){
      return buildHorizontal(context);
    }else{
      return buildVertical(context);
    }
  }
}