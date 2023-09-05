import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs{
  Prefs(SharedPreferences sp){
    mode = sp.getInt("mode")??0;
    sharedPreferences = sp;
  }

  late int mode;
  late SharedPreferences sharedPreferences;

  Color? get backgroundColor{
    if(mode == 2){
      return Colors.black;
    }
    return null;
  }

  Color get oppositeBackgroundColor{
    if(mode == 2){
      return Colors.white;
    }
    return Colors.black;
  }

  bool get backgroundAnimation{
    return mode == 0;
  }

  bool get highContrast{
    return mode == 2;
  }

  void setMode(value){
    sharedPreferences.setInt("mode", value);
    mode = value;
  }
}