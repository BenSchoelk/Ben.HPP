import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/appLocalization.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/answerOption.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/ui/screens/quiz/quizScreen.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/audioQuestionContainer.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/guessTheWordQuestionContainer.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/ui/widgets/optionContainer.dart';
import 'package:flutterquiz/ui/widgets/questionBackgroundCard.dart';
import 'package:flutterquiz/ui/widgets/settingsDialogContainer.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/lifeLineOptions.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class QuestionsContainer extends StatefulWidget {
  final List<GlobalKey> guessTheWordQuestionContainerKeys;

  final List<GlobalKey>? audioQuestionContainerKeys;
  final QuizTypes quizType;
  final Function hasSubmittedAnswerForCurrentQuestion;
  final int currentQuestionIndex;
  final Function submitAnswer;
  final AnimationController questionContentAnimationController;
  final AnimationController questionAnimationController;
  final Animation<double> questionSlideAnimation;
  final Animation<double> questionScaleUpAnimation;
  final Animation<double> questionScaleDownAnimation;
  final Animation<double> questionContentAnimation;
  final List<Question> questions;
  final List<GuessTheWordQuestion> guessTheWordQuestions;
  final double? topPadding;
  final Widget bookmarkButton;
  final String? level;
  final Map<String, LifelineStatus> lifeLines;
  final bool? showAnswerCorrectness;
  final Function toggleSettingDialog;
  final AnimationController? timerAnimationController;

  const QuestionsContainer({
    Key? key,
    required this.submitAnswer,
    required this.quizType,
    required this.toggleSettingDialog,
    required this.guessTheWordQuestionContainerKeys,
    required this.hasSubmittedAnswerForCurrentQuestion,
    required this.currentQuestionIndex,
    required this.guessTheWordQuestions,
    required this.questionAnimationController,
    required this.questionContentAnimationController,
    required this.questionContentAnimation,
    required this.questionScaleDownAnimation,
    required this.questionScaleUpAnimation,
    required this.questionSlideAnimation,
    required this.questions,
    required this.bookmarkButton,
    required this.lifeLines,
    this.audioQuestionContainerKeys,
    this.showAnswerCorrectness,
    this.timerAnimationController,
    this.level,
    this.topPadding,
  }) : super(key: key);

  @override
  State<QuestionsContainer> createState() => _QuestionsContainerState();
}

class _QuestionsContainerState extends State<QuestionsContainer> {
  List<AnswerOption> fiftyFiftyAnswerOptions = [];
  List<int> percentages = [];

  double textSize = 14;
  void settingDialog() {
    widget.toggleSettingDialog();
    showDialog(
        context: context,
        builder: (_) {
          return SettingsDialogContainer();
        }).then((value) => widget.toggleSettingDialog());
  }

  //to get question length
  int getQuestionsLength() {
    if (widget.questions.isNotEmpty) {
      return widget.questions.length;
    }
    return widget.guessTheWordQuestions.length;
  }

  Widget _buildOptions(Question question, BoxConstraints constraints) {
    if (widget.lifeLines.isNotEmpty) {
      if (widget.lifeLines[fiftyFifty] == LifelineStatus.using) {
        if (!question.attempted) {
          fiftyFiftyAnswerOptions = LifeLineOptions.getFiftyFiftyOptions(question.answerOptions!, question.correctAnswerOptionId!);
        }
        //build lifeline when using 50/50 lifelines
        return Column(
            children: fiftyFiftyAnswerOptions
                .map((answerOption) => OptionContainer(
                      submittedAnswerId: question.submittedAnswerId,
                      showAnswerCorrectness: widget.showAnswerCorrectness!,
                      showAudiencePoll: false,
                      hasSubmittedAnswerForCurrentQuestion: widget.hasSubmittedAnswerForCurrentQuestion,
                      constraints: constraints,
                      answerOption: answerOption,
                      correctOptionId: question.correctAnswerOptionId!,
                      submitAnswer: widget.submitAnswer,
                    ))
                .toList());
      }

      if (widget.lifeLines[audiencePoll] == LifelineStatus.using) {
        if (!question.attempted) {
          percentages = LifeLineOptions.getAudiencePollPercentage(question.answerOptions!, question.correctAnswerOptionId!);
        }

        //build options when using audience poll lifeline
        return Column(
            children: question.answerOptions!.map((option) {
          int percentageIndex = question.answerOptions!.indexOf(option);
          return OptionContainer(
            submittedAnswerId: question.submittedAnswerId,
            showAnswerCorrectness: widget.showAnswerCorrectness!,
            showAudiencePoll: true,
            audiencePollPercentage: percentages[percentageIndex],
            hasSubmittedAnswerForCurrentQuestion: widget.hasSubmittedAnswerForCurrentQuestion,
            constraints: constraints,
            answerOption: option,
            correctOptionId: question.correctAnswerOptionId!,
            submitAnswer: widget.submitAnswer,
          );
        }).toList());
      }
      //build answer when no lifeline is in using state
      return Column(
        children: question.answerOptions!.map((option) {
          return OptionContainer(
            submittedAnswerId: question.submittedAnswerId,
            showAnswerCorrectness: widget.showAnswerCorrectness!,
            showAudiencePoll: false,
            hasSubmittedAnswerForCurrentQuestion: widget.hasSubmittedAnswerForCurrentQuestion,
            constraints: constraints,
            answerOption: option,
            correctOptionId: question.correctAnswerOptionId!,
            submitAnswer: widget.submitAnswer,
          );
        }).toList(),
      );
    }
    //build options when no need to use lifeline
    return Column(
      children: question.answerOptions!.map((option) {
        return OptionContainer(
          submittedAnswerId: question.submittedAnswerId,
          showAnswerCorrectness: widget.showAnswerCorrectness!,
          showAudiencePoll: false,
          hasSubmittedAnswerForCurrentQuestion: widget.hasSubmittedAnswerForCurrentQuestion,
          constraints: constraints,
          answerOption: option,
          correctOptionId: question.correctAnswerOptionId!,
          submitAnswer: widget.submitAnswer,
        );
      }).toList(),
    );
  }

