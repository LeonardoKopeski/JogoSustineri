import 'dart:math';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

class UsernameChoose extends StatelessWidget {
  UsernameChoose({
    super.key,
    required this.socket,
    required this.publicId,
    required this.setScreen  
  });
  final Socket socket;
  final int publicId;
  final Function setScreen;
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double buttonWidth = min(width - 100, 500);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(
                bottom: 25
              ),
              width: buttonWidth - 6,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 3,
                      color: Colors.white
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 3,
                      color: Colors.white
                    )
                  ),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w200,
                    color: Colors.white
                  ),
                  labelText: "Escolha um nome de usuário"
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: (){
                socket.emitWithAck("join_room", [publicId.toString(), controller.text],
                  ack: (res){
                    if(res == 0){
                      setScreen("LOBBY");
                    }else if(res == 4){
                      setScreen("ALREADY_STARTED");
                    }else if(res == 1){
                      setScreen("NOT_FOUND");
                    }
                  }
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white
              ),
              icon: const Icon(Icons.arrow_circle_right_outlined),
              label: const Text("Continuar",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              )
            ),
            ElevatedButton.icon(
              onPressed: (){
                Navigator.of(context).pushNamedAndRemoveUntil("/", (_)=> false);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, 50),
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                foregroundColor: Colors.white
              ),
              icon: const Icon(Icons.keyboard_return),
              label: const Text("Voltar")
            )
          ]
        )
      )
    );
  }
}