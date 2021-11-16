import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class ExamResultBottomSheetContainer extends StatelessWidget {
  const ExamResultBottomSheetContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          gradient: UiUtils.buildLinerGradient([Theme.of(context).scaffoldBackgroundColor, Theme.of(context).canvasColor], Alignment.topCenter, Alignment.bottomCenter)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.all(10.0),
                alignment: Alignment.centerRight,
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      size: 28.0,
                      color: Theme.of(context).primaryColor,
                    )),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.05),
          ),
        ],
      ),
    );
  }
}