  Widget _buildLevelContainer() {
    if (widget.level == null) {
      return Container();
    }
    if (widget.level!.isEmpty) {
      return Container();
    }
    return Container(
      child: Text(
        AppLocalization.of(context)!.getTranslatedValues("levelLbl")! + " : ${widget.level}",
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }

  Widget _buildCurrentCoins() {
    if (widget.lifeLines.isEmpty) {
      return Container();
    }
    return BlocBuilder<UserDetailsCubit, UserDetailsState>(
        bloc: context.read<UserDetailsCubit>(),
        builder: (context, state) {
          if (state is UserDetailsFetchSuccess) {
            return Align(
              alignment: AlignmentDirectional.center,
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  end: MediaQuery.of(context).size.width * (0.175),
                ),
                child: Text(
                  AppLocalization.of(context)!.getTranslatedValues("coinsLbl")! + ":${state.userProfile.coins}",
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            );
          }
          return Container();
        });
  }

  Widget _buildCurrentQuestionIndex() {
    return Align(
      alignment: AlignmentDirectional.center,
      child: Padding(
        padding: EdgeInsetsDirectional.only(start: widget.lifeLines.isEmpty ? 0 : MediaQuery.of(context).size.width * (0.175)),
        child: Text(
          "${widget.currentQuestionIndex + 1} | ${widget.questions.length}",
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ),
    );
  }

  Widget _buildQuesitonContainer(double scale, int index, bool showContent, BuildContext context) {
    Widget child = LayoutBuilder(builder: (context, constraints) {
      if (widget.questions.isEmpty) {
        return GuessTheWordQuestionContainer(
          key: showContent ? widget.guessTheWordQuestionContainerKeys[widget.currentQuestionIndex] : null,
          submitAnswer: widget.submitAnswer,
          constraints: constraints,
          currentQuestionIndex: widget.currentQuestionIndex,
          questions: widget.guessTheWordQuestions,
        );
      } else {
        if (widget.quizType == QuizTypes.audioQuestions) {
          return AudioQuestionContainer(
            key: widget.audioQuestionContainerKeys![widget.currentQuestionIndex],
            hasSubmittedAnswerForCurrentQuestion: widget.hasSubmittedAnswerForCurrentQuestion,
            constraints: constraints,
            currentQuestionIndex: widget.currentQuestionIndex,
            questions: widget.questions,
            submitAnswer: widget.submitAnswer,
            timerAnimationController: widget.timerAnimationController!,
          );
        }
        Question question = widget.questions[index];
        return SingleChildScrollView(
          child: Column(
            children: [
              widget.quizType == QuizTypes.groupPlay
                  ? SizedBox(
                      height: 22.5,
                    )
                  : SizedBox(),
              Container(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: _buildLevelContainer(),
                    ),
                    _buildCurrentCoins(),
                    _buildCurrentQuestionIndex(),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(end: widget.bookmarkButton.toString() == "Container" ? 0.0 : 30.0),
                        child: IconButton(
                          color: Theme.of(context).colorScheme.secondary,
                          icon: Icon(Icons.settings),
                          onPressed: () {
                            settingDialog();
                          },
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: widget.bookmarkButton,
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Text(
                  "${question.question}",
                  style: TextStyle(height: 1.125, color: Theme.of(context).colorScheme.secondary, fontSize: textSize),
                ),
              ),
              question.imageUrl != null && question.imageUrl!.isNotEmpty
                  ? SizedBox(
                      height: constraints.maxHeight * (0.0175),
                    )
                  : SizedBox(
                      height: constraints.maxHeight * (0.02),
                    ),
              question.imageUrl != null && question.imageUrl!.isNotEmpty
                  ? Container(
                      width: MediaQuery.of(context).size.width,
                      height: constraints.maxHeight * (0.225),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25.0),
                        child: CachedNetworkImage(
                          placeholder: (context, _) {
                            return Center(
                              child: CircularProgressContainer(
                                useWhiteLoader: false,
                              ),
                            );
                          },
                          imageUrl: question.imageUrl!,
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            );
                          },
                          errorWidget: (context, image, error) {
                            print(error.toString());
                            return Center(
                              child: Icon(
                                Icons.error,
                                color: Theme.of(context).primaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : Container(),
              _buildOptions(question, constraints),
              SizedBox(
                height: 15.0,
              ),
            ],
          ),
        );
      }
    });

    return Container(
      child: showContent
          ? SlideTransition(
              position: widget.questionContentAnimation.drive(Tween<Offset>(begin: Offset(0.5, 0.0), end: Offset.zero)),
              child: FadeTransition(
                opacity: widget.questionContentAnimation,
                child: child,
              ),
            )
          : Container(),
      transform: Matrix4.identity()..scale(scale),
      transformAlignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      width: MediaQuery.of(context).size.width * (0.85),
      height: MediaQuery.of(context).size.height * UiUtils.questionContainerHeightPercentage,
      decoration: BoxDecoration(color: Theme.of(context).backgroundColor, borderRadius: BorderRadius.circular(25)),
    );
  }

  Widget _buildQuestion(int questionIndex, BuildContext context) {
    //print(questionIndex);
    //if current question index is same as question index means
    //it is current question and will be on top
    //so we need to add animation that slide and fade this question
    if (widget.currentQuestionIndex == questionIndex) {
      return FadeTransition(
          opacity: widget.questionSlideAnimation.drive(Tween<double>(begin: 1.0, end: 0.0)),
          child: SlideTransition(child: _buildQuesitonContainer(1.0, questionIndex, true, context), position: widget.questionSlideAnimation.drive(Tween<Offset>(begin: Offset.zero, end: Offset(-1.5, 0.0)))));
    }
    //if the question is second or after current question
    //so we need to animation that scale this question
    //initial scale of this question is 0.95

    else if (questionIndex > widget.currentQuestionIndex && (questionIndex == widget.currentQuestionIndex + 1)) {
      return AnimatedBuilder(
          animation: widget.questionAnimationController,
          builder: (context, child) {
            double scale = 0.95 + widget.questionScaleUpAnimation.value - widget.questionScaleDownAnimation.value;
            return _buildQuesitonContainer(scale, questionIndex, false, context);
          });
    }
    //to build question except top 2

    else if (questionIndex > widget.currentQuestionIndex) {
      return _buildQuesitonContainer(1.0, questionIndex, false, context);
    }
    //if the question is already animated that show empty container
    return Container();
  }

  //to build questions
  List<Widget> _buildQuesitons(BuildContext context) {
    List<Widget> children = [];

    //loop terminate condition will be questions.length instead of 4
    for (var i = 0; i < getQuestionsLength(); i++) {
      //add question
      children.add(_buildQuestion(i, context));
    }
    //need to reverse the list in order to display 1st question in top
    children = children.reversed.toList();

    return children;
  }

  @override
  Widget build(BuildContext context) {
    //Font Size change Lister to change questions font size
    return BlocListener<SettingsCubit, SettingsState>(
        bloc: context.read<SettingsCubit>(),
        listener: (context, state) {
          if (state.settingsModel!.playAreaFontSize != textSize) {
            setState(() {
              textSize = context.read<SettingsCubit>().getSettings().playAreaFontSize;
            });
          }
        },
        child: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + (widget.topPadding ?? 7.5),
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              QuestionBackgroundCard(
                opacity: 0.7,
                topMarginPercentage: 0.05,
                widthPercentage: 0.65,
              ),
              QuestionBackgroundCard(
                opacity: 0.85,
                topMarginPercentage: 0.03,
                widthPercentage: 0.75,
              ),
              ..._buildQuesitons(context),
            ],
          ),
        )));
  }
}
