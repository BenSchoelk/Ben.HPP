import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/wallet/cubits/paymentRequestCubit.dart';
import 'package:flutterquiz/features/wallet/walletRepository.dart';
import 'package:flutterquiz/ui/screens/wallet/widgets/redeemAmountRequestBottomSheetContainer.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletScreen extends StatefulWidget {
  WalletScreen({Key? key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => MultiBlocProvider(providers: [
              //
              BlocProvider<PaymentRequestCubit>(
                  create: (_) => PaymentRequestCubit(WalletRepository())),
            ], child: WalletScreen()));
  }
}

class _WalletScreenState extends State<WalletScreen> {
  int _currentSelectedTab = 1;

  TextEditingController? redeemableAmountTextEditingController;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      //
      redeemableAmountTextEditingController = TextEditingController(
        text: _calculateAmountPerCoins(
                userCoins:
                    int.parse(context.read<UserDetailsCubit>().getCoins()!),
                amount: 1,
                coins: 100)
            .toString(),
      );

      setState(() {});
    });
  }

  //
  double _calculateAmountPerCoins(
      {required int userCoins, required int amount, required int coins}) {
    return (amount * userCoins) / coins;
  }

  int _calculateDeductedCoinsForRedeemableAmount(
      {required double userEnteredAmount,
      required int amount,
      required int coins}) {
    return (coins * userEnteredAmount) ~/ amount;
  }

  @override
  void dispose() {
    redeemableAmountTextEditingController?.dispose();
    super.dispose();
  }

  void showRedeemRequestAmountBottomSheet(
      {required int deductedCoins, required double redeemableAmount}) {
    //
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        elevation: 5.0,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (_) {
          return RedeemAmountRequestBottomSheetContainer(
            paymentRequestCubit: context.read<PaymentRequestCubit>(),
            deductedCoins: deductedCoins,
            redeemableAmount: redeemableAmount,
          );
        });
  }

  Widget _buildTabContainer(String title, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentSelectedTab = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context)
                .primaryColor
                .withOpacity(_currentSelectedTab == index ? 1.0 : 0.5),
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: Stack(
        children: [
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 25.0, bottom: 37.5),
              child: CustomBackButton(
                removeSnackBars: false,
                iconColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Padding(
              padding: EdgeInsetsDirectional.only(bottom: 37.5),
              child: Text(
                  AppLocalization.of(context)!.getTranslatedValues(walletKey)!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 21.0, color: Theme.of(context).primaryColor)),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabContainer(
                    AppLocalization.of(context)!
                        .getTranslatedValues(requestKey)!,
                    1),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                ),
                _buildTabContainer(
                    AppLocalization.of(context)!
                        .getTranslatedValues(transactionKey)!,
                    2),
              ],
            ),
          ),
        ],
      ),
      height:
          MediaQuery.of(context).size.height * (UiUtils.appBarHeightPercentage),
      decoration: BoxDecoration(
          boxShadow: [UiUtils.buildAppbarShadow()],
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0))),
    );
  }

  Widget _buildWalletRequestNoteContainer(String note) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 7.5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(3)),
          ),
          SizedBox(
            width: 10.0,
          ),
          Flexible(
              child: Text(
            note,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              height: 1.2,
            ),
          ))
        ],
      ),
    );
  }

  Widget _buildRequestContainer() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height *
            (UiUtils.appBarHeightPercentage + 0.05),
        left: MediaQuery.of(context).size.width * (0.05),
        right: MediaQuery.of(context).size.width * (0.05),
      ),
      child: Column(
        children: [
          //
          Container(
            alignment: Alignment.center,
            child: Text(
              "Redeemable Amount",
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20.0),
            ),
          ),

          Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 30.0,
                ),
                Text("\$",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 30.0)),
                SizedBox(
                  width: 5.0,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * (0.2),
                  child: TextField(
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 30.0),
                    keyboardType: TextInputType.number,
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: "00",
                        hintStyle: TextStyle(
                          fontSize: 25.0,
                          color: Theme.of(context).primaryColor,
                        )),
                    controller: redeemableAmountTextEditingController,
                  ),
                ),
              ],
            ),
          ),

          Container(
            alignment: Alignment.center,
            child: Text(
              "Total Coins",
              style: TextStyle(
                  color: Theme.of(context).primaryColor.withOpacity(0.75),
                  fontSize: 20.0),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              "${context.read<UserDetailsCubit>().getCoins()}",
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20.0),
            ),
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height * (0.025),
          ),
          CustomRoundedButton(
            widthPercentage: 0.4,
            backgroundColor: Theme.of(context).primaryColor,
            buttonTitle: "Redeem Now",
            radius: 15.0,
            showBorder: false,
            titleColor: Theme.of(context).backgroundColor,
            fontWeight: FontWeight.bold,
            textSize: 17.0,
            onTap: () {
              if (redeemableAmountTextEditingController!.text.trim().isEmpty) {
                return;
              }

              if (double.parse(
                      redeemableAmountTextEditingController!.text.trim()) <
                  minimumRedeemableAmountInDollar.toDouble()) {
                //

                UiUtils.setSnackbar(
                    "Minimum redeemable amount is \$$minimumRedeemableAmountInDollar ",
                    context,
                    false);
                return;
              }
              double maxRedeemableAmount = _calculateAmountPerCoins(
                  userCoins:
                      int.parse(context.read<UserDetailsCubit>().getCoins()!),
                  amount: 1,
                  coins: 100);
              if (double.parse(
                      redeemableAmountTextEditingController!.text.trim()) >
                  maxRedeemableAmount) {
                //

                UiUtils.setSnackbar(
                    "You don't have enough coins to redeem this amount",
                    context,
                    false);
                return;
              }

              showRedeemRequestAmountBottomSheet(
                deductedCoins: _calculateDeductedCoinsForRedeemableAmount(
                    amount: 1,
                    coins: 100,
                    userEnteredAmount: double.parse(
                        redeemableAmountTextEditingController!.text.trim())),
                redeemableAmount: double.parse(
                    redeemableAmountTextEditingController!.text.trim()),
              );
            },
            height: 50.0,
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height * (0.03),
          ),

          Divider(
            height: 1.5,
            color: Theme.of(context).primaryColor,
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height * (0.025),
          ),

          //
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Note",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 18.0),
                    )),
                Column(
                  children: walletRequestNotes
                      .map((e) => _buildWalletRequestNoteContainer(e))
                      .toList(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTransactionContainer() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _currentSelectedTab == 1
                ? _buildRequestContainer()
                : _buildTransactionContainer(),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _buildAppBar(),
          ),
        ],
      ),
    );
  }
}
