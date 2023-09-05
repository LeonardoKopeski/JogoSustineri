import 'package:flutter/material.dart';
import 'package:sustineri/utils/prefs.dart';
import 'package:sustineri/utils/question_model.dart';

class QuestionCard extends StatelessWidget {
  QuestionCard({
    super.key,
    required this.prefs,
    required this.questionData,
    required this.skip,
    required this.send
  });
  final Question questionData;
  final Prefs prefs;
  final void Function() skip;
  final void Function(String) send;

  final TextEditingController controller = TextEditingController();

  Widget buildHeader(double sizeUnit){
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: sizeUnit,
        horizontal: 2*sizeUnit
      ),
      width: 30*sizeUnit,
      child: FittedBox(
        child: Text("Questão ${questionData.id}",
          textAlign: TextAlign.start,
          style: TextStyle(
            color: prefs.highContrast? Colors.black: Colors.black26,
          ),
        ),
      )
    );
  }

  Widget buildTitle(double sizeUnit){
    RegExp splitRegex = RegExp(r'\s|(?<=\*)|(?=\*)');
    List<String> words = questionData.title.split(splitRegex);
    List<Widget> children = words.map((x){
      if(x == "*") return buildTextField(sizeUnit);
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sizeUnit*0.5,
          vertical: sizeUnit*1.0 + 10
        ),
        child: Text(x,
          style: TextStyle(
            fontWeight: prefs.highContrast?FontWeight.bold: FontWeight.normal,
            fontSize: sizeUnit*4,
          ),
        ),
      );
    }).toList();
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 1.3*sizeUnit,
        horizontal: 2*sizeUnit
      ),
      width: 100*sizeUnit,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: children,
      )
    );
  }

  Widget buildTextField(double sizeUnit){
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizeUnit
      ),
      width: sizeUnit*30,
      child: TextField(
        controller: controller,
        autofocus: true,
        style: TextStyle(
          fontSize: sizeUnit*4
        ),
      ),
    );
  }

  Widget buildActionButtons(double sizeUnit){
    return SizedBox(
      width: sizeUnit*100,
      height: sizeUnit*15,
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (){
                  skip();
                  controller.clear();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(prefs.highContrast?Icons.next_plan:Icons.next_plan_outlined,
                      color: prefs.highContrast?Colors.black:Colors.red,
                      size: sizeUnit * 4.5,
                    ),
                    Text("Pular",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: sizeUnit * 2
                      ),
                    )
                  ],
                ),
              )
            ),
          ),
          const VerticalDivider(
            color: Colors.black,
            width: 1,
          ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: (){
                  send(controller.text.toString());
                  controller.clear();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded,
                      color: prefs.highContrast?Colors.black:Colors.green,
                      size: sizeUnit * 4.5,
                    ),
                    Text("Enviar",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: sizeUnit * 2
                      ),
                    )
                  ],
                ),
              )
            ),
          ),
        ]
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: LayoutBuilder(builder: (context, constraints){
        double sizeUnit = constraints.maxWidth/100;
        return SizedBox.shrink(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildHeader(sizeUnit),
              buildTitle(sizeUnit),
              const Spacer(),
              Divider(
                height: 1,
                color: prefs.highContrast? Colors.transparent: Colors.black,
              ),
              buildActionButtons(sizeUnit)
            ],
          ),
        );
      })
    );
  }
}