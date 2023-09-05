import 'package:flutter/material.dart';
import 'package:sustineri/room_player/lobby/bottom_bar_button.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    const double iconSize = 60;
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 50, 50, 50),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20)
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Padding(
            padding: EdgeInsets.only(
              top: 12,
            ),
            child: Text("Opções da sala:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20
              ),
            ),
          ),
          Container(
            height: iconSize + 32,
            padding: const EdgeInsets.symmetric(
              horizontal: 8
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                BottomBarButton(
                  onTap: (){},
                  label: "Convidar",
                  size: iconSize,
                  icon: const Icon(Icons.share)
                ),
                BottomBarButton(
                  onTap: (){},
                  label: "Chat",
                  size: iconSize,
                  icon: const Icon(Icons.message)
                ),
                BottomBarButton(
                  onTap: (){
                    Navigator.of(context).pushNamedAndRemoveUntil("/", (_)=> false);
                  },
                  label: "Sair",
                  size: iconSize,
                  icon: const Icon(Icons.door_front_door_outlined)
                )
              ],
            ),
          )
        ],
      )
    );
  }
}