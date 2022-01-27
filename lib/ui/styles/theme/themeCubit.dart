import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hpp/features/settings/settingsLocalDataSource.dart';
import 'package:hpp/ui/styles/theme/appTheme.dart';
import 'package:hpp/utils/uiUtils.dart';

class ThemeState {
  final AppTheme appTheme;
  ThemeState(this.appTheme);
}

class ThemeCubit extends Cubit<ThemeState> {
  SettingsLocalDataSource settingsLocalDataSource;
  ThemeCubit(this.settingsLocalDataSource) : super(ThemeState(UiUtils.getAppThemeFromLabel(settingsLocalDataSource.theme())));

  void changeTheme(AppTheme appTheme) {
    settingsLocalDataSource.setTheme(UiUtils.getThemeLabelFromAppTheme(appTheme));
    emit(ThemeState(appTheme));
  }
}
