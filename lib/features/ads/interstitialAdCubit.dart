import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/utils/adIds.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class InterstitialAdState {}

class InterstitialAdInitial extends InterstitialAdState {}

class InterstitialAdLoaded extends InterstitialAdState {}

class InterstitialAdLoadInProgress extends InterstitialAdState {}

class InterstitialAdFailToLoad extends InterstitialAdState {}

class InterstitialAdCubit extends Cubit<InterstitialAdState> {
  InterstitialAdCubit() : super(InterstitialAdInitial());

  InterstitialAd? _interstitialAd;

  InterstitialAd? get interstitialAd => _interstitialAd;

  void createInterstitialAd() {
    emit(InterstitialAdLoadInProgress());
    InterstitialAd.load(
        adUnitId: AdIds.interstitialId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print("InterstitialAd Ad loaded successfully");
            _interstitialAd = ad;
            emit(InterstitialAdLoaded());
          },
          onAdFailedToLoad: (LoadAdError error) {
            print(error);
            emit(InterstitialAdFailToLoad());
          },
        ));
  }

  void showAd() {
    if (state is InterstitialAdLoaded) {
      interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {},
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          ad.dispose();
          createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          createInterstitialAd();
        },
      );
      interstitialAd?.show();
    } else {
      createInterstitialAd();
    }
  }

  @override
  Future<void> close() async {
    _interstitialAd?.dispose();
    return super.close();
  }
}
