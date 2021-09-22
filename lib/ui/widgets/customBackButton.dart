import 'package:flutter/material.dart';

import 'exitGameDailog.dart';

class CustomBackButton extends StatelessWidget {
  final bool? removeSnackBars;
  final Color? iconColor;
  final Color? bgColor;
  final bool? isShowDialog;
  const CustomBackButton({Key? key, this.removeSnackBars, this.iconColor, this.isShowDialog, this.bgColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isShowDialog!
        ? RawMaterialButton(
            onPressed: () {
              print("1");
              showDialog(context: context, builder: (_) => ExitGameDailog());
            },
            constraints: BoxConstraints(),
            elevation: 2.0,
            fillColor: bgColor,
            child: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).primaryColor,
              size: 15.0,
            ),
            padding: EdgeInsets.all(9.0),
            shape: CircleBorder(),
          )
        : InkWell(
            onTap: () {
              Navigator.pop(context);
              if (removeSnackBars != null && removeSnackBars!) {
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
              }
            },
            child: Container(
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: iconColor,
                )));
  }
}
