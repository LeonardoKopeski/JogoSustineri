import 'dart:async';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:sustineri/room_player/errors/already_started_room_page.dart';
import 'package:sustineri/room_player/errors/room_close.dart';
import 'package:sustineri/room_player/errors/room_not_found.dart';
import 'package:sustineri/room_player/loading_page.dart';
import 'package:sustineri/room_player/lobby/lobby.dart';
import 'package:sustineri/room_player/question/question_page.dart';
import 'package:sustineri/room_player/settings.dart';
import 'package:sustineri/room_player/username_choose.dart';
import 'package:sustineri/utils/prefs.dart';
import 'package:sustineri/utils/question_model.dart';
import 'package:sustineri/utils/team_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({
    super.key,
    required this.publicId,
    required this.socket,
    required this.navigatorKey
  });
  final Socket socket;
  final GlobalKey<NavigatorState> navigatorKey;
  final int publicId;

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  int team = -1;
  Question? actualQuestion;
  SharedPreferences? sharedPrefs;

  String screen = "LOADING";

  void checkRoom(){
    widget.socket.emitWithAck("search_room", widget.publicId,
      ack: (res){
        if(res != 0){
          setState((){
            screen = "NOT_FOUND";
          });
        }else{
          setState((){
            screen = "CHOOSE_USERNAME";
          });
        }
      }
    );
  }

  void showFullPopUp(String text, IconData iconData, Color color){
    Duration duration = const Duration(seconds: 1);
    showDialog(
      barrierDismissible: false,
      context: widget.navigatorKey.currentContext!,
      builder: (context)=> FutureBuilder(
        future: Future.delayed(duration).then((value) => true),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Navigator.of(context).pop();
          }
          return Material(
            color: Colors.black38,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                Icon(iconData,
                  color: color,
                  size: 150
                ),
                Text(text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    color: color
                  ),
                ),
                const Spacer(),
              ],
            )
          );
        }
      )
    );
  }

  void showSettingsDialog(BuildContext context){
    showDialog(
      context: context,
      builder: (context)=>SettingsDialog(
        prefs: Prefs(sharedPrefs!),
        onSave: (){
          setState(() {});
        }
      )
    );
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((sp){
      sharedPrefs = sp;
      setState(() {});
    });
    
    checkRoom();
    widget.socket.on("room_timeout",(res){
      setState(() {
        screen = "LOBBY";
      });
    });
    widget.socket.on("close_room", (res){
      setState(() {
        screen = "CLOSED";
      });
    });
    widget.socket.on("update_question",(res){
      switch(res["cause"]){
        case 9:
          showFullPopUp(
            "Questão pulada",
            Icons.next_plan,
            const Color(0xffffb703)
          );
          break;
        case 8:
          showFullPopUp(
            "Questão respondida corretamente",
            Icons.check_circle_outline_rounded,
            Colors.green
          );
          break;
      }
      Future.delayed(const Duration(seconds: 1), (){
        setState(() {
          screen = "QUESTION";  
          actualQuestion = Question(
            title: res["questionData"]["title"],
            answerType: res["questionData"]["answerType"],
            id: res["questionData"]["questionId"]
          );
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.socket.off("room_timeout");
    widget.socket.off("close_room");
    widget.socket.off("update_question");
    widget.socket.emit("disconnect_user");
    super.dispose();
  }
  
  Widget buildChild() {
    switch(screen){
      case "LOADING":
        return const LoadingPage();
      case "NOT_FOUND":
        return const RoomNotFoundPage();
      case "CHOOSE_USERNAME":
        return UsernameChoose(
          socket: widget.socket,
          publicId: widget.publicId,
          setScreen: (s){
            setState(() {
              screen = s;
            });
          },
        );
      case "ALREADY_STARTED":
        return const AlreadyStartedRoomPage();
      case "LOBBY":
        return GameLobby(
          socket: widget.socket,
          setTeam: (newTeam){
            setState(() {
              team = newTeam;
            });
          },
          team: team
        );
      case "QUESTION":
        return QuestionPage(
          question: actualQuestion!,
          team: teams[team],
          socket: widget.socket,
          prefs: Prefs(sharedPrefs!),
          showSettingsDialog: showSettingsDialog
        );
      case "CLOSED":
        return const RoomClosePage();
      case "RECONNECTING":
        return const Placeholder();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        SettingsDialog.showExitDialog(context);
        return false;
      },
      child: buildChild()
    );
  }
}