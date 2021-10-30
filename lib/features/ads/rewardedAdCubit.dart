import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/utils/adIds.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

//TODO : add reason for ad load failure and shows to user
abstract class RewardedAdState {}

class RewardedAdInitial extends RewardedAdState {}

class RewardedAdLoaded extends RewardedAdState {}

class RewardedAdLoadInProgress extends RewardedAdState {}

class RewardedAdFailure extends RewardedAdState {}

class RewardedAdCubit extends Cubit<RewardedAdState> {
  RewardedAdCubit() : super(RewardedAdInitial());

  RewardedAd? _rewardedAd;

  RewardedAd? get rewardedAd => _rewardedAd;

  void createRewardedAd() {
    emit(RewardedAdLoadInProgress());
    RewardedAd.load(
      adUnitId: AdIds.rewardedId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(onAdFailedToLoad: (error) {
        print("Rewarded ad failed to load");
        emit(RewardedAdFailure());
      }, onAdLoaded: (ad) {
        _rewardedAd = ad;
        print("Rewarded ad loaded successfully");
        emit(RewardedAdLoaded());
      }),
    );
  }

  void showAd({required Function onAdDismissedCallback}) {
    if (state is RewardedAdLoaded) {
      _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          onAdDismissedCallback();
          createRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('$ad onAdFailedToShowFullScreenContent: $error');
          ad.dispose();
          //need to show this reason to user
          emit(RewardedAdFailure());
          createRewardedAd();
        },
      );
      rewardedAd?.show(onUserEarnedReward: (_, __) => {});
    } else if (state is RewardedAdFailure) {
      createRewardedAd();
    }
  }

  @override
  Future<void> close() async {
    _rewardedAd?.dispose();
    return super.close();
  }
}
