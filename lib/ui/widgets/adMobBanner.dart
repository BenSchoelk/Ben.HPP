import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobBanner extends StatefulWidget {
  @override
  _AdMobBanner createState() => _AdMobBanner();
}

class _AdMobBanner extends State<AdMobBanner> {
  @override
  void initState() {
    _createAnchoredBanner();
    super.initState();
  }

  @override
  void dispose() {
    _anchoredBanner?.dispose();

    super.dispose();
  }

  String getBannerAdUnitId() {
    if (Platform.isIOS && !kIsWeb) {
      return bannerIosId;
    } else if (Platform.isAndroid && !kIsWeb) {
      return bannerAndroidId;
    }
    return "";
  }

  BannerAd? _anchoredBanner;
  Future<void> _createAnchoredBanner() async {
    /*  final AnchoredAdaptiveBannerAdSize? size =
    await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,500,
    );

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }*/
    final BannerAd banner = BannerAd(
      request: AdRequest(),
      adUnitId: getBannerAdUnitId(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded');
          setState(() {
            _anchoredBanner = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed'),
      ),
      size: AdSize.banner,
    );
    return banner.load();
  }

  @override
  Widget build(BuildContext context) {
    return _anchoredBanner != null
        ? Container(
            width: _anchoredBanner!.size.width.toDouble(),
            height: _anchoredBanner!.size.height.toDouble(),
            child: AdWidget(ad: _anchoredBanner!),
          )
        : Container();

    /*AdmobBanner(
      adUnitId: getBannerAdUnitId(),
      adSize: AdmobBannerSize.BANNER,
    );*/
  }
}
