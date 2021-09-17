import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/settings/settingsLocalDataSource.dart';
import 'package:flutterquiz/utils/constants.dart';

class AppLocalizationState {
  final Locale language;
  AppLocalizationState(this.language);
}

class AppLocalizationCubit extends Cubit<AppLocalizationState> {
  final SettingsLocalDataSource settingsLocalDataSource;
  AppLocalizationCubit(this.settingsLocalDataSource) : super(AppLocalizationState(Locale(defaultLanguageCode))) {
    changeLanguage(Locale(settingsLocalDataSource.languageCode()!));
  }

  void changeLanguage(Locale language) {
    settingsLocalDataSource.setLanguageCode(language.languageCode);

    emit(AppLocalizationState(language));
  }
}
