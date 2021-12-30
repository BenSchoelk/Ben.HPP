import 'package:flutter/material.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/wallet/cubits/paymentRequestCubit.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RedeemAmountRequestBottomSheetContainer extends StatefulWidget {
  final double redeemableAmount;
  final int deductedCoins;
  final PaymentRequestCubit paymentRequestCubit;
  RedeemAmountRequestBottomSheetContainer(
      {Key? key,
      required this.deductedCoins,
      required this.redeemableAmount,
      required this.paymentRequestCubit})
      : super(key: key);

  @override
  _RedeemAmountRequestBottomSheetContainerState createState() =>
      _RedeemAmountRequestBottomSheetContainerState();
}

class _RedeemAmountRequestBottomSheetContainerState
    extends State<RedeemAmountRequestBottomSheetContainer>
    with TickerProviderStateMixin {
  late double _selectPaymentMethodDx = 0;

  late int _selectedPaymentMethodIndex = 0;
  late int _enterPayoutMethodDx = 1;

  Widget _buildPaymentSelectMethodContainer({required int paymentMethodIndex}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethodIndex = paymentMethodIndex;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width * (0.16),
        height: MediaQuery.of(context).size.width * (0.16),
        color: _selectedPaymentMethodIndex == paymentMethodIndex
            ? Theme.of(context).primaryColor
            : Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _buildEnterPayoutMethodIdContainer() {
    return AnimatedContainer(
      curve: Curves.easeInOut,
      transform: Matrix4.identity()
        ..setEntry(
            0, 3, MediaQuery.of(context).size.width * _enterPayoutMethodDx),
      duration: Duration(milliseconds: 500),
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.015),
          ),
          //
          Container(
            alignment: Alignment.center,
            child: Text(
              "Payout method - $_selectedPaymentMethodIndex",
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20.0),
            ),
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height * (0.025),
          ),

          Container(
            padding: EdgeInsets.only(left: 20.0, right: 20.0),
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * (0.1)),
            decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.circular(25.0)),
            height: MediaQuery.of(context).size.height * (0.05),
            child: TextField(
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).primaryColor),
              cursorColor: Theme.of(context).primaryColor,
              decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: "Enter id",
                  hintStyle: TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).primaryColor,
                  )),
            ),
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height * (0.025),
          ),

          CustomRoundedButton(
            widthPercentage: 0.4,
            backgroundColor: Theme.of(context).primaryColor,
            buttonTitle: "Make Request",
            radius: 15.0,
            showBorder: false,
            titleColor: Theme.of(context).backgroundColor,
            fontWeight: FontWeight.bold,
            textSize: 17.0,
            onTap: () {
              widget.paymentRequestCubit.makePaymentRequest(
                  userId: context.read<UserDetailsCubit>().getUserId(),
                  paymentType: "upi",
                  paymentAddress: "test@oxaxis",
                  paymentAmount: widget.redeemableAmount.toString(),
                  coinUsed: widget.deductedCoins.toString(),
                  details: "Redeem Request");
            },
            height: 40.0,
          ),

          Container(
            child: TextButton(
                onPressed: () {
                  //
                  setState(() {
                    _selectPaymentMethodDx = 0;
                    _enterPayoutMethodDx = 1;
                  });
                },
                child: Text(
                  "Change payout method",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                )),
          )
        ],
      ),
    );
  }

  Widget _buildSelectPayoutOption() {
    return AnimatedContainer(
      curve: Curves.easeInOut,
      transform: Matrix4.identity()
        ..setEntry(
            0, 3, MediaQuery.of(context).size.width * _selectPaymentMethodDx),
      duration: Duration(milliseconds: 500),
      child: Column(
        children: [
          Transform.translate(
            offset: Offset(0.0, -20.0),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "Redeemable Amount",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 20.0),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "\$${widget.redeemableAmount}",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 22.0),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "${widget.deductedCoins} coins will be deducted",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor, fontSize: 20.0),
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(0.0, -10.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Divider(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Text(
              "Select payout option",
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20.0),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.55) * (0.05),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                _buildPaymentSelectMethodContainer(paymentMethodIndex: 0),
              ],
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.55) * (0.075),
          ),
          CustomRoundedButton(
            widthPercentage: 0.4,
            backgroundColor: Theme.of(context).primaryColor,
            buttonTitle: "Continue",
            radius: 15.0,
            showBorder: false,
            titleColor: Theme.of(context).backgroundColor,
            fontWeight: FontWeight.bold,
            textSize: 17.0,
            onTap: () {
              //
              setState(() {
                _selectPaymentMethodDx = -1;
                _enterPayoutMethodDx = 0;
              });
            },
            height: 40.0,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * (0.8)),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          gradient: UiUtils.buildLinerGradient([
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).canvasColor
          ], Alignment.topCenter, Alignment.bottomCenter)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.all(10.0),
                alignment: Alignment.centerRight,
                child: IconButton(
                    onPressed: () {
                      if (widget.paymentRequestCubit.state
                          is PaymentRequestInProgress) {
                        return;
                      }
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close,
                      size: 28.0,
                      color: Theme.of(context).primaryColor,
                    )),
              ),
            ],
          ),
          Stack(
            children: [
              _buildSelectPayoutOption(),
              _buildEnterPayoutMethodIdContainer(),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * (0.05),
          ),
        ],
      ),
    );
  }
}
