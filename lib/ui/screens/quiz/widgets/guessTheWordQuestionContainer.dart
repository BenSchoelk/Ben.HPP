import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/features/quiz/models/guessTheWordQuestion.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainner.dart';
import 'package:flutterquiz/ui/widgets/settingsDialogContainer.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GuessTheWordQuestionContainer extends StatefulWidget {
  final BoxConstraints constraints;
  final int currentQuestionIndex;
  final List<GuessTheWordQuestion> questions;
  final Function submitAnswer;
  GuessTheWordQuestionContainer({Key? key, required this.currentQuestionIndex, required this.questions, required this.constraints, required this.submitAnswer}) : super(key: key);

  @override
  GuessTheWordQuestionContainerState createState() => GuessTheWordQuestionContainerState();
}

class GuessTheWordQuestionContainerState extends State<GuessTheWordQuestionContainer> with TickerProviderStateMixin {
  final optionBoxContainerHeight = 40.0;
  double textSize = 14;
  //contains ontionIndex.. stroing index so we can lower down the opacity of selected index
  late List<int> submittedAnswer = [];
  //to controll the answer text
  late List<AnimationController> controllers = [];
  late List<Animation<double>> animations = [];
  //
  //to control the bottomBorder animation
  late List<AnimationController> bottomBorderAnimationControllers = [];
  late List<Animation<double>> bottomBorderAnimations = [];
  //
  //to control the topContainer animation
  late List<AnimationController> topContainerAnimationControllers = [];
  late List<Animation<double>> topContainerAnimations = [];

  late int currentSelectedIndex = 0;

