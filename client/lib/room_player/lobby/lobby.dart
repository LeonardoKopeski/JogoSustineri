import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:sustineri/room_player/lobby/bottom_bar.dart';
import 'package:sustineri/utils/team_model.dart';

class GameLobby extends StatelessWidget {
  const GameLobby({super.key, required this.socket, required this.setTeam, required this.team});
  final Socket socket;
  final Function setTeam;
  final int team;

  void performTeamChange(int teamId){
    socket.emitWithAck("update_team", teamId,
      ack: (_){
        setTeam(teamId);
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(//TODO
      body: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 130,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      color: teams[0].color,
                      height: (height - 130) / 2,
                      width: width / 2,
                      child: IconButton(
                        icon: Icon(teams[0].icon),
                        iconSize: 50,
                        color: Colors.white,
                        onPressed: ()=>performTeamChange(0),
                      ),
                    ),
                    Container(
                      color: teams[1].color,
                      height: (height - 130) / 2,
                      width: width / 2,
                      child: IconButton(
                        icon: Icon(teams[1].icon),
                        iconSize: 50,
                        color: Colors.white,
                        onPressed: ()=>performTeamChange(1),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      color: teams[2].color,
                      height: (height - 130) / 2,
                      width: width / 2,
                      child: IconButton(
                        icon: Icon(teams[2].icon),
                        iconSize: 50,
                        color: Colors.white,
                        onPressed: ()=>performTeamChange(2),
                      ),
                    ),
                    Container(
                      color: teams[3].color,
                      height: (height - 130) / 2,
                      width: width / 2,
                      child: IconButton(
                        icon: Icon(teams[3].icon),
                        iconSize: 50,
                        color: Colors.white,
                        onPressed: ()=>performTeamChange(3),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Positioned(
            top: (height - 200) / 2,
            height: 70,
            left: 60,
            right: 60,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Seu time: ",
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                  Text(team == -1? "Nenhum": teams[team].name,
                    style: TextStyle(
                      fontSize: 25,
                      color: team == -1? Colors.black: teams[team].color,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              )
            ),
          ),
          const Positioned(
            bottom: 0,
            height: 150,
            left: 0,
            right: 0,
            child: BottomBar()
          )
        ],
      )
    );
  }
}