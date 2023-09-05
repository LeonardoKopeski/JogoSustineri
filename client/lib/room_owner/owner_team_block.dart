import 'package:flutter/material.dart';
import 'package:sustineri/utils/team_model.dart';

class TeamBlock extends StatelessWidget {
  const TeamBlock({
    super.key,
    required this.teamId,
    required this.users,
    required this.started,
    required this.pontuation
  });

  final int teamId;
  final bool started; 
  final int pontuation;
  final List<String> users;

  List<Widget> buildUserTiles(bool inverted){
    List<Widget> results = [];
    Widget icon = Icon(inverted?
      Icons.arrow_right_rounded:
      Icons.arrow_left_rounded,
      color: Colors.white,
      size: 40,
    );
    for(String user in users){
      Widget name = Padding(
        padding: const EdgeInsets.only(
          bottom: 5
        ),
        child: Text(user,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25
          ),
        )
      );

      List<Widget> children = inverted? [icon, name]: [name, icon];

      results.add(Row(
        mainAxisAlignment: inverted?
          MainAxisAlignment.start:
          MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ));
    }

    if(results.isEmpty){
      return [Row(
        mainAxisAlignment: inverted?
          MainAxisAlignment.start:
          MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Padding(
            padding: EdgeInsets.only(
              bottom: 5
            ),
            child: Text("Ninguém (ainda)",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 25
              ),
            )
          )
        ],
      )];
    }

    return results;
  }

  List<Widget> buildStats(){
    return [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(pontuation.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 70
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(
              bottom: 15,
              left: 5
            ),
            child: Text("pontos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20
              ),
            )
          )
        ]
      )
    ];
  }

  List<Widget> buildContent(bool inverted){
    if(started){
      return buildStats();
    }else{
      return buildUserTiles(inverted);
    }
  }

  List<Widget> buildHeader(Team teamData, bool inverted){
    Widget icon = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 10
      ),
      child: Icon(teamData.icon,
        size: 50,
        color: Colors.white,
      ),
    );
    Widget title = Text("Time ${teamData.name}",
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 33
      ),
    );

    if(inverted) return [icon, title];
    return [title, icon];
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    Team teamData = teams[teamId];

    return Container(
      color: teamData.color,
      height: height / 2,
      width: width / 2,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: teamId % 2 == 0?
              MainAxisAlignment.start:
              MainAxisAlignment.end,
            children: buildHeader(teamData, teamId % 2 == 0),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 10
              ),
              child: Column(
                crossAxisAlignment: teamId % 2 == 0?
                  CrossAxisAlignment.start:
                  CrossAxisAlignment.end,
                children: [
                  const Spacer(flex: 1),
                  ...buildContent(teamId % 2 == 0),
                  const Spacer(flex: 2),
                ],
              ),
            )
          )
        ],
      )
    );
  }
}