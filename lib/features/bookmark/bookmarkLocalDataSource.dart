import 'package:flutterquiz/utils/constants.dart';
import 'package:hive/hive.dart';

class BookmarkLocalDataSource {
  Future<void> openBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<String>(boxName);
    }
  }

  Future<void> setAnswerForBookmarkedQuestion(
      String submittedAnswerId, String questionId) async {
    //key will be questionId and value for this key will be submittedAsnwerId
    await openBox(bookmarkBox);
    final box = Hive.box<String>(bookmarkBox);
    await box.put(questionId, submittedAnswerId);
  }

  Future<void> setAnswerForAudioBookmarkedQuestion(
      String submittedAnswerId, String questionId) async {
    //key will be questionId and value for this key will be submittedAsnwerId
    await openBox(audioBookmarkBox);
    final box = Hive.box<String>(audioBookmarkBox);
    await box.put(questionId, submittedAnswerId);
  }

  Future<void> setAnswerForGuessTheWordBookmarkedQuestion(
      String submittedAnswer, String questionId) async {
    //key will be questionId and value for this key will be submittedAsnwer
    await openBox(guessTheWordBookmarkBox);
    final box = Hive.box<String>(guessTheWordBookmarkBox);
    await box.put(questionId, submittedAnswer);
  }

  Future<List<String>> getAnswerOfBookmarkedQuestion(
      List<String?> questionIds) async {
    List<String> submittedAnswerIds = [];
    await openBox(bookmarkBox);
    final box = Hive.box<String>(bookmarkBox);

    questionIds.forEach((element) {
      submittedAnswerIds.add(box.get(element, defaultValue: "")!);
    });
    return submittedAnswerIds;
  }

  Future<List<String>> getAnswerOfAudioBookmarkedQuestion(
      List<String?> questionIds) async {
    List<String> submittedAnswerIds = [];
    await openBox(audioBookmarkBox);
    final box = Hive.box<String>(audioBookmarkBox);

    questionIds.forEach((element) {
      submittedAnswerIds.add(box.get(element, defaultValue: "")!);
    });
    return submittedAnswerIds;
  }

  Future<List<String>> getAnswerOfGuessTheWordBookmarkedQuestion(
      List<String> questionIds) async {
    List<String> submittedAnswerIds = [];
    await openBox(guessTheWordBookmarkBox);
    final box = Hive.box<String>(guessTheWordBookmarkBox);

    questionIds.forEach((element) {
      submittedAnswerIds.add(box.get(element, defaultValue: "")!);
    });
    return submittedAnswerIds;
  }

  Future<void> removeBookmarkedAnswer(String? questionId) async {
    await openBox(bookmarkBox);
    final box = Hive.box<String>(bookmarkBox);
    await box.delete(questionId);
  }

  Future<void> removeAudioBookmarkedAnswer(String? questionId) async {
    await openBox(audioBookmarkBox);
    final box = Hive.box<String>(audioBookmarkBox);
    await box.delete(questionId);
  }

  Future<void> removeGuessTheWordBookmarkedAnswer(String questionId) async {
    await openBox(bookmarkBox);
    final box = Hive.box<String>(guessTheWordBookmarkBox);
    await box.delete(questionId);
  }
}
