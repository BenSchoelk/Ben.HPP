import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final bool? removeSnackBars;
  final Color? iconColor;
  const CustomBackButton({Key? key, this.removeSnackBars, this.iconColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
