import 'dart:async';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/auth/cubits/signInCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/termsAndCondition.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:lottie/lottie.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:pin_code_fields/pin_code_fields.dart';


class FillOtpScreen extends StatefulWidget {
  final String? mobileNumber, countryCode, name;

  const FillOtpScreen({Key? key, this.mobileNumber, this.countryCode, this.name}) : super(key: key);
  @override
  _FillOtpScreen createState() => _FillOtpScreen();
}

class _FillOtpScreen extends State<FillOtpScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String mobile = "", _verificationId = "", otp = "", signature = "";
  bool _isClickable = false, isCodeSent = false, isloading = false, isErrorOtp = false;
  late OTPTextEditController controller;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late AnimationController buttonController;
  late Timer _timer;
  int _start = 60;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            _isClickable = true;
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  bool otpMobile(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        isErrorOtp = true;
      });
      return false;
    }
    return false;
  }

//to get time to display in text widget
  String getTime() {
    String secondsAsString = _start < 10 ? "0$_start" : _start.toString();
    return "$secondsAsString";
  }

  static Future<bool> checkNet() async {
    bool check = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      check = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      check = true;
    }
    return check;
  }

  @override
  void initState() {
    super.initState();
    getSingature();
    _onVerifyCode();
    startTimer();
    Future.delayed(Duration(seconds: 60)).then((_) {
      _isClickable = true;
    });
    buttonController = new AnimationController(duration: new Duration(milliseconds: 2000), vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    buttonController.dispose();
  }

  Future<void> getSingature() async {
    OTPInteractor.getAppSignature()
    //ignore: avoid_print
        .then((value) => print('signature - $value'));
    controller = OTPTextEditController(
      codeLength: 6,
      //ignore: avoid_print
      onCodeReceive: (code) => print('Your Application receive code............................. - $code'),
    )..startListenUserConsent(
          (code) {
        final exp = RegExp(r'(\d{5})');
        return exp.stringMatch(code ?? '') ?? '';
      },
    );
    /*SmsAutoFill().getAppSignature.then((sign) {
      setState(() {
        signature = sign;
      });
    });
    await SmsAutoFill().listenForCode;*/
  }

  Future<void> checkNetworkOtpResend() async {
    bool checkInternet = await checkNet();
    if (checkInternet) {
      if (_isClickable) {
        _onVerifyCode();
      } else {
        UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues('resendSnackBar')!, context, false);
      }
    } else {
      setState(() {
        checkInternet = false;
      });
      Future.delayed(Duration(seconds: 60)).then((_) async {
        bool checkInternet = await checkNet();
        if (checkInternet) {
          if (_isClickable)
            _onVerifyCode();
          else {
            UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues("resendSnackBar")!, context, false);
          }
        } else {
          await buttonController.reverse();
          UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues("noInterNetSnackBar")!, context, false);
        }
      });
    }
  }

  void _onVerifyCode() async {
    setState(() {
      isCodeSent = true;
    });
    final PhoneVerificationCompleted verificationCompleted = (AuthCredential phoneAuthCredential) {
      _firebaseAuth.signInWithCredential(phoneAuthCredential).then((UserCredential value) {
        User? user = value.user;
        if (user != null) {
        } else {}
      }).catchError((error) {});
    };
    final PhoneVerificationFailed verificationFailed = (FirebaseAuthException authException) {
      setState(() {
        UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues("otpNotMatch")!, context, false);
      });
    };
    final PhoneCodeSent codeSent = (String verificationId, [int? forceResendingToken]) async {
      if (mounted) {
        setState(() {
          _verificationId = verificationId;
        });
      }
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationId) {
      _verificationId = verificationId;
      if (mounted) {
        setState(() {
          _isClickable = true;
          _verificationId = verificationId;
        });
      }
    };
    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+${widget.countryCode}${widget.mobileNumber}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onFormSubmitted() async {
    String code = otp.trim();
    if (code.length == 6) {
      setState(() {
        isloading = true;
      });
      AuthCredential _authCredential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: code);
      _firebaseAuth.signInWithCredential(_authCredential).then((UserCredential value) async {
        String? uid = value.user!.uid;
        String email = value.user!.email ?? "";
        String name = widget.name.toString();
        String profile = value.user!.photoURL ?? "";
        //update auth
        context.read<AuthCubit>().updateAuthDetails(authProvider: AuthProvider.mobile, authStatus: true, firebaseId: uid, isNewUser: false);

        if (value.additionalUserInfo!.isNewUser) {
          context.read<AuthCubit>().authRepository.addUserData(firebaseId: uid, type: "mobile", name: name, profile: profile, mobile: widget.countryCode! + widget.mobileNumber!, email: email, friendCode: "", referCode: "").then((value) {
            if (mounted) {
              context.read<UserDetailsCubit>().fetchUserDetails(uid);
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed(Routes.selectProfile, arguments: true);
              setState(() {
                isloading = false;
              });
            }
          });
        } else {
          context.read<UserDetailsCubit>().fetchUserDetails(uid);
          Navigator.pop(context);
          Navigator.of(context).pushReplacementNamed(Routes.home, arguments: false);
        }
        if (value.user != null) {
          await buttonController.reverse();
        } else {
          await buttonController.reverse();
        }
      }).catchError((error) async {
        if (mounted) {
          UiUtils.setSnackbar(error.toString(), context, false);
          await buttonController.reverse();
        }
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInCubit>(
        create: (_) => SignInCubit(AuthRepository()),
        child: Builder(
            builder: (context) => Scaffold(
                resizeToAvoidBottomInset: true,
                body: Stack(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        PageBackgroundGradientContainer(),
                        SingleChildScrollView(
                          child: showForm(),
                        )
                      ],
                    ),
                  ],
                ))));
  }

  Widget showForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: MediaQuery.of(context).size.width * .05, end: MediaQuery.of(context).size.width * .08),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * .07,
              ),
              otpLabel(),
              SizedBox(
                height: MediaQuery.of(context).size.height * .03,
              ),
              showTopImage(),
              showText(),
              numberText(),
              SizedBox(
                height: MediaQuery.of(context).size.height * .01,
              ),
              showPin(),
              SizedBox(
                height: MediaQuery.of(context).size.height * .08,
              ),
              resendText(),
              showVerify(),
              TermsAndCondition()
            ],
          ),
        ),
      ),
    );
  }

  Widget otpLabel() {
    return Text(
      AppLocalization.of(context)!.getTranslatedValues('otpVerificationLbl')!,
      textAlign: TextAlign.center,
      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget showTopImage() {
    return Container(
      transformAlignment: Alignment.topCenter,
      child: Lottie.asset("assets/animations/login.json", height: MediaQuery.of(context).size.height * .25, width: MediaQuery.of(context).size.width * 3),
    );
  }

  Widget showText() {
    return Container(
        alignment: AlignmentDirectional.topStart,
        padding: EdgeInsetsDirectional.only(
          top: MediaQuery.of(context).size.height * .03,
          start: 25,
        ),
        child: Text(
          AppLocalization.of(context)!.getTranslatedValues('otpSendLbl')!,
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 20),
        ));
  }

  Widget numberText() {
    return Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsetsDirectional.only(
          start: 25,
        ),
        child: Text(
          "+" + widget.countryCode! + " " + widget.mobileNumber!,
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14),
        ));
  }
  Widget showPin() {
    return Padding(
        padding: EdgeInsetsDirectional.only(
          start: MediaQuery.of(context).size.width * .05,
          end: MediaQuery.of(context).size.width * .05,
        ),
        child:PinCodeTextField(keyboardType: TextInputType.number,
          appContext: context,
          length: 6,
          obscureText: false,
          animationType: AnimationType.fade,validator: (val)=>isErrorOtp ? AppLocalization.of(context)!.getTranslatedValues(enterOtp) : null,
          pinTheme: PinTheme(selectedFillColor:Theme.of(context).colorScheme.secondary,
            inactiveColor: Theme.of(context).backgroundColor,
            activeColor:  Theme.of(context).backgroundColor,
            inactiveFillColor:  Theme.of(context).backgroundColor,
            selectedColor:Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(5),
            fieldHeight: 50,
            fieldWidth: 40,
            activeFillColor: Theme.of(context).backgroundColor,
          ),cursorColor:Theme.of(context).backgroundColor,
          animationDuration: Duration(milliseconds: 300),
          //backgroundColor:  Theme.of(context).backgroundColor,
          enableActiveFill: true,
          controller: controller,
          onCompleted: (v) {
            otp = v;
          },
          onChanged: (value) {
            isErrorOtp = controller.text.isEmpty;
            otp = value;
            isloading = false;
          },
        )
    );
  }

  Widget showVerify() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .07, vertical: MediaQuery.of(context).size.height * .04),
        width: MediaQuery.of(context).size.width,
        child: isloading
            ? Center(
                child: CircularProgressContainer(
                  useWhiteLoader: false,
                  heightAndWidth: 50,
                ),
              )
            : CupertinoButton(
                borderRadius: BorderRadius.circular(15),
                child: Text(
                  AppLocalization.of(context)!.getTranslatedValues('submitBtn')!,
                  style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                color: Theme.of(context).primaryColor,
                onPressed: () {
                  if (controller.text.isEmpty) {
                    otpMobile(controller.text);
                  } else {
                    _onFormSubmitted();
                  }
                },
              ));
  }

  Widget resendText() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalization.of(context)!.getTranslatedValues('resetLbl')! + "00:" + getTime() + " ",
            style: TextStyle(fontSize: 10, color: Theme.of(context).primaryColor, fontWeight: FontWeight.normal),
          ),
          _isClickable == true
              ? CupertinoButton(
                  onPressed: () async {
                    setState(() {
                      isloading = false;
                    });
                    await buttonController.reverse();
                    checkNetworkOtpResend();
                  },
                  padding: EdgeInsets.all(0),
                  child: Text(
                    AppLocalization.of(context)!.getTranslatedValues("resendBtn")!,
                    style: TextStyle(fontSize: 10, color: Theme.of(context).primaryColor, decoration: TextDecoration.underline, fontWeight: FontWeight.normal),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
