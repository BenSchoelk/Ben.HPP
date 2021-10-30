import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';

//TODO : decide how many coins shoud give to user once user sees ad successfully
class WatchRewardAdDialog extends StatelessWidget {
  final Function onTapYesButton;
  const WatchRewardAdDialog({Key? key, required this.onTapYesButton}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: Text(
          AppLocalization.of(context)!.getTranslatedValues("showAdsLbl")!,
        ),
        actions: [
          CupertinoButton(
            onPressed: () {
              onTapYesButton();
              Navigator.pop(context);
            },
            child: Text(
              AppLocalization.of(context)!.getTranslatedValues("yesBtn")!,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          CupertinoButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              AppLocalization.of(context)!.getTranslatedValues("noBtn")!,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ]);
  }
}