  late AssetsAudioPlayer assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    initializeAnimation();
  }

  @override
  void dispose() {
    controllers.forEach((element) {
      element.dispose();
    });
    topContainerAnimationControllers.forEach((element) {
      element.dispose();
    });
    bottomBorderAnimationControllers.forEach((element) {
      element.dispose();
    });
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  List<String> getSubmittedAnswer() {
    return submittedAnswer.map((e) => e == -1 ? "" : widget.questions[widget.currentQuestionIndex].options[e]).toList();
  }

  void initializeAnimation() {
    //initalize the animation
    for (int i = 0; i < widget.questions[widget.currentQuestionIndex].submittedAnswer.length; i++) {
      submittedAnswer.add(-1);
      controllers.add(AnimationController(vsync: this, duration: Duration(milliseconds: 150)));
      animations.add(Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: controllers[i], curve: Curves.linear, reverseCurve: Curves.linear)));
      topContainerAnimationControllers.add(AnimationController(vsync: this, duration: Duration(milliseconds: 150)));
      topContainerAnimations.add(Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: topContainerAnimationControllers[i], curve: Curves.linear)));
      bottomBorderAnimationControllers.add(AnimationController(vsync: this, duration: Duration(milliseconds: 150)));
      bottomBorderAnimations.add(Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: bottomBorderAnimationControllers[i], curve: Curves.linear)));
    }
    bottomBorderAnimationControllers.first.forward();
  }

  void changeCurrentSelectedAnswerBox(int answerBoxIndex) {
    setState(() {
      currentSelectedIndex = answerBoxIndex;
    });
    bottomBorderAnimationControllers[answerBoxIndex].forward();
    for (var controller in bottomBorderAnimationControllers) {
      if (controller.isCompleted) {
        controller.reverse();
        break;
      }
    }
  }

  void playSound(String trackName) {
    if (context.read<SettingsCubit>().getSettings().sound) {
      if (assetsAudioPlayer.isPlaying.value) {
        assetsAudioPlayer.stop();
      }
      assetsAudioPlayer.open(Audio("$trackName"));
      assetsAudioPlayer.play();
    }
  }

  void playVibrate() async {
    if (context.read<SettingsCubit>().getSettings().vibration) {
      UiUtils.vibrate();
    }
  }

  Widget _buildAnswerBox(int answerBoxIndex) {
    return GestureDetector(
      onTap: () {
        changeCurrentSelectedAnswerBox(answerBoxIndex);
      },
      child: AnimatedBuilder(
        animation: bottomBorderAnimationControllers[answerBoxIndex],
        builder: (context, child) {
          double border = bottomBorderAnimations[answerBoxIndex].drive(Tween<double>(begin: 1.0, end: 2.5)).value;

          return Container(
            clipBehavior: Clip.hardEdge,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(border: Border(bottom: BorderSide(width: border, color: currentSelectedIndex == answerBoxIndex ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary))),
            margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.5),
            height: optionBoxContainerHeight,
            width: 35.0,
            child: AnimatedBuilder(
              animation: controllers[answerBoxIndex],
              builder: (context, child) {
                return controllers[answerBoxIndex].status == AnimationStatus.reverse
                    ? Opacity(
                        opacity: animations[answerBoxIndex].value,
                        child: FractionalTranslation(
                          translation: Offset(0.0, 1.0 - animations[answerBoxIndex].value),
                          child: child,
                        ),
                      )
                    : FractionalTranslation(
                        translation: Offset(0.0, 1.0 - animations[answerBoxIndex].value),
                        child: child,
                      );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: topContainerAnimationControllers[answerBoxIndex],
                    builder: (context, child) {
                      return Container(
                        height: 2.0,
                        width: 35.0 * (1.0 - topContainerAnimations[answerBoxIndex].value),
                        color: currentSelectedIndex == answerBoxIndex ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary,
                      );
                    },
                  ),
                  Text(
                    //submitted answer contains the index of option
                    //length of answerbox is same as submittedAnswer

                    submittedAnswer[answerBoxIndex] == -1 ? "" : widget.questions[widget.currentQuestionIndex].options[submittedAnswer[answerBoxIndex]],
                    //
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color: currentSelectedIndex == answerBoxIndex ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnswerBoxes() {
    List<Widget> children = [];
    for (var i = 0; i < widget.questions[widget.currentQuestionIndex].submittedAnswer.length; i++) {
      children.add(_buildAnswerBox(i));
    }
    return Wrap(
      children: children,
    );
  }

  Widget _optionContainer(String letter, int optionIndex) {
    return GestureDetector(
      onTap: submittedAnswer.contains(optionIndex)
          ? () {}
          : () async {
              playVibrate();
              //! menas we need to add back button
              if (letter == "!") {
                await topContainerAnimationControllers[currentSelectedIndex].reverse();
                await controllers[currentSelectedIndex].reverse();
                setState(() {
                  submittedAnswer[currentSelectedIndex] = -1;
                });
              } else {
                if (submittedAnswer[currentSelectedIndex] != -1) {
                  await topContainerAnimationControllers[currentSelectedIndex].reverse();
                  await controllers[currentSelectedIndex].reverse();
                }
                await Future.delayed(Duration(milliseconds: 25));

                //adding new letter
                setState(() {
                  submittedAnswer[currentSelectedIndex] = optionIndex;
                });

                await controllers[currentSelectedIndex].forward();
                await topContainerAnimationControllers[currentSelectedIndex].forward();
                //update currentAnswerBox

                if (currentSelectedIndex != widget.questions[widget.currentQuestionIndex].submittedAnswer.length - 1) {
                  changeCurrentSelectedAnswerBox(currentSelectedIndex + 1);
                }
              }
            },
      child: Opacity(
        opacity: submittedAnswer.contains(optionIndex) ? 0.5 : 1.0,
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0), color: Theme.of(context).primaryColor),
          height: optionBoxContainerHeight,
          width: optionBoxContainerHeight,
          child: letter == "!"
              ? Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).backgroundColor,
                )
              : Text(
                  letter,
                  style: TextStyle(
                    color: Theme.of(context).backgroundColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildOptions(List<String> answerOptions) {
    List<Widget> listOfWidgets = [];

    for (var i = 0; i < answerOptions.length; i++) {
      listOfWidgets.add(_optionContainer(answerOptions[i], i));
    }

    return Wrap(
      children: listOfWidgets,
    );
  }

  Widget _buildAnswerCorrectness() {
    bool correctAnswer = UiUtils.buildGuessTheWordQuestionAnswer(getSubmittedAnswer()) == widget.questions[widget.currentQuestionIndex].answer;
    if (correctAnswer) {
      playSound(correctAnswerSoundTrack);
    } else {
      playSound(wrongAnswerSoundTrack);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: correctAnswer ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary,
          radius: 20,
          child: Center(
            child: Icon(correctAnswer ? Icons.check : Icons.close, color: Theme.of(context).backgroundColor),
          ),
        ),
        SizedBox(
          height: 5.0,
        ),
        Text(
          UiUtils.buildGuessTheWordQuestionAnswer(getSubmittedAnswer()),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: correctAnswer ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary,
            fontSize: 20.0,
            letterSpacing: 1.0,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[widget.currentQuestionIndex];
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
          child: Column(
            children: [
              Container(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "${widget.currentQuestionIndex + 1} | ${widget.questions.length}",
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: IconButton(
                        color: Theme.of(context).colorScheme.secondary,
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          showDialog(context: context, builder: (context) => SettingsDialogContainer());
                        },
                      ),
                    ),
                  ],
                ),
              ),
              //
              Container(
                alignment: Alignment.center,
                child: Text(
                  "${question.question}",
                  style: TextStyle(height: 1.125, fontSize: textSize, color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              SizedBox(
                height: widget.constraints.maxHeight * (0.025),
              ),
              question.image.isNotEmpty
                  ? Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25.0)),
                      width: MediaQuery.of(context).size.width,
                      height: widget.constraints.maxHeight * (0.275),
                      alignment: Alignment.center,
                      child: CachedNetworkImage(
                        placeholder: (context, _) {
                          return Center(
                            child: CircularProgressContainer(
                              useWhiteLoader: false,
                            ),
                          );
                        },
                        imageUrl: question.image,
                        imageBuilder: (context, imageProvider) {
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                          );
                        },
                        errorWidget: (context, image, _) => Center(
                          child: Icon(
                            Icons.error,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(
                height: widget.constraints.maxHeight * (0.025),
              ),
              AnimatedSwitcher(duration: Duration(milliseconds: 300), child: widget.questions[widget.currentQuestionIndex].hasAnswered ? _buildAnswerCorrectness() : _buildAnswerBoxes()),
              SizedBox(
                height: widget.constraints.maxHeight * (0.04),
              ),
              _buildOptions(question.options),
              SizedBox(
                height: 15.0,
              ),
            ],
          ),
        ));
  }
}
