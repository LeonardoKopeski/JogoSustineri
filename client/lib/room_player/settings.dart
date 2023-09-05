import 'package:flutter/material.dart';
import 'package:sustineri/utils/prefs.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
    required this.prefs,
    required this.onSave
  });
  final Prefs prefs;
  final Function onSave;

  static dynamic showExitDialog(BuildContext context){
    return showDialog(
      context: context,
      builder: (context)=>AlertDialog(
        title: const Text("Perai!",
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        content: const SelectableText("Tem certeza que quer sair?"),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pushNamedAndRemoveUntil("/", (_) => false);
            },
            child: const Text("Abandonar essa sala")
          ),
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: const Text("Ficar na sala")
          )
        ],
      )
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool backgroundAnimation;
  late bool simplifiedMode;
  late bool highContrast;
  @override
  void initState() {
    backgroundAnimation = widget.prefs.backgroundAnimation;
    highContrast = widget.prefs.highContrast;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Configurações",
        textAlign: TextAlign.left,
        style: TextStyle(
          fontWeight: FontWeight.bold
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Animação de fundo"),
              Switch(value: backgroundAnimation, onChanged: (value){
                setState(() {
                  backgroundAnimation = value;
                  if(value && highContrast){
                    highContrast = false;
                  }
                });
              })
            ]
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Modo alto contraste"),
              Switch(value: highContrast, onChanged: (value){
                setState(() {
                  highContrast = value;
                  if(value){
                    backgroundAnimation = false;
                  }
                });
              })
            ]
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: (){
            SettingsDialog.showExitDialog(context);
          },
          child: const Text("Sair da sala")
        ),
        TextButton(
          onPressed: (){
            widget.prefs.setMode(highContrast?2:backgroundAnimation?0:1);
            widget.onSave();
            Navigator.of(context).pop();
          },
          child: const Text("Salvar!",
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          )
        )
      ],
    );
  }
}