import 'package:flutterquiz/utils/constants.dart';
import 'package:hive/hive.dart';

class BookmarkLocalDataSource {
  Future<void> openBox() async {
    if (!Hive.isBoxOpen(bookmarkBox)) {
      await Hive.openBox<String>(bookmarkBox);
    }
  }

  Future<void> setAnswerForBookmarkedQuestion(String submittedAnswerId, String questionId) async {
    //key will be questionId and value for this key will be submittedAsnwerId
    await openBox();
    final box = Hive.box<String>(bookmarkBox);
    await box.put(questionId, submittedAnswerId);
  }

  Future<List<String>> getAnswerOfBookmarkedQuestion(List<String?> questionIds) async {
    List<String> submittedAnswerIds = [];
    await openBox();
    final box = Hive.box<String>(bookmarkBox);

    questionIds.forEach((element) {
      submittedAnswerIds.add(box.get(element, defaultValue: "")!);
    });
    return submittedAnswerIds;
  }

  Future<void> removeBookmarkedAnswer(String? questionId) async {
    await openBox();
    final box = Hive.box<String>(bookmarkBox);
    await box.delete(questionId);
  }
}
