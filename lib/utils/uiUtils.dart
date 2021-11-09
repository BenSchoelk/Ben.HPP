import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/battleRoom/battleRoomRepository.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/bookmark/cubits/bookmarkCubit.dart';
import 'package:flutterquiz/features/localization/appLocalizationCubit.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/styles/theme/appTheme.dart';

import 'package:flutterquiz/ui/widgets/errorMessageDialog.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/stringLabels.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UiUtils {
  static double questionContainerHeightPercentage = 0.725;
  static double quizTypeMaxHeightPercentage = 0.275;
  static double quizTypeMinHeightPercentage = 0.185;

  static double profileHeightBreakPointResultScreen = 355.0;

  static double bottomMenuPercentage = 0.075;

  static double dailogHeightPercentage = 0.65;
  static double dailogWidthPercentage = 0.85;

  static double dailogBlurSigma = 6.0;
  static double dailogRadius = 40.0;
  static double appBarHeightPercentage = 0.16;

  static List<String> needToUpdateBadgesLocally = [];

  static String buildGuessTheWordQuestionAnswer(List<String> submittedAnswer) {
    String answer = "";
    submittedAnswer.forEach((element) {
      if (element.isNotEmpty) {
        answer = answer + element;
      }
    });
    return answer;
  }

  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    if (message.data['type'].toString() == "badges") {
      needToUpdateBadgesLocally.add(message.data['badge_type'].toString());
    }
    print(message.data);
  }

  static void updateBadgesLocally(BuildContext context) {
    needToUpdateBadgesLocally.forEach((badgeType) {
      context.read<BadgesCubit>().unlockBadge(badgeType);
    });
    needToUpdateBadgesLocally.clear();
  }

  static void setSnackbar(String msg, BuildContext context, bool showAction, {Function? onPressedAction, Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(msg, textAlign: showAction ? TextAlign.start : TextAlign.center, style: TextStyle(color: Theme.of(context).backgroundColor, fontWeight: FontWeight.bold, fontSize: 16.0)),
      behavior: SnackBarBehavior.fixed,
      duration: duration ?? Duration(seconds: 2),
      backgroundColor: Theme.of(context).primaryColor,
      action: showAction
          ? SnackBarAction(
              label: "Retry",
              onPressed: onPressedAction as void Function(),
              textColor: Theme.of(context).backgroundColor,
            )
          : null,
      elevation: 2.0,
    ));
  }

  static void errorMessageDialog(BuildContext context, String? errorMessage) {
    showDialog(context: context, builder: (_) => ErrorMessageDialog(errorMessage: errorMessage));
  }

  static String getImagePath(String imageName) {
    return "assets/images/$imageName";
  }

  static String getprofileImagePath(String imageName) {
    return "assets/images/profile/$imageName";
  }

  static String getEmojiPath(String emojiName) {
    return "assets/images/emojis/$emojiName";
  }

  static BoxShadow buildBoxShadow({Offset? offset, double? blurRadius, Color? color}) {
    return BoxShadow(
      color: color ?? Colors.black.withOpacity(0.1),
      blurRadius: blurRadius ?? 10.0,
      offset: offset ?? Offset(5.0, 5.0),
    );
  }

  static BoxShadow buildAppbarShadow() {
    return buildBoxShadow(blurRadius: 5.0, color: Colors.black.withOpacity(0.3), offset: Offset.zero);
  }

  static LinearGradient buildLinerGradient(List<Color> colors, Alignment begin, Alignment end) {
    return LinearGradient(colors: colors, begin: begin, end: end);
  }

  static String getCurrentQuestionLanguageId(BuildContext context) {
    final currentLanguage = context.read<AppLocalizationCubit>().state.language;
    if (context.read<SystemConfigCubit>().getLanguageMode() == "1") {
      final supporatedLanguage = context.read<SystemConfigCubit>().getSupportedLanguages();
      final supporatedLanguageIndex = supporatedLanguage.indexWhere((element) => getLocaleFromLanguageCode(element.languageCode) == currentLanguage);
      print(supporatedLanguageIndex);
      return supporatedLanguage[supporatedLanguageIndex].id;
    }

    return defaultQuestionLanguageId;
  }

  static Locale getLocaleFromLanguageCode(String languageCode) {
    List<String> result = languageCode.split("-");
    return result.length == 1 ? Locale(result.first) : Locale(result.first, result.last);
  }

  static String formatNumber(int number) {
    return NumberFormat.compact().format(number).toLowerCase();
  }

  //This method will determine how much coins will user get after
  //completing the quiz
  static int coinsBasedOnWinPercentage(double percentage, QuizTypes quizType) {
    //if percentage is more than maxCoinsWinningPercentage then user will earn maxWinningCoins
    //
    //if percentage is less than maxCoinsWinningPercentage
    //coin value will deduct from maxWinning coins
    //earned coins = (maxWinningCoins - ((maxCoinsWinningPercentage - percentage)/ 10))

    //For example: if percentage is 70 then user will
    //earn 3 coins if maxWinningCoins is 4

    int earnedCoins = 0;
    if (percentage >= maxCoinsWinningPercentage) {
      earnedCoins = quizType == QuizTypes.guessTheWord ? guessTheWordMaxWinningCoins : maxWinningCoins;
    } else {
      int maxCoins = quizType == QuizTypes.guessTheWord ? guessTheWordMaxWinningCoins : maxWinningCoins;

      earnedCoins = (maxCoins - ((maxCoinsWinningPercentage - percentage) / 10)).toInt();
    }
    if (earnedCoins < 0) {
      earnedCoins = 0;
    }
    return earnedCoins;
  }

  static String getCategoryTypeNumberFromQuizType(QuizTypes quizType) {
    //quiz_zone=1, fun_n_learn=2, guess_the_word=3, audio_question=4
    if (quizType == QuizTypes.audioQuestions) {
      return "4";
    }
    if (quizType == QuizTypes.guessTheWord) {
      return "3";
    }
    if (quizType == QuizTypes.funAndLearn) {
      return "2";
    }
    return "1";
  }

  static Future<bool> forceUpdate(String updatedVersion) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = "${packageInfo.version}+${packageInfo.buildNumber}";
    if (updatedVersion.isEmpty) {
      return false;
    }

    bool updateBasedOnVersion = _shouldUpdateBasedOnVersion(currentVersion.split("+").first, updatedVersion.split("+").first);
    bool updateBasedOnBuildNumber = _shouldUpdateBasedOnBuildNumber(currentVersion.split("+").last, updatedVersion.split("+").last);

    return (updateBasedOnVersion || updateBasedOnBuildNumber);
  }

  static bool _shouldUpdateBasedOnVersion(String currentVersion, String updatedVersion) {
    List<int> currentVersionList = currentVersion.split(".").map((e) => int.parse(e)).toList();
    List<int> updatedVersionList = updatedVersion.split(".").map((e) => int.parse(e)).toList();

    if (updatedVersionList[0] > currentVersionList[0]) {
      return true;
    }
    if (updatedVersionList[1] > currentVersionList[1]) {
      return true;
    }
    if (updatedVersionList[2] > currentVersionList[2]) {
      return true;
    }

    return false;
  }

  static bool _shouldUpdateBasedOnBuildNumber(String currentBuildNumber, String updatedBuildNumber) {
    return int.parse(updatedBuildNumber) > int.parse(currentBuildNumber);
  }

  static void vibrate() {
    HapticFeedback.heavyImpact();
    HapticFeedback.vibrate();
  }

  static void fetchBookmarkAndBadges({required BuildContext context, required String userId}) {
    //fetch bookmark
    if (context.read<BookmarkCubit>().state is! BookmarkFetchSuccess) {
      print("Fetch bookmark details");
      context.read<BookmarkCubit>().getBookmark(userId);
      //delete any unused gruop battle room which is created by this user
      BattleRoomRepository().deleteUnusedBattleRoom(userId);
    }

    if (context.read<BadgesCubit>().state is! BadgesFetchSuccess) {
      print("Fetch badges details");
      //get badges for given user
      context.read<BadgesCubit>().getBadges(userId: userId);
    }
  }

  static int determineBattleCorrectAnswerPoints(double animationControllerValue) {
    double secondsTakenToAnswer = (questionDurationInSeconds * animationControllerValue);

    print("Took ${secondsTakenToAnswer}s to give the answer");

    //improve points system here if needed
    if (secondsTakenToAnswer <= 2) {
      return correctAnswerPointsForBattle + extraPointForQuickestAnswer;
    } else if (secondsTakenToAnswer <= 4) {
      return correctAnswerPointsForBattle + extraPointForSecondQuickestAnswer;
    }
    return correctAnswerPointsForBattle;
  }

  static double timeTakenToSubmitAnswer({required double animationControllerValue, required QuizTypes quizType}) {
    double secondsTakenToAnswer;

    if (quizType == QuizTypes.guessTheWord) {
      secondsTakenToAnswer = (guessTheWordQuestionDurationInSeconds * animationControllerValue);
    } else {
      secondsTakenToAnswer = (questionDurationInSeconds * animationControllerValue);
    }
    return secondsTakenToAnswer;
  }

  //navigate to battle screen
  static void navigateToOneVSOneBattleScreen(BuildContext context) {
    //reset state of battle room to initial
    context.read<BattleRoomCubit>().emit(BattleRoomInitial());
    if (context.read<SystemConfigCubit>().getIsCategoryEnableForBattle() == "1") {
      //go to category page
      Navigator.of(context).pushNamed(Routes.category, arguments: {"quizType": QuizTypes.battle});
    } else {
      Navigator.of(context).pushNamed(Routes.battleRoomFindOpponent, arguments: "").then((value) {
        //need to delete room if user exit the process in between of finding opponent
        //or instantly press exit button
        Future.delayed(Duration(milliseconds: 3000)).then((value) {
          //In battleRoomFindOpponent screen
          //we are calling pushReplacement method so it will trigger this
          //callback so we need to check if state is not battleUserFound then
          //and then we need to call deleteBattleRoom

          //when user press the backbutton and choose to exit the game and
          //process of creating room(in firebase) is still running
          //then state of battleRoomCubit will not be battleRoomUserFound
          //deleteRoom call execute
          if (context.read<BattleRoomCubit>().state is! BattleRoomUserFound) {
            context.read<BattleRoomCubit>().deleteBattleRoom(false);
          }
        });
      });
    }
  }

  static String getThemeLabelFromAppTheme(AppTheme appTheme) {
    if (appTheme == AppTheme.Dark) {
      return darkThemeKey;
    }
    return lightThemeKey;
  }

  static AppTheme getAppThemeFromLabel(String label) {
    if (label == darkThemeKey) {
      return AppTheme.Dark;
    }
    return AppTheme.Light;
  }

  //will be in use while playing screen
  //this method will be in use to display color based on user's answer
  static Color getOptionBackgroundColor(Question question, BuildContext context, String? optionId, String? showCorrectAnswerMode) {
    if (question.attempted) {
      if (showCorrectAnswerMode == "0") {
        return Theme.of(context).primaryColor.withOpacity(0.65);
      }

      // if given answer is correct
      if (question.submittedAnswerId == question.correctAnswerOptionId) {
        //if given option is same as answer
        if (question.submittedAnswerId == optionId) {
          return Colors.greenAccent;
        }
        //color will not change for other options
        return Theme.of(context).colorScheme.secondary;
      } else {
        //option id is same as given answer then change color to red
        if (question.submittedAnswerId == optionId) {
          return Colors.redAccent;
        }
        //if given option id is correct as same answer then change color to green
        else if (question.correctAnswerOptionId == optionId) {
          return Colors.greenAccent;
        }
        //do not change color
        return Theme.of(context).colorScheme.secondary;
      }
    }
    return Theme.of(context).colorScheme.secondary;
  }

  //will be in use while playing  quiz screen
  //this method will be in use to display color based on user's answer
  static Color getOptionTextColor(Question question, BuildContext context, String? optionId, String? showCorrectAnswerMode) {
    if (question.attempted) {
      if (showCorrectAnswerMode == "0") {
        return Theme.of(context).scaffoldBackgroundColor;
      }

      // if given answer is correct
      if (question.submittedAnswerId == question.correctAnswerOptionId) {
        //if given option is same as answer
        if (question.submittedAnswerId == optionId) {
          return Theme.of(context).scaffoldBackgroundColor;
        }
        //color will not change for other options
        return Theme.of(context).scaffoldBackgroundColor;
      } else {
        //option id is same as given answer then change color to red
        if (question.submittedAnswerId == optionId) {
          return Theme.of(context).scaffoldBackgroundColor;
        }
        //if given option id is correct as same answer then change color to green
        else if (question.correctAnswerOptionId == optionId) {
          return Theme.of(context).scaffoldBackgroundColor;
        }
        //do not change color
        return Theme.of(context).scaffoldBackgroundColor;
      }
    }
    return Theme.of(context).scaffoldBackgroundColor;
  }
}
