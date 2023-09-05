import 'package:flutter/material.dart';

class Team{
  const Team({required this.name, required this.color, required this.icon});
  final String name;
  final Color color;
  final IconData icon;
}

const List<Team> teams = [
  Team(
    color: Color(0xffd90429),
    name: "Vermelho",
    icon: Icons.local_fire_department
  ),
  Team(
    color: Colors.green,
    name: "Verde",
    icon: Icons.eco
  ),
  Team(
    color: Color(0xffffb703),
    name: "Amarelo",
    icon: Icons.sunny
  ),
  Team(
    color: Colors.indigo,
    name: "Azul",
    icon: Icons.water_drop
  )
];