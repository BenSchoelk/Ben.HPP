import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/utils/stringLabels.dart';

final List<QuizType> quizTypes = [
  //title will be the key of localization for quizType title
  QuizType(title: quizZone, image: "quizzone_icon.svg", active: true, description: desQuizZone),
  QuizType(title: battleQuiz, image: "battle_quiz.svg", active: true, description: desBattleQuiz),
  QuizType(title: contest, image: "contests_icon.svg", active: true, description: desContest),
  QuizType(title: groupPlay, image: "groupplay_icon.svg", active: true, description: desGroupPlay),
  QuizType(title: guessTheWord, image: "Guess the word.svg", active: true, description: desGuessTheWord),
  QuizType(title: funAndLearn, image: "fun_nlearn.svg", active: true, description: desFunAndLearn),
  QuizType(title: trueAndFalse, image: "true_false_icon.svg", active: true, description: desTrueAndFalse),
  QuizType(title: dailyQuiz, image: "daily_quiz.svg", active: true, description: desDailyQuiz),
  QuizType(title: mathManiaKey, image: "daily_quiz.svg", active: true, description: desMathManiaKey),
  QuizType(title: audioRoomKey, image: "daily_quiz.svg", active: true, description: desAudioRoomKey),
];
