import 'package:flutter/material.dart';

class BottomBarButton extends StatelessWidget {
  const BottomBarButton({super.key, required this.icon, required this.size, required this.label, required this.onTap});
  final double size;
  final Icon icon;
  final String label;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8
      ),
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(size/2)),
              color: const Color.fromARGB(255, 35, 35, 35),
            ),
            child: IconButton(
              onPressed: ()=>onTap(),
              color: Colors.white,
              icon: icon,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 4
            ),
            child: Text(label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 15
              ),
            ),
          )
        ],
      ),
    );
  }
}