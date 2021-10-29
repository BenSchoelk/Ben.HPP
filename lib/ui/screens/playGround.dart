import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/adMobBanner.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PlayGround extends StatefulWidget {
  PlayGround({Key? key}) : super(key: key);

  @override
  _PlayGroundState createState() => _PlayGroundState();
}

class _PlayGroundState extends State<PlayGround> {
  InterstitialAd? interstitialAd;

  @override
  void initState() {
    initInterstitialAd();
    super.initState();
  }

  void initInterstitialAd() {
    InterstitialAd.load(
        adUnitId: "ca-app-pub-3940256099942544/1033173712",
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print("Interstital Ad loaded successfully");
            interstitialAd = ad;
            showInterstitialAd();
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            //
          },
        ));
  }

  void showInterstitialAd() {
    if (interstitialAd == null) {
      return;
    }

    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
      },
    );
    interstitialAd!.show();
    interstitialAd = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(onPressed: () {}),
      body: Center(
        child: AdMobBanner(),
      ),
    );
  }
}


/*
  void _showInterstitialAd() {
    print("Show add");
    if (interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded');
      return;
    }
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
        print('$ad onAdDismissedFullScreenContent');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    interstitialAd!.show();
    interstitialAd = null;
  }


*/