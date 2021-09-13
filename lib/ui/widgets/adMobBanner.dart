import 'dart:io';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterquiz/utils/constants.dart';

class AdMobBanner extends StatefulWidget {
  @override
  _AdMobBanner createState() => _AdMobBanner();
}

class _AdMobBanner extends State<AdMobBanner> {
  String getBannerAdUnitId() {
    if (Platform.isIOS && !kIsWeb) {
      return bannerIosId;
    } else if (Platform.isAndroid && !kIsWeb) {
      return bannerAndroidId;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return AdmobBanner(
      adUnitId: getBannerAdUnitId(),
      adSize: AdmobBannerSize.BANNER,
    );
  }
}
