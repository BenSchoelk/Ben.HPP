import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/ui/styles/theme/appTheme.dart';

class ThemeState {
  final AppTheme appTheme;
  ThemeState(this.appTheme);
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState(AppTheme.Light));

  void changeTheme(AppTheme appTheme) {
    emit(ThemeState(appTheme));
  }
}
