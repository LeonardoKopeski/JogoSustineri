import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:sustineri/home/home.dart';
import 'package:sustineri/room_owner/owner.dart';
import 'package:sustineri/room_player/player.dart';
import 'package:sustineri/utils/constants.dart';

void main() {
  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late Socket socket;
  String? socketId;
  int? lastRoomId;

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Route onGenerateRoute(RouteSettings settings){
    Uri uri = Uri.parse(settings.name??"/");
    switch(uri.path){
      case "/":
        return MaterialPageRoute(
          builder: (context)=>const HomePage()
        );
      case "/room/join":
        lastRoomId = int.tryParse(uri.queryParameters["id"]??"")??0;
        return MaterialPageRoute(
          builder: (context)=>PlayerPage(
            publicId: lastRoomId!,
            socket: socket,
            navigatorKey: navigatorKey
          )
        );
      case "/room/create":
        return MaterialPageRoute(
          builder: (context)=>OwnerPage(
            socket: socket,
            navigatorKey: navigatorKey
          )
        );
      default:
        return MaterialPageRoute(
          builder: (context)=>Text("not found ${uri.path} ${uri.queryParameters}")//TODO
        );
    }
  }

  @override
  void initState() {
    super.initState();
    socket = io(serverURL,  <String, dynamic>{
      'transports': ['websocket']
    });
    socket.onConnect((_){
      socketId = socket.id;
    });
    socket.onDisconnect((reason){
      print("Server down");
    });
    socket.onReconnect((data){
      socket.emitWithAck("reconnect_user", [socketId, lastRoomId ?? 0],
        ack: (response){
          print(response);
        }
      );
    });
  }

  @override
  void dispose(){
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sustineri',
      theme: ThemeData(
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      initialRoute: "/",
      onGenerateRoute: onGenerateRoute,
    );
  }
}