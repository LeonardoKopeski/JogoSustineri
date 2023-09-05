import 'package:flutter/material.dart';

class MenuForm extends StatelessWidget {
  const MenuForm({
    super.key,
    required this.buttonWidth,
  });

  final double buttonWidth;

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    return Expanded(
      child: Center(
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
                keyboardType: TextInputType.number,
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
                  labelText: "Código da sala"
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: (){
                Navigator.of(context).pushNamed("/room/join?id=${controller.text}");
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white
              ),
              icon: const Icon(Icons.door_back_door),
              label: const Text("Entrar",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              )
            ),
            ElevatedButton.icon(
              onPressed: (){
                Navigator.of(context).pushNamed("/room/create");
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, 50),
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                foregroundColor: Colors.white
              ),
              icon: const Icon(Icons.create),
              label: const Text("Criar uma sala")
            )
          ]
        )
      )
    );
  }
}