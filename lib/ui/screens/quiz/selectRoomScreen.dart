import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/ui/styles/colors.dart';

class SelectRoomScreen extends StatefulWidget{
  @override
  _SelectRoomScreen createState() => _SelectRoomScreen();

}
class _SelectRoomScreen extends State<SelectRoomScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          showForm(),
        ],
      ),
    );
  }
  Widget showForm() {
    return Form(
        child: Column(
            children: <Widget>[
              Expanded(flex: 3,
                  child: back()),
              Expanded(flex: 10,
                  child: level())
            ]
        )
    );
  }
  Widget back(){
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 50,start: 20,end: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            child:Image.asset("assets/images/back.png"),
            onTap: (){
              Navigator.pop(context);
            },
          ),
          GestureDetector(
            child:Image.asset("assets/images/language.png",),
            onTap: (){
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
  Widget level() {
    return Column(
      children: <Widget>[
      Container(
          height: 90,margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                  color:accentColor,
                  width: 5.0
              )
          ),
          child:ListTile(
            leading: Image.asset("assets/images/onevone.png"),
            trailing: IconButton(icon: Icon(Icons.navigate_next_outlined,size: 40,color: primaryColor,), onPressed: () {  },),
            tileColor: accentColor,
            title: Text(AppLocalization.of(context)!.getTranslatedValues("oneToOneLbl")!),
          )
      ),
        Container(height: 90,margin: EdgeInsets.all(15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                    color:accentColor,
                    width: 5.0
                )
            ),
            child:ListTile(
              leading: Image.asset("assets/images/private_room.png"),
              trailing: IconButton(icon: Icon(Icons.navigate_next_outlined,size: 40,color: primaryColor,), onPressed: () {  },),
            tileColor: accentColor,
            title: Text(AppLocalization.of(context)!.getTranslatedValues("privateRoomLbl")!),
          )

    ),
        Container(height: 90,margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
          color:accentColor,
          width: 5.0
          )),
              child: ListTile(
                leading: Image.asset("assets/images/public_room.png"),
                trailing: IconButton(icon: Icon(Icons.navigate_next_outlined,size: 40,color: primaryColor,), onPressed: () {  },),
                tileColor: accentColor,
                title: Text(AppLocalization.of(context)!.getTranslatedValues("publicRoomLbl")!),
              )
        )
      ]
    );
  }
}