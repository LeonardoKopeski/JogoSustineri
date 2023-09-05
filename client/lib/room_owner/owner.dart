import 'package:socket_io_client/socket_io_client.dart';
import 'package:sustineri/room_owner/owner_center_info.dart';
import 'package:sustineri/room_owner/owner_team_block.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/material.dart';
import 'package:sustineri/utils/team_model.dart';

class OwnerPage extends StatefulWidget {
  const OwnerPage({
    super.key,
    required this.socket,
    required this.navigatorKey
  });
  final Socket socket;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<OwnerPage> createState() => _OwnerPageState();
}

class _OwnerPageState extends State<OwnerPage> {
  String? publicID;
  bool started = false;
  List<int> pontuations = [0,0,0,0];
  List<List<Map<String, String>>> users = [[], [], [], [], []];

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

  void showPopUp(String title, String content){
    showDialog(
      context: widget.navigatorKey.currentContext!,
      builder: (context)=>AlertDialog(
        title: Text(title,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        content: SelectableText(content),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: const Text("Ok")
          )
        ],
      )
    );
  }

  void startRoomAck(res){
    if(res[0] == 0){
      setState(() {
        started = true;
      });
    }else{
      showPopUp("Erro desconhecido", "Identificador: room.start.ack - ${res["status"]}");
    }
  }

  void startListeners(){
    widget.socket.on("new_viewer", (res){
      users[0].add({
        "name": res["name"],
        "id": res["userID"]
      });
      setState(() {});
    });
    widget.socket.on("user_out", (res){
      for(var i = 0; i <= 4; i++){
        users[i].removeWhere((elm)=>elm["id"] == res["userID"]);
      }
      setState(() {});
    });
    widget.socket.on("update_user_team", (res){
      for(var i = 0; i <= 4; i++){
        Map? user = users[i].where((elm)=>elm["id"] == res["userID"]).firstOrNull;
        if(user != null){
          users[i].removeWhere((elm)=>elm["id"] == res["userID"]);
          users[res["team"]].add({
            "name": user["name"],
            "id": user["id"]
          });
        }
      }
      
      setState(() {});
    });
    widget.socket.on("update_pontuation", (res){
      num diff = res["pontuation"] - pontuations[res["team"]];
      Team team = teams[res["team"]];
      showFullPopUp(
        "O time ${team.name} ${diff>0?"ganhou":"perdeu"} ${diff.abs()} pontos!",
        team.icon,
        team.color
      );
      pontuations[res["team"]] = res["pontuation"];
      setState(() {});
    });
  }

  @override
  void initState(){
    super.initState();

    widget.socket.emitWithAck("create_room", null,
      ack: (res){
        html.window.history.pushState({}, "", "/room/join?id=${res[1]["publicID"]}");
        setState(() {
          publicID = res[1]["publicID"];
        });
      }
    );
    
    widget.socket.onConnect((data){
      startListeners();
    });
  }

  @override
  void dispose(){
    widget.socket.off("server.uncaught_exception_warning");
    widget.socket.off("new_viewer");
    widget.socket.off("user_out");
    widget.socket.off("update_user_team");
    widget.socket.off("update_pontuation");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  children: [
                    TeamBlock(
                      teamId: 0,
                      users: users[1].map((x)=>x["name"] ?? "").toList(),
                      pontuation: pontuations[0],
                      started: started
                    ),
                    TeamBlock(
                      teamId: 1,
                      users: users[2].map((x)=>x["name"] ?? "").toList(),
                      pontuation: pontuations[1],
                      started: started
                    ),
                  ],
                ),
                Row(
                  children: [
                    TeamBlock(
                      teamId: 2,
                      users: users[3].map((x)=>x["name"] ?? "").toList(),
                      pontuation: pontuations[2],
                      started: started
                    ),
                    TeamBlock(
                      teamId: 3,
                      users: users[4].map((x)=>x["name"] ?? "").toList(),
                      pontuation: pontuations[3],
                      started: started
                    ),
                  ],
                )
              ],
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 40
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 35, 35, 35),
                borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: CenterInfo(
                started: started,
                publicID: publicID,
                onTimeOut: (){
                  setState(() {
                    started = false;
                  });
                },
                startRoom: (){
                  widget.socket.emitWithAck("start_room", null,
                    ack: startRoomAck
                  );
                },
              )
            ),
          ),
        ],
      )
    );
  }
}