import 'package:flutter/material.dart';

class AlreadyStartedRoomPage extends StatelessWidget {
  const AlreadyStartedRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tarde demais...",
                    style: TextStyle(
                      color: Color(0xffffb703),
                      fontWeight: FontWeight.w900,
                      fontSize: 35
                    ),
                  ),
                  Text("Essa sala já começou a jogar!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30
                    ),
                  )
                ]
              ),
            ),
            ElevatedButton(
              onPressed: (){
                Navigator.pushNamedAndRemoveUntil(context, "/", (_)=> false);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white
              ),
              child: const Text("Voltar"),
            )
            
          ]
        ),
      ),
    );
  }
}