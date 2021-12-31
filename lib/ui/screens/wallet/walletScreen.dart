import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/features/wallet/cubits/paymentRequestCubit.dart';
import 'package:flutterquiz/features/wallet/walletRepository.dart';
import 'package:flutterquiz/ui/screens/wallet/widgets/redeemAmountRequestBottomSheetContainer.dart';
import 'package:flutterquiz/ui/widgets/customBackButton.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

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
          userCoins: int.parse(context.read<UserDetailsCubit>().getCoins()!),
          amount: context
              .read<SystemConfigCubit>()
              .coinAmount(), //per x coin y amount
          coins: context.read<SystemConfigCubit>().perCoin(), //per x coins
        ).toString(),
      );

      setState(() {});
    });
  }

  //calculate amount per coins based on users coins
  double _calculateAmountPerCoins(
      {required int userCoins, required int amount, required int coins}) {
    return (amount * userCoins) / coins;
  }

  //calculate coins based on entered amount
  int _calculateDeductedCoinsForRedeemableAmount(
      {required double userEnteredAmount,
      required int amount,
      required int coins}) {
    return (coins * userEnteredAmount) ~/ amount;
  }

  //
  double _minimumReedemableAmount() {
    return _calculateAmountPerCoins(
      userCoins: context.read<SystemConfigCubit>().minimumcoinLimit(),
      amount: context.read<SystemConfigCubit>().coinAmount(),
      coins: context.read<SystemConfigCubit>().perCoin(),
    );
  }

  //

  @override
  void dispose() {
    redeemableAmountTextEditingController?.dispose();
    super.dispose();
  }

  void showRedeemRequestAmountBottomSheet(
      {required int deductedCoins, required double redeemableAmount}) {
    //
    showModalBottomSheet<bool>(
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
        }).then((value) {
      if (value != null && value) {
        //TODO : Update transaction
        redeemableAmountTextEditingController?.text = _calculateAmountPerCoins(
                userCoins:
                    int.parse(context.read<UserDetailsCubit>().getCoins()!),
                amount: context.read<SystemConfigCubit>().coinAmount(),
                coins: context.read<SystemConfigCubit>().perCoin())
            .toString();

        setState(() {
          _currentSelectedTab = 2;
        });
      }
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
              padding: EdgeInsetsDirectional.only(start: 25.0, bottom: 35.0),
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
              AppLocalization.of(context)!
                  .getTranslatedValues(redeemableAmountKey)!, //
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
              AppLocalization.of(context)!.getTranslatedValues(totalCoinsKey)!,
              style: TextStyle(
                  color: Theme.of(context).primaryColor.withOpacity(0.75),
                  fontSize: 20.0),
            ),
          ),
          BlocBuilder<UserDetailsCubit, UserDetailsState>(
            bloc: context.read<UserDetailsCubit>(),
            builder: (context, state) {
              if (state is UserDetailsFetchSuccess) {
                return Container(
                  alignment: Alignment.center,
                  child: Text(
                    "${context.read<UserDetailsCubit>().getCoins()}",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 20.0),
                  ),
                );
              }

              return SizedBox();
            },
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height * (0.025),
          ),
          CustomRoundedButton(
            widthPercentage: 0.4,
            backgroundColor: Theme.of(context).primaryColor,
            buttonTitle: AppLocalization.of(context)!
                    .getTranslatedValues(redeemNowKey) ??
                "",
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
                  _minimumReedemableAmount()) {
                //

                UiUtils.setSnackbar(
                    "${AppLocalization.of(context)!.getTranslatedValues(minimumRedeemableAmountKey)} \$${_minimumReedemableAmount()} ",
                    context,
                    false);
                return;
              }
              double maxRedeemableAmount = _calculateAmountPerCoins(
                userCoins:
                    int.parse(context.read<UserDetailsCubit>().getCoins()!),
                amount: context
                    .read<SystemConfigCubit>()
                    .coinAmount(), //per x coin y amount
                coins:
                    context.read<SystemConfigCubit>().perCoin(), //per x coins
              );
              if (double.parse(
                      redeemableAmountTextEditingController!.text.trim()) >
                  maxRedeemableAmount) {
                //

                UiUtils.setSnackbar(
                    AppLocalization.of(context)!
                        .getTranslatedValues(notEnoughCoinsToRedeemAmountKey)!,
                    context,
                    false);
                return;
              }

              showRedeemRequestAmountBottomSheet(
                deductedCoins: _calculateDeductedCoinsForRedeemableAmount(
                  amount: context
                      .read<SystemConfigCubit>()
                      .coinAmount(), //per x coin y amount
                  coins:
                      context.read<SystemConfigCubit>().perCoin(), //per x coins
                  userEnteredAmount: double.parse(
                    redeemableAmountTextEditingController!.text.trim(),
                  ),
                ),
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
                      AppLocalization.of(context)!
                          .getTranslatedValues(notesKey)!,
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
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionContainer(int index) {
    return GestureDetector(
      onTap: () {
        //
        print(MediaQuery.of(context).size.height);
      },
      child: LayoutBuilder(builder: (context, boxConstraints) {
        return Container(
          child: Row(
            children: [
              Container(
                width: boxConstraints.maxWidth * (0.6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalization.of(context)!
                          .getTranslatedValues(redeemRequestKey)!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Theme.of(context).backgroundColor,
                          fontSize: 16.5),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Text("Paypal",
                            style: TextStyle(
                                fontSize: 12.0,
                                color: Theme.of(context)
                                    .backgroundColor
                                    .withOpacity(0.875))),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * (0.0225),
                        ),
                        CircleAvatar(
                          backgroundColor: Theme.of(context).backgroundColor,
                          radius: 2.75,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * (0.0225),
                        ),
                        Text(
                          "30-12-2021",
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Theme.of(context)
                                  .backgroundColor
                                  .withOpacity(0.875)),
                        ),
                        Text(
                          "  3:56 PM",
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Theme.of(context)
                                  .backgroundColor
                                  .withOpacity(0.875)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Spacer(),
              Container(
                width: boxConstraints.maxWidth * 0.3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 1.0),
                      margin: EdgeInsets.only(
                          left: boxConstraints.maxWidth * 0.3 * (0.4)),
                      color: Theme.of(context).backgroundColor,
                      alignment: Alignment.center,
                      child: Text(
                        "\$${UiUtils.formatNumber(500)}",
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 15),
                      ),
                    ),
                    Spacer(),
                    Text(
                      index == 1 ? "Pending" : "Rejected",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Theme.of(context).backgroundColor,
                          fontSize: 12.0),
                    ),
                  ],
                ),
              )
            ],
          ),
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * (0.03),
              vertical: 15),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(10.0)),
          height: MediaQuery.of(context).size.height *
              UiUtils.getTransactionContainerHeight(
                  MediaQuery.of(context).size.height), //
          margin: EdgeInsets.symmetric(vertical: 10.0),
        );
      }),
    );
  }

  Widget _buildTransactionListContainer() {
    return SingleChildScrollView(
      child: Column(
        children: [
          //

          Container(
            alignment: Alignment.center,
            child: Text(
              "${AppLocalization.of(context)!.getTranslatedValues(totalEarningsKey)!} : \$1000",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 18.0,
              ),
            ),
            width: MediaQuery.of(context).size.width * (0.75),
            height: MediaQuery.of(context).size.height * (0.065),
            decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.circular(20.0)),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.015),
          ),

          Column(
            children:
                [1, 2, 3].map((e) => _buildTransactionContainer(e)).toList(),
          )
        ],
      ),
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height *
              (UiUtils.appBarHeightPercentage + 0.025),
          left: MediaQuery.of(context).size.width * (0.05),
          right: MediaQuery.of(context).size.width * (0.05)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageBackgroundGradientContainer(),
          Align(
            alignment: Alignment.topCenter,
            child: _currentSelectedTab == 1
                ? _buildRequestContainer()
                : _buildTransactionListContainer(),
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
