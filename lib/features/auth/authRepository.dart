import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterquiz/features/auth/auhtException.dart';
import 'package:flutterquiz/features/auth/authLocalDataSource.dart';
import 'package:flutterquiz/features/auth/authRemoteDataSource.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';

class AuthRepository {
  static final AuthRepository _authRepository = AuthRepository._internal();
  late AuthLocalDataSource _authLocalDataSource;
  late AuthRemoteDataSource _authRemoteDataSource;

  factory AuthRepository() {
    _authRepository._authLocalDataSource = AuthLocalDataSource();
    _authRepository._authRemoteDataSource = AuthRemoteDataSource();
    return _authRepository;
  }

  AuthRepository._internal();

  //to get auth detials stored in hive box
  getLocalAuthDetails() {
    return {
      "isLogin": _authLocalDataSource.checkIsAuth(),
      "jwtToken": _authLocalDataSource.getJwt(),
      "firebaseId": _authLocalDataSource.getUserFirebaseId(),
      "isNewUser": _authLocalDataSource.getIsNewUser(),
      "authProvider": getAuthProviderFromString(_authLocalDataSource.getAuthType()),
    };
  }

  void setLocalAuthDetails({String? jwtToken, String? firebaseId, String? authType, bool? authStatus, bool? isNewUser}) {
    _authLocalDataSource.changeAuthStatus(authStatus);
    _authLocalDataSource.setJwt(jwtToken);
    _authLocalDataSource.setUserFirebaseId(firebaseId);
    _authLocalDataSource.setAuthType(authType);
    _authLocalDataSource.setIsNewUser(isNewUser);
  }

  //First we signin user with given provider then add user details
  Future<Map<String, dynamic>> signInUser(
    AuthProvider authProvider, {
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authRemoteDataSource.signInUser(authProvider, email: email, password: password);
      final user = result['user'] as User;
      bool isNewUser = result['isNewUser'] as bool;

      if (authProvider == AuthProvider.email) {
        //check if user exist or not
        final isUserExist = await _authRemoteDataSource.isUserExist(user.uid);
        //if user does not exist add in database
        if (!isUserExist) {
          isNewUser = true;
          await _authRemoteDataSource.addUser(
            email: user.email ?? "",
            firebaseId: user.uid,
            mobile: user.phoneNumber ?? "",
            name: user.displayName ?? "",
            type: getAuthTypeString(authProvider),
            profile: user.photoURL ?? "",
          );
        } else {
          print("Update fcm id");
          await _authRemoteDataSource.updateFcmId(firebaseId: user.uid, userLoggingOut: false);
        }
      } else {
        if (isNewUser) {
          await _authRemoteDataSource.addUser(
            email: user.email ?? "",
            firebaseId: user.uid,
            mobile: user.phoneNumber ?? "",
            name: user.displayName ?? "",
            type: getAuthTypeString(authProvider),
            profile: user.photoURL ?? "",
          );
        } else {
          print("Update fcm id");
          await _authRemoteDataSource.updateFcmId(firebaseId: user.uid, userLoggingOut: false);
        }
      }
      //getFcm id update token
      print(user.uid);
      return {
        "user": user,
        "isNewUser": isNewUser,
      };
    } catch (e) {
      signOut(authProvider);
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  //to signUp user
  Future<void> signUpUser(String email, String password) async {
    try {
      await _authRemoteDataSource.signUpUser(email, password);
    } catch (e) {
      signOut(AuthProvider.email);
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  Future<void> signOut(AuthProvider? authProvider) async {
    //remove fcm token when user logout
    _authRemoteDataSource.updateFcmId(firebaseId: _authLocalDataSource.getUserFirebaseId()!, userLoggingOut: true);
    _authRemoteDataSource.signOut(authProvider);
    setLocalAuthDetails(authStatus: false, authType: "", jwtToken: "", firebaseId: "", isNewUser: false);
  }

  String getAuthTypeString(AuthProvider provider) {
    String authType;
    if (provider == AuthProvider.fb) {
      authType = "fb";
    } else if (provider == AuthProvider.gmail) {
      authType = "gmail";
    } else if (provider == AuthProvider.mobile) {
      authType = "mobile";
    } else if (provider == AuthProvider.apple) {
      authType = "apple";
    } else {
      authType = "email";
    }
    return authType;
  }

  //to add user's data to database. This will be in use when authenticating using phoneNumber
  Future<Map<String, dynamic>> addUserData({String? firebaseId, String? type, String? name, String? profile, String? mobile, String? email, String? referCode, String? friendCode}) async {
    try {
      final result = await _authRemoteDataSource.addUser(email: email, firebaseId: firebaseId, friendCode: friendCode, mobile: mobile, name: name, profile: profile, referCode: referCode, type: type);

      return Map.from(result); //
    } catch (e) {
      signOut(AuthProvider.mobile);
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  AuthProvider getAuthProviderFromString(String? value) {
    AuthProvider authProvider;
    if (value == "fb") {
      authProvider = AuthProvider.fb;
    } else if (value == "gmail") {
      authProvider = AuthProvider.gmail;
    } else if (value == "mobile") {
      authProvider = AuthProvider.mobile;
    } else if (value == "apple") {
      authProvider = AuthProvider.apple;
    } else {
      authProvider = AuthProvider.email;
    }
    return authProvider;
  }
}
