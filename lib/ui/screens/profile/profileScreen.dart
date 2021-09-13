import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/uploadProfileCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';

import 'package:flutterquiz/ui/screens/profile/widgets/editProfileFieldBottomSheetContainer.dart';
import 'package:flutterquiz/ui/widgets/circularImageContainer.dart';
import 'package:flutterquiz/ui/widgets/pageBackgroundGradientContainer.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share_plus/share_plus.dart';

//menu
class Menu {
  final String title;
  final String imagePath;
  final String routeName;
  final Map<String, dynamic> routeArguments;

  Menu({required this.title, required this.imagePath, required this.routeName, required this.routeArguments});
}

class ProfileScreen extends StatelessWidget {
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (context) => MultiBlocProvider(providers: [
              BlocProvider<UploadProfileCubit>(
                  create: (context) => UploadProfileCubit(
                        ProfileManagementRepository(),
                      )),
              BlocProvider<UpdateUserDetailCubit>(
                  create: (context) => UpdateUserDetailCubit(
                        ProfileManagementRepository(),
                      )),
            ], child: ProfileScreen()));
  }

  ProfileScreen({
    Key? key,
  }) : super(key: key);
  final List<Menu> menuList = [
    Menu(
      imagePath: "bookmark_icon.svg",
      routeArguments: {},
      routeName: Routes.bookmark,
      title: "bookmarkLbl",
    ),
    Menu(
      imagePath: "howtoplay_icon.svg",
      routeArguments: {},
      routeName: Routes.bookmark,
      title: howToPlayLbl,
    ),
    Menu(
      imagePath: "invite_friends.svg",
      routeArguments: {},
      routeName: Routes.bookmark,
      title: "inviteFriendsLbl",
    ),
    Menu(
      imagePath: "contactus_icon.svg",
      routeArguments: {},
      routeName: Routes.bookmark,
      title: contactUs,
    ),
    Menu(
      imagePath: "aboutus_icon.svg",
      routeArguments: {},
      routeName: Routes.bookmark,
      title: aboutUs,
    ),
    Menu(
      imagePath: "termscond_icon.svg",
      routeArguments: {},
      routeName: Routes.bookmark,
      title: termsAndConditions,
    ),
    Menu(
      imagePath: "rateus_icon.svg",
      routeArguments: {},
      routeName: Routes.bookmark,
      title: "rateUsLbl",
    ),
    Menu(
      imagePath: "privacypolicy_icon.svg",
      routeArguments: {},
      routeName: Routes.bookmark,
      title: privacyPolicy,
    ),
    Menu(
      imagePath: "share_app.svg",
      routeArguments: {},
      routeName: Routes.bookmark,
      title: "shareAppLbl",
    ),
    Menu(
      imagePath: "logout_icon.svg",
      routeArguments: {},
      routeName: Routes.bookmark,
      title: "logoutLbl",
    ),
  ];

  void onMenuTap(String menuItem, BuildContext context) {
    if (menuItem == AppLocalization.of(context)!.getTranslatedValues("logoutLbl")!) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text(
                  AppLocalization.of(context)!.getTranslatedValues("logoutDialogLbl")!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();

                        context.read<AuthCubit>().signOut();
                        Navigator.of(context).pushReplacementNamed(Routes.login);
                      },
                      child: Text(
                        AppLocalization.of(context)!.getTranslatedValues("yesBtn")!,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        AppLocalization.of(context)!.getTranslatedValues("noBtn")!,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      )),
                ],
              ));
    } else if (menuItem == AppLocalization.of(context)!.getTranslatedValues("bookmarkLbl")!) {
      Navigator.of(context).pushNamed(Routes.bookmark);
    } else if (menuItem == AppLocalization.of(context)!.getTranslatedValues("aboutUs")!) {
      Navigator.of(context).pushNamed(Routes.appSettings, arguments: aboutUs);
    } else if (menuItem == AppLocalization.of(context)!.getTranslatedValues("contactUs")!) {
      Navigator.of(context).pushNamed(Routes.appSettings, arguments: contactUs);
    } else if (menuItem == AppLocalization.of(context)!.getTranslatedValues("termsAndConditions")!) {
      Navigator.of(context).pushNamed(Routes.appSettings, arguments: termsAndConditions);
    } else if (menuItem == AppLocalization.of(context)!.getTranslatedValues("privacyPolicy")!) {
      Navigator.of(context).pushNamed(Routes.appSettings, arguments: privacyPolicy);
    } else if (menuItem == AppLocalization.of(context)!.getTranslatedValues("inviteFriendsLbl")!) {
      Navigator.of(context).pushNamed(Routes.referAndEarn);
    } else if (menuItem == AppLocalization.of(context)!.getTranslatedValues("shareAppLbl")!) {
      //share app dialog
      try {
        if (Platform.isAndroid) {
          Share.share(appName + " \nhttps://play.google.com/store/apps/details?id=" + packageName + "\n" + context.read<SystemConfigCubit>().getSystemDetails().shareappText!);
        } else {
          Share.share(appName + packageName + "\n" + context.read<SystemConfigCubit>().getSystemDetails().shareappText!);
          context.read<SystemConfigCubit>().getSystemDetails().shareappText!;
        }
      } catch (e) {
        UiUtils.setSnackbar(e.toString(), context, false);
      }
    } else if (menuItem == AppLocalization.of(context)!.getTranslatedValues("rateUsLbl")!) {
      //Rate Us pge navigate to playsore
      LaunchReview.launch(
        androidAppId: packageName,
        iOSAppId: "585027354",
      );
    } else if (menuItem == AppLocalization.of(context)!.getTranslatedValues("howToPlayLbl")!) {
      Navigator.of(context).pushNamed(Routes.appSettings, arguments: howToPlayLbl);
    }
  }

  void editProfileFieldBottomSheet(String fieldTitle, String fieldValue, bool isNumericKeyboardEnable, BuildContext context, UpdateUserDetailCubit updateUserDetailCubit) {
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        )),
        context: context,
        builder: (context) {
          return EditProfileFieldBottomSheetContainer(fieldTitle: fieldTitle, fieldValue: fieldValue, numericKeyboardEnable: isNumericKeyboardEnable, updateUserDetailCubit: updateUserDetailCubit);
        }).then((value) {
      context.read<UpdateUserDetailCubit>().emit(UpdateUserDetailInitial());
    });
  }

  Widget _buildProfileTile({required BoxConstraints boxConstraints, required BuildContext context, required String title, required String subTitle, required String leadingIcon, required VoidCallback onEdit, required bool canEditField}) {
    return Container(
      child: Row(
        children: [
          Container(width: 30.0, transform: Matrix4.identity()..scale(0.7), transformAlignment: Alignment.center, child: SvgPicture.asset(UiUtils.getImagePath(leadingIcon))),
          SizedBox(
            width: boxConstraints.maxWidth * (0.03),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 13.0, color: Theme.of(context).primaryColor.withOpacity(0.6)),
              ),
              Container(
                //decoration: BoxDecoration(border: Border.all()),
                width: boxConstraints.maxWidth * (0.625),
                child: Text(
                  subTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15.0, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          Spacer(),
          canEditField
              ? GestureDetector(
                  onTap: onEdit,
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : SizedBox(),
        ],
      ),
      width: boxConstraints.maxWidth * (0.85),
      height: boxConstraints.maxHeight * (0.13),
    );
  }

  Widget _buildProfileContainer(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height * (0.5),
        width: MediaQuery.of(context).size.width * (0.84),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          color: Theme.of(context).backgroundColor,
          boxShadow: [UiUtils.buildBoxShadow()],
        ),
        child: BlocConsumer<UploadProfileCubit, UploadProfileState>(listener: (context, state) {
          if (state is UploadProfileFailure) {
            UiUtils.setSnackbar(AppLocalization.of(context)!.getTranslatedValues(convertErrorCodeToLanguageKey(state.errorMessage))!, context, false);
          } else if (state is UploadProfileSuccess) {
            context.read<UserDetailsCubit>().updateUserProfileUrl(state.imageUrl);
          }
        }, builder: (context, state) {
          return BlocBuilder<UserDetailsCubit, UserDetailsState>(
            bloc: context.read<UserDetailsCubit>(),
            builder: (context, state) {
              if (state is UserDetailsFetchSuccess) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: constraints.maxHeight * (0.05),
                        ),
                        Text(
                          AppLocalization.of(context)!.getTranslatedValues("profileLbl")!,
                          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20.0),
                        ),
                        SizedBox(
                          height: constraints.maxHeight * (0.025),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Center(
                              child: Container(
                                color: Theme.of(context).primaryColor,
                                width: constraints.maxWidth * (0.75),
                                height: 1.75,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(7.5),
                              decoration: BoxDecoration(color: Theme.of(context).backgroundColor, border: Border.all(color: Theme.of(context).primaryColor), shape: BoxShape.circle),
                              child: CircularImageContainer(
                                height: constraints.maxHeight * (0.275),
                                width: constraints.maxWidth * (0.425),
                                imagePath: state.userProfile.profileUrl!,
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: constraints.maxWidth * (0.19),
                                  left: constraints.maxWidth * (0.23),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(constraints.maxWidth * (0.07)),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(Routes.selectProfile, arguments: false);
                                        //showDialog(barrierDismissible: false, context: context, builder: (_) => ChooseProfileDialog(id: context.read<UserDetailsCubit>().getUserId(), bloc: context.read<UploadProfileCubit>()));
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.edit,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        decoration: BoxDecoration(color: Theme.of(context).backgroundColor.withOpacity(0.7), borderRadius: BorderRadius.circular(constraints.maxWidth * (0.07))),
                                        height: constraints.maxWidth * (0.14),
                                        width: constraints.maxWidth * (0.14),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: constraints.maxHeight * (0.04),
                        ),
                        Container(
                          color: Theme.of(context).primaryColor.withOpacity(0.25),
                          width: constraints.maxWidth * (0.825),
                          height: 1.75,
                        ),
                        SizedBox(
                          height: constraints.maxHeight * (0.04),
                        ),
                        _buildProfileTile(
                          canEditField: true,
                          boxConstraints: constraints,
                          context: context,
                          leadingIcon: "name_icon.svg",
                          onEdit: () {
                            editProfileFieldBottomSheet(
                              AppLocalization.of(context)!.getTranslatedValues("nameLbl")!,
                              state.userProfile.name!.isEmpty ? "" : state.userProfile.name!,
                              false,
                              context,
                              context.read<UpdateUserDetailCubit>(),
                            );
                          },
                          subTitle: state.userProfile.name!.isEmpty ? "-" : state.userProfile.name!,
                          title: AppLocalization.of(context)!.getTranslatedValues("nameLbl")!,
                        ),
                        _buildProfileTile(
                          canEditField: !(context.read<AuthCubit>().getAuthProvider() == AuthProvider.mobile),
                          boxConstraints: constraints,
                          context: context,
                          leadingIcon: "mobile_number.svg",
                          onEdit: () {
                            editProfileFieldBottomSheet(
                                AppLocalization.of(context)!.getTranslatedValues("mobileNumberLbl")!, state.userProfile.mobileNumber!.isEmpty ? "" : state.userProfile.mobileNumber!, true, context, context.read<UpdateUserDetailCubit>());
                          },
                          subTitle: state.userProfile.mobileNumber!.isEmpty ? "-" : state.userProfile.mobileNumber!,
                          title: AppLocalization.of(context)!.getTranslatedValues("mobileNumberLbl")!,
                        ),
                        _buildProfileTile(
                          canEditField: !(context.read<AuthCubit>().getAuthProvider() != AuthProvider.mobile),
                          boxConstraints: constraints,
                          context: context,
                          leadingIcon: "email_icon.svg",
                          onEdit: () {
                            editProfileFieldBottomSheet(AppLocalization.of(context)!.getTranslatedValues("emailLbl")!, state.userProfile.email!.isEmpty ? "" : state.userProfile.email!, false, context, context.read<UpdateUserDetailCubit>());
                          },
                          subTitle: state.userProfile.email!.isEmpty ? "-" : state.userProfile.email!,
                          title: AppLocalization.of(context)!.getTranslatedValues("emailLbl")!,
                        ),
                      ],
                    );
                  },
                );
              }
              return Container();
            },
          );
        }));
  }

  Widget _buildMenuContainer(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * (0.84),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: Theme.of(context).backgroundColor,
        boxShadow: [UiUtils.buildBoxShadow()],
      ),
      padding: EdgeInsets.only(top: 5.0),
      child: Column(
        children: menuList
            .map((e) => ListTile(
                  onTap: () {
                    onMenuTap(AppLocalization.of(context)!.getTranslatedValues(e.title)!, context);
                  },
                  title: Text(
                    AppLocalization.of(context)!.getTranslatedValues(e.title)!,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  leading: Container(
                    width: 60,
                    //decoration: BoxDecoration(border: Border.all()),
                    transform: Matrix4.identity()..scale(0.45),
                    transformAlignment: Alignment.center,
                    child: SvgPicture.asset(
                      UiUtils.getImagePath(e.imagePath),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageBackgroundGradientContainer(),
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
            ),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    height: 20.0,
                  ),
                  _buildProfileContainer(context),
                  SizedBox(
                    height: 30.0,
                  ),
                  _buildMenuContainer(context),
                  SizedBox(
                    height: 30.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
