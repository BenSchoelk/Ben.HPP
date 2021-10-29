import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterquiz/utils/adIds.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
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

  BannerAd? _anchoredBanner;
  Future<void> _createAnchoredBanner() async {
    final BannerAd banner = BannerAd(
      request: AdRequest(),
      adUnitId: AdIds.bannerId,
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
            decoration: BoxDecoration(
              gradient: UiUtils.buildLinerGradient([Theme.of(context).scaffoldBackgroundColor, Theme.of(context).canvasColor], Alignment.topCenter, Alignment.bottomCenter),
            ),
            width: MediaQuery.of(context).size.width,
            height: _anchoredBanner!.size.height.toDouble(),
            child: AdWidget(ad: _anchoredBanner!),
          )
        : Container();
  }
}
