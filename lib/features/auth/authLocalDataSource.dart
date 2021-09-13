import 'package:flutterquiz/utils/constants.dart';
import 'package:hive/hive.dart';

//AuthLocalDataSource will communicate with local database (hive)
class AuthLocalDataSource {
  bool? checkIsAuth() {
    return Hive.box(authBox).get(isLoginKey, defaultValue: false);
  }

  String? getJwt() {
    return Hive.box(authBox).get(jwtTokenKey, defaultValue: "");
  }

  String? getAuthType() {
    return Hive.box(authBox).get(authTypeKey, defaultValue: "");
  }

  String? getUserFirebaseId() {
    return Hive.box(authBox).get(firebaseIdBoxKey, defaultValue: "");
  }

  bool? getIsNewUser() {
    return Hive.box(authBox).get(isNewUserKey, defaultValue: false);
  }

  Future<void> setJwt(String? jwtToken) async {
    Hive.box(authBox).put(jwtTokenKey, jwtToken);
  }

  Future<void> setUserFirebaseId(String? userId) async {
    Hive.box(authBox).put(firebaseIdBoxKey, userId);
  }

  Future<void> setAuthType(String? authType) async {
    Hive.box(authBox).put(authTypeKey, authType);
  }

  Future<void> changeAuthStatus(bool? authStatus) async {
    Hive.box(authBox).put(isLoginKey, authStatus);
  }

  Future<void> setIsNewUser(bool? isNewUser) async {
    Hive.box(authBox).put(isNewUserKey, isNewUser);
  }
}
