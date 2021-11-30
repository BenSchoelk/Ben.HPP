import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';

import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/signInCubit.dart';
import 'package:flutterquiz/ui/screens/auth/fillOtpScreen.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/termsAndCondition.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';

class OtpScreen extends StatefulWidget {
  @override
  _OtpScreen createState() => _OtpScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<SignInCubit>(
              child: OtpScreen(),
              create: (_) => SignInCubit(AuthRepository()),
            ));
  }
}

class _OtpScreen extends State<OtpScreen> {
  TextEditingController phoneController = TextEditingController();
  bool iserrorNumber = false, isErrorName = false;
  String? countrycode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageBackgroundGradientContainer(),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: MediaQuery.of(context).size.width * .05, end: MediaQuery.of(context).size.width * .08),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .07,
                  ),
                  _buildClockAnimation(),
                  _buildEnterNumberTextContainer(),
                  _buildReceiveOtpContainer(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .02,
                  ),
                  showMobileNumber(),
                  showVerify(),
                  TermsAndCondition(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget otpLabelIos() {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: CustomBackButton(
              iconColor: Theme.of(context).primaryColor,
              isShowDialog: false,
            )),
        Expanded(
          flex: 10,
          child: Text(
            AppLocalization.of(context)!.getTranslatedValues('otpVerificationLbl')!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget otpLabel() {
    return Text(
      AppLocalization.of(context)!.getTranslatedValues('otpVerificationLbl')!,
      textAlign: TextAlign.center,
      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildClockAnimation() {
    return Container(
      transformAlignment: Alignment.topCenter,
      child: Lottie.asset("assets/animations/login.json", height: MediaQuery.of(context).size.height * .25, width: MediaQuery.of(context).size.width * 3),
    );
  }

  Widget _buildEnterNumberTextContainer() {
    return Container(
        alignment: AlignmentDirectional.topStart,
        padding: EdgeInsetsDirectional.only(
          top: MediaQuery.of(context).size.height * .03,
          start: 25,
        ),
        child: Text(
          AppLocalization.of(context)!.getTranslatedValues('enterNumberLbl')!,
          style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 22),
        ));
  }

  Widget _buildReceiveOtpContainer() {
    return Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsetsDirectional.only(
          start: 25,
        ),
        child: Text(
          AppLocalization.of(context)!.getTranslatedValues('receiveOtpLbl')!,
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 14),
        ));
  }

  Widget showMobileNumber() {
    return IntlPhoneField(
      decoration: InputDecoration(
        labelText: 'Phone Number',
        border: OutlineInputBorder(
          borderSide: BorderSide(),
        ),
      ),
      onChanged: (phone) {
        print(phone.completeNumber);
      },
      onCountryChanged: (phone) {
        print(phone.countryCode);
      },
    );
    /*
    return Stack(
      alignment: Alignment.center,
      children: [
        
        // Container(
        //   height: MediaQuery.of(context).size.height * 0.06,
        //   width: MediaQuery.of(context).size.width,
        //   decoration: BoxDecoration(
        //     color: Theme.of(context).backgroundColor,
        //     borderRadius: BorderRadius.circular(10.0),
        //   ),
        // ),
        IntlPhoneField(
          showCountryFlag: true,
          controller: phoneController,
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
          initialCountryCode: initialCountryCode,
          decoration: InputDecoration(
            border: InputBorder.none,
            //errorBorder: InputBorder.none,
            // fillColor: Theme.of(context).backgroundColor,
            // filled: true,
            errorText: iserrorNumber ? AppLocalization.of(context)!.getTranslatedValues("validMobMsg") : null,
            hintText: "+91 999-999-999",
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary.withOpacity(0.6)),
            // labelStyle: TextStyle(
            //   fontWeight: FontWeight.w600,
            //   color: Theme.of(context).colorScheme.secondary,
            // ),
            // focusedBorder: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(10.0),
            //   borderSide: BorderSide.none,
            // ),
            // enabledBorder: UnderlineInputBorder(
            //   borderRadius: BorderRadius.circular(10.0),
            //   borderSide: new BorderSide(color: Theme.of(context).backgroundColor),
            // ),
          ),
          onChanged: (phone) {
            //countrycode = phone.countryCode!.toString().replaceFirst("+", "");
            //print(countries.firstWhere((element) => element['code'] == phone.countryISOCode)['max_length']);
            //countries.firstWhere((element) => element['code'] == phone.countryISOCode)['max_length']
          },
          onCountryChanged: (phone) {
            print('Country code changed to: ' + phone.countryCode!);
            countrycode = phone.countryCode!.toString().replaceFirst("+", "");
          },
        ),
        
      ],
    );
    */
  }

  Widget showVerify() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * .07, vertical: MediaQuery.of(context).size.height * .04),
      width: MediaQuery.of(context).size.width,
      child: CupertinoButton(
        borderRadius: BorderRadius.circular(15),
        child: Text(
          AppLocalization.of(context)!.getTranslatedValues("requestOtpLbl")!,
          style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        color: Theme.of(context).primaryColor,
        onPressed: () {},
      ),
    );
  }
}
