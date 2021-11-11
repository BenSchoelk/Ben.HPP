//State
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/systemConfig/model/supportedQuestionLanguage.dart';
import 'package:flutterquiz/features/systemConfig/model/systemConfigModel.dart';
import 'package:flutterquiz/features/systemConfig/systemConfigRepository.dart';
import 'package:flutterquiz/utils/constants.dart';

abstract class SystemConfigState {}

class SystemConfigIntial extends SystemConfigState {}

class SystemConfigFetchInProgress extends SystemConfigState {}

class SystemConfigFetchSuccess extends SystemConfigState {
  final List<String> introSliderImages;
  final SystemConfigModel systemConfigModel;
  final List<SupportedLanguage> supportedLanguages;
  final List<String> emojis;

  final List<String> defaultProfileImages;

  SystemConfigFetchSuccess({required this.systemConfigModel, required this.defaultProfileImages, required this.introSliderImages, required this.supportedLanguages, required this.emojis});
}

class SystemConfigFetchFailure extends SystemConfigState {
  final String errorCode;

  SystemConfigFetchFailure(this.errorCode);
}

class SystemConfigCubit extends Cubit<SystemConfigState> {
  final SystemConfigRepository _systemConfigRepository;
  SystemConfigCubit(this._systemConfigRepository) : super(SystemConfigIntial());

  void getSystemConfig() async {
    emit(SystemConfigFetchInProgress());
    try {
      List<SupportedLanguage> supporatedLanguages = [];
      final systemConfig = await _systemConfigRepository.getSystemConfig();
      final introSliderImages = await _systemConfigRepository.getImagesFromFile("assets/files/introSliderImages.json");
      final defaultProfileImages = await _systemConfigRepository.getImagesFromFile("assets/files/defaultProfileImages.json");
      final emojis = await _systemConfigRepository.getImagesFromFile("assets/files/emojis.json");

      if (systemConfig.languageMode == "1") {
        supporatedLanguages = await _systemConfigRepository.getSupportedQuestionLanguages();
      }
      emit(SystemConfigFetchSuccess(
        systemConfigModel: systemConfig,
        defaultProfileImages: defaultProfileImages,
        introSliderImages: introSliderImages,
        supportedLanguages: supporatedLanguages,
        emojis: emojis,
      ));
    } catch (e) {
      emit(SystemConfigFetchFailure(e.toString()));
    }
  }

  String getLanguageMode() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.languageMode;
    }
    return defaultQuestionLanguageId;
  }

  List<SupportedLanguage> getSupportedLanguages() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).supportedLanguages;
    }
    return [];
  }

  List<String> getEmojis() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).emojis;
    }
    return [];
  }

  SystemConfigModel getSystemDetails() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel;
    }
    return SystemConfigModel.fromJson({});
  }

  String? getIsCategoryEnableForBattle() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.battleRandomCategoryMode;
    }
    return "0";
  }

  String? getIsCategoryEnableForGroupBattle() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.battleGroupCategoryMode;
    }
    return "0";
  }

  String? getShowCorrectAnswerMode() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.answerMode;
    }
    return "0";
  }

  String? getIsDailyQuizAvailable() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.dailyQuizMode;
    }
    return "0";
  }

  String? getIsContestAvailable() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.contestMode;
    }
    return "0";
  }

  String? getIsFunNLearnAvailable() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.funNLearnMode;
    }
    return "0";
  }

  String? getIsGuessTheWordAvailable() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.guessTheWordMode;
    }
    return "0";
  }

  String? getIsAudioQuestionAvailable() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.audioQuestionMode;
    }
    return "0";
  }

  String getAppVersion() {
    if (state is SystemConfigFetchSuccess) {
      if (Platform.isIOS) {
        return (state as SystemConfigFetchSuccess).systemConfigModel.appVersionIos;
      }
      return (state as SystemConfigFetchSuccess).systemConfigModel.appVersion;
    }
    return "1.0.0+1";
  }

  String getAppUrl() {
    if (state is SystemConfigFetchSuccess) {
      if (Platform.isAndroid) {
        return (state as SystemConfigFetchSuccess).systemConfigModel.appLink;
      }
      if (Platform.isIOS) {
        return (state as SystemConfigFetchSuccess).systemConfigModel.iosAppLink;
      }
    }
    return "";
  }

  String faceBookBannerId() {
    if (state is SystemConfigFetchSuccess) {
      if (Platform.isAndroid) {
        return "$fbBannerAndInterstitialAdPrefix${(state as SystemConfigFetchSuccess).systemConfigModel.androidFbBannerId}";
      }
      if (Platform.isIOS) {
        return "$fbBannerAndInterstitialAdPrefix${(state as SystemConfigFetchSuccess).systemConfigModel.iosFbBannerId}";
      }
    }
    return "";
  }

  String faceBookInterstitialAdId() {
    if (state is SystemConfigFetchSuccess) {
      if (Platform.isAndroid) {
        return "$fbBannerAndInterstitialAdPrefix${(state as SystemConfigFetchSuccess).systemConfigModel.androidFbInterstitialId}";
      }
      if (Platform.isIOS) {
        return "$fbBannerAndInterstitialAdPrefix${(state as SystemConfigFetchSuccess).systemConfigModel.iosFbInterstitialId}";
      }
    }

    return "";
  }

  String faceBookRewardedAdId() {
    if (state is SystemConfigFetchSuccess) {
      if (Platform.isAndroid) {
        return "$fbRewardedAdPrefix${(state as SystemConfigFetchSuccess).systemConfigModel.androidFbRewardedId}";
      }
      if (Platform.isIOS) {
        return "$fbRewardedAdPrefix${(state as SystemConfigFetchSuccess).systemConfigModel.iosFbRewardedId}";
      }
    }
    return "";
  }

  String googleBannerId() {
    if (state is SystemConfigFetchSuccess) {
      if (Platform.isAndroid) {
        return (state as SystemConfigFetchSuccess).systemConfigModel.androidBannerId;
      }
      if (Platform.isIOS) {
        return (state as SystemConfigFetchSuccess).systemConfigModel.iosBannerId;
      }
    }
    return "";
  }

  String googleInterstitialAdId() {
    if (state is SystemConfigFetchSuccess) {
      if (Platform.isAndroid) {
        return (state as SystemConfigFetchSuccess).systemConfigModel.androidInterstitialId;
      }
      if (Platform.isIOS) {
        return (state as SystemConfigFetchSuccess).systemConfigModel.iosInterstitialId;
      }
    }
    return "";
  }

  String googleRewardedAdId() {
    if (state is SystemConfigFetchSuccess) {
      if (Platform.isAndroid) {
        return (state as SystemConfigFetchSuccess).systemConfigModel.androidRewardedId;
      }
      if (Platform.isIOS) {
        return (state as SystemConfigFetchSuccess).systemConfigModel.iosRewardedId;
      }
    }
    return "";
  }

  bool isForceUpdateEnable() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.forceUpdate == "1";
    }
    return false;
  }

  bool isAdsEnable() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.adsEnabled == "1";
    }
    return false;
  }

  bool isGoogleAdEnable() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.adsType == "1";
    }
    return false;
  }
}
