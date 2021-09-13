import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/inAppPurchase/inAppPurchaseCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/ui/widgets/roundedAppbar.dart';
import 'package:flutterquiz/utils/inAppPurchaseProducts.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class CoinStoreScreen extends StatefulWidget {
  CoinStoreScreen({Key? key}) : super(key: key);

  @override
  _CoinStoreScreenState createState() => _CoinStoreScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (context) => MultiBlocProvider(providers: [
              BlocProvider<InAppPurchaseCubit>(create: (context) => InAppPurchaseCubit(productIds: inAppPurchaseProducts.keys.toList())),
              BlocProvider<UpdateScoreAndCoinsCubit>(create: (context) => UpdateScoreAndCoinsCubit(ProfileManagementRepository())),
            ], child: CoinStoreScreen()));
  }
}

class _CoinStoreScreenState extends State<CoinStoreScreen> with SingleTickerProviderStateMixin {
  Widget _buildProducts(List<ProductDetails> products) {
    return ListView.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * UiUtils.appBarHeightPercentage,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              context.read<InAppPurchaseCubit>().buyConsumableProducts(products[index]);
            },
            title: Text("${products[index].title} - ${inAppPurchaseProducts[products[index].id]}"),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: RoundedAppbar(
                title: AppLocalization.of(context)!.getTranslatedValues("storeLbl")!,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: BlocConsumer<InAppPurchaseCubit, InAppPurchaseState>(
                bloc: context.read<InAppPurchaseCubit>(),
                listener: (context, state) {
                  print("State change to ${state.toString()}");
                  if (state is InAppPurchaseProcessSuccess) {
                    print("Add ${inAppPurchaseProducts[state.purchasedProductId]} coins to user wallet");
                    context.read<UserDetailsCubit>().updateCoins(
                          addCoin: true,
                          coins: inAppPurchaseProducts[state.purchasedProductId],
                        );
                    context.read<UpdateScoreAndCoinsCubit>().updateCoins(context.read<UserDetailsCubit>().getUserId(), inAppPurchaseProducts[state.purchasedProductId], true);
                    UiUtils.setSnackbar("Coins bought successfully", context, false);
                  } else if (state is InAppPurchaseFailure) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Text(state.errorMessage),
                            ));
                  } else if (state is InAppPurchaseProcessFailure) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Text(state.errorMessage),
                            ));
                  }
                },
                builder: (context, state) {
                  //initial state of cubit
                  if (state is InAppPurchaseInitial || state is InAppPurchaseLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  //if occurred problem while fetching product details
                  //from appstore or playstore
                  if (state is InAppPurchaseFailure) {
                    //
                    return Center(
                      child: Text("${state.errorMessage}"),
                    );
                  }

                  if (state is InAppPurchaseNotAvailable) {
                    return Center(
                      child: Text("In-app purchase is not available"),
                    );
                  }

                  //if any error occurred in while making in-app purchase
                  if (state is InAppPurchaseProcessFailure) {
                    return _buildProducts(state.products);
                  }
                  //
                  if (state is InAppPurchaseAvailable) {
                    return _buildProducts(state.products);
                  }
                  //
                  if (state is InAppPurchaseProcessSuccess) {
                    return _buildProducts(state.products);
                  }
                  if (state is InAppPurchaseProcessInProgress) {
                    return _buildProducts(state.products);
                  }

                  return Container();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
