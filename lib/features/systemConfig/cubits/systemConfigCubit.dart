//State
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

  final List<String> defaultProfileImages;

  SystemConfigFetchSuccess({required this.systemConfigModel, required this.defaultProfileImages, required this.introSliderImages, required this.supportedLanguages});
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
      if (systemConfig.languageMode == "1") {
        supporatedLanguages = await _systemConfigRepository.getSupportedQuestionLanguages();
      }
      emit(SystemConfigFetchSuccess(
        systemConfigModel: systemConfig,
        defaultProfileImages: defaultProfileImages,
        introSliderImages: introSliderImages,
        supportedLanguages: supporatedLanguages,
      ));
    } catch (e) {
      emit(SystemConfigFetchFailure(e.toString()));
    }
  }

  String getLanguageMode() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.languageMode!;
    }
    return defaultQuestionLanguageId;
  }

  List<SupportedLanguage> getSupportedLanguages() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).supportedLanguages;
    }
    return [];
  }

  SystemConfigModel getSystemDetails() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel;
    }
    return SystemConfigModel();
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
}
