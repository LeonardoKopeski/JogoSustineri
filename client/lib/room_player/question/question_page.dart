import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:sustineri/room_player/question/question_card.dart';
import 'package:sustineri/utils/prefs.dart';
import 'package:sustineri/utils/question_model.dart';
import 'package:metaballs/metaballs.dart';
import 'package:sustineri/utils/team_model.dart';

class QuestionPage extends StatelessWidget {
  const QuestionPage({
    super.key,
    required this.question,
    required this.team,
    required this.socket,
    required this.prefs,
    required this.showSettingsDialog
  });
  final Question question;
  final Team team;
  final Socket socket;
  final Prefs prefs;
  final Function showSettingsDialog;

  Widget buildBackground(){
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
      child: Container(
        color: prefs.backgroundColor ?? team.color,
        child: prefs.backgroundAnimation?const Opacity(
          opacity: 0.15,
          child: Metaballs(
            minBallRadius: 25,
            maxBallRadius: 80,
            color: Colors.black
          ),
        ): Container()
      )
    );
  }

  void onWrongAnswer(BuildContext context){
    Duration duration = const Duration(seconds: 1);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context)=> FutureBuilder(
        future: Future.delayed(duration).then((value) => true),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Navigator.of(context).pop();
          }
          return const Material(
            color: Colors.black38,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                Icon(Icons.cancel_outlined,
                  color: Color(0xffd90429),
                  size: 150
                ),
                Text("Resposta errada...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    color: Color(0xffd90429)
                  ),
                ),
                Spacer(),
              ],
            )
          );
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double aspectRatio = MediaQuery.of(context).size.aspectRatio;
    double cardSizeMultiplier = 0.65;
    double cardSize = aspectRatio > 1.75?
      height*cardSizeMultiplier:
      width*cardSizeMultiplier;
    return Scaffold(
      body:Stack(
        children:[
          buildBackground(),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: cardSize,
                minWidth: cardSize*1.75,
                maxWidth: cardSize*1.75
              ),
              child: QuestionCard(
                prefs: prefs,
                questionData: question,
                skip: (){
                  socket.emitWithAck("skip_question", null,
                    ack: (_){}
                  );
                },
                send: (String response){
                  socket.emitWithAck("send_answer", response,
                    ack: (res){
                      print(res);
                      if(res == 6){
                        onWrongAnswer(context);
                      }
                    }
                  );
                },
              ),
            )
          ),
          Positioned(
            child: IconButton(
              onPressed: (){showSettingsDialog(context);},
              iconSize: cardSize / 10,
              color: prefs.oppositeBackgroundColor,
              icon: const Icon(Icons.settings)
            ),
          ),
        ],
      )
    );
  }
}