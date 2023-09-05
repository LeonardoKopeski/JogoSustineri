import 'dart:async';

import 'package:flutter/material.dart';

class CenterInfo extends StatefulWidget {
  const CenterInfo({
    super.key,
    required this.started,
    required this.publicID,
    required this.startRoom,
    required this.onTimeOut
  });
  final bool started;
  final String? publicID;
  final Function onTimeOut;
  final Function startRoom;

  @override
  State<CenterInfo> createState() => _CenterInfoState();
}

class _CenterInfoState extends State<CenterInfo> {
  int minutes = 10;
  int seconds = 0;
  bool timeRunning = false;
  Timer? timer;

  String getTime(){
    String secondsStr = seconds < 10? "0$seconds":"$seconds";
    return "$minutes:$secondsStr";
  }

  @override
  void dispose(){
    if(timer != null){
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(!widget.started){
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("ID da sala: ${widget.publicID ?? "Carregando..."}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20
            ),
            child: ElevatedButton.icon(
              onPressed: (){
                widget.startRoom();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(200, 50)
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text("Começar") 
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 20
            ),
            child: ElevatedButton.icon(
              onPressed: (){
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white24,
                foregroundColor: Colors.white,
                minimumSize: const Size(200, 50)
              ),
              icon: const Icon(Icons.door_front_door),
              label: const Text("Sair") 
            ),
          )
        ],
      );
    }
    if(!timeRunning) {
      timeRunning = true;
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if(seconds == 0 && minutes == 0){
          timer.cancel();
          minutes = 10;
          widget.onTimeOut();
          return;
        }
        if(seconds == 0){
          seconds = 59;
          minutes--;
        }else{
          seconds--;
        }
        setState(() {});
      });
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(getTime(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 100,
            fontWeight: FontWeight.bold
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            top: 20
          ),
          child: ElevatedButton.icon(
            onPressed: (){
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
              minimumSize: const Size(160, 40)
            ),
            icon: const Icon(Icons.door_front_door),
            label: const Text("Sair") 
          ),
        )
      ],
    );
  }
}