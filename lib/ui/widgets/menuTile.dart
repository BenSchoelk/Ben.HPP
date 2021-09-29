import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_fake.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class MenuTile extends StatelessWidget {
  final String title;
  final bool isSvgIcon;
  final String? leadingIcon;
  final IconData? leadingIconData;
  final VoidCallback onTap;

  const MenuTile({
    Key? key,
    required this.isSvgIcon,
    required this.onTap,
    required this.title,
    this.leadingIcon,
    this.leadingIconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45.0,
      child: ListTile(
        onTap: onTap,
        title: Text(
          AppLocalization.of(context)!.getTranslatedValues(title)!,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        leading: Container(
          width: 60,
          transform: Matrix4.identity()..scale(0.45),
          transformAlignment: Alignment.center,
          child: isSvgIcon ? SvgPicture.asset(UiUtils.getImagePath(leadingIcon!)) : Icon(leadingIconData),
        ),
      ),
    );
  }
}
