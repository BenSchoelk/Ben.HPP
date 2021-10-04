import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/battleRoom/battleRoomRepository.dart';
import 'package:flutterquiz/features/battleRoom/models/battleRoom.dart';
import 'package:flutterquiz/features/quiz/models/question.dart';
import 'package:flutterquiz/features/quiz/models/userBattleRoomDetails.dart';

import 'package:flutterquiz/utils/errorMessageKeys.dart';

@immutable
class BattleRoomState {}

class BattleRoomInitial extends BattleRoomState {}

class BattleRoomSearchInProgress extends BattleRoomState {}

class BattleRoomDeleted extends BattleRoomState {}

class BattleRoomJoining extends BattleRoomState {}

class BattleRoomCreating extends BattleRoomState {}

class BattleRoomCreated extends BattleRoomState {
  final BattleRoom battleRoom;
  BattleRoomCreated(this.battleRoom);
}

class BattleRoomUserFound extends BattleRoomState {
  final BattleRoom battleRoom;
  final bool hasLeft;
  final List<Question> questions;

  BattleRoomUserFound({required this.battleRoom, required this.hasLeft, required this.questions});
}

class BattleRoomFailure extends BattleRoomState {
  final String errorMessageCode;
  BattleRoomFailure(this.errorMessageCode);
}

class BattleRoomCubit extends Cubit<BattleRoomState> {
  final BattleRoomRepository _battleRoomRepository;
  BattleRoomCubit(this._battleRoomRepository) : super(BattleRoomInitial());

  StreamSubscription<DocumentSnapshot>? _battleRoomStreamSubscription;

  //subscribe battle room
  void subscribeToBattleRoom(String battleRoomDocumentId, List<Question> questions) {
    //for realtimeness
    _battleRoomStreamSubscription = _battleRoomRepository.subscribeToBattleRoom(battleRoomDocumentId, false).listen((event) {
      if (event.exists) {
        //emit new state
        BattleRoom battleRoom = BattleRoom.fromDocumentSnapshot(event);
        bool? userNotFound = battleRoom.user2?.uid.isEmpty;
        if (userNotFound == true) {
          //emit(BattleRoomCreated(battleRoom));
        } else {
          emit(BattleRoomUserFound(
            battleRoom: battleRoom,
            hasLeft: false,
            questions: questions,
          ));
        }
      } else {
        if (state is BattleRoomUserFound) {
          //if one of the user has left the game while playing
          emit(
            BattleRoomUserFound(battleRoom: (state as BattleRoomUserFound).battleRoom, hasLeft: true, questions: (state as BattleRoomUserFound).questions),
          );
        }
      }
    }, onError: (e) {
      emit(BattleRoomFailure(defaultErrorMessageCode));
    }, cancelOnError: true);
  }

  void searchRoom({required String categoryId, required String name, required String profileUrl, required String uid, required String questionLanguageId}) async {
    emit(BattleRoomSearchInProgress());
    try {
      List<DocumentSnapshot> documents = await _battleRoomRepository.searchBattleRoom(
        questionLanguageId: questionLanguageId,
        categoryId: categoryId,
        name: name,
        profileUrl: profileUrl,
        uid: uid,
      );

      if (documents.isNotEmpty) {
        //find any random room
        DocumentSnapshot room = documents[Random.secure().nextInt(documents.length)];
        emit(BattleRoomJoining());
        List<Question> questions = await _battleRoomRepository.getQuestions(
          categoryId: categoryId,
          matchId: room.id,
          forMultiUser: false,
          roomDocumentId: room.id,
          languageId: questionLanguageId,
          roomCreater: false,
        );
        await _battleRoomRepository.joinBattleRoom(battleRoomDocumentId: room.id, name: name, profileUrl: profileUrl, uid: uid);
        subscribeToBattleRoom(room.id, questions);
      } else {
        emit(BattleRoomCreating());

        final createdRoomDocument = await _battleRoomRepository.createBattleRoom(
          categoryId: categoryId,
          name: name,
          profileUrl: profileUrl,
          uid: uid,
          questionLanguageId: questionLanguageId,
        );
        emit(BattleRoomCreated(BattleRoom.fromDocumentSnapshot(createdRoomDocument)));
        List<Question> questions = await _battleRoomRepository.getQuestions(
          categoryId: categoryId,
          matchId: createdRoomDocument.id,
          forMultiUser: false,
          roomDocumentId: createdRoomDocument.id,
          languageId: questionLanguageId,
          roomCreater: true,
        );
        print(questions.length);
        subscribeToBattleRoom(createdRoomDocument.id, questions);
      }
    } catch (e) {
      emit(BattleRoomFailure(e.toString()));
    }
  }

  //this will be call when user submit answer and marked questions attempted
  //if time expired for given question then default "-1" answer will be submitted
  void updateQuestionAnswer(String? questionId, String? submittedAnswerId) {
    if (state is BattleRoomUserFound) {
      List<Question> updatedQuestions = (state as BattleRoomUserFound).questions;
      //fetching index of question that need to update with submittedAnswer
      int questionIndex = updatedQuestions.indexWhere((element) => element.id == questionId);
      //update question at given questionIndex with submittedAnswerId
      updatedQuestions[questionIndex] = updatedQuestions[questionIndex].updateQuestionWithAnswer(submittedAnswerId: submittedAnswerId!);
      emit(BattleRoomUserFound(
        hasLeft: (state as BattleRoomUserFound).hasLeft,
        battleRoom: (state as BattleRoomUserFound).battleRoom,
        questions: updatedQuestions,
      ));
    }
  }

  //delete room after qutting the game or finishing the game
  void deleteBattleRoom() {
    if (state is BattleRoomUserFound) {
      _battleRoomRepository.deleteBattleRoom((state as BattleRoomUserFound).battleRoom.roomId, false);
      emit(BattleRoomDeleted());
    } else if (state is BattleRoomCreated) {
      _battleRoomRepository.deleteBattleRoom((state as BattleRoomCreated).battleRoom.roomId, false);
      emit(BattleRoomDeleted());
    }
  }

  //submit anser
  void submitAnswer(String? currentUserId, String? submittedAnswer, bool isCorrectAnswer, int points) {
    if (state is BattleRoomUserFound) {
      BattleRoom battleRoom = (state as BattleRoomUserFound).battleRoom;
      List<Question>? questions = (state as BattleRoomUserFound).questions;

      //need to check submitting answer for user1 or user2
      if (currentUserId == battleRoom.user1!.uid) {
        if (battleRoom.user1!.answers.length != questions.length) {
          _battleRoomRepository.submitAnswer(
            battleRoomDocumentId: battleRoom.roomId,
            points: isCorrectAnswer ? (battleRoom.user1!.points + points) : battleRoom.user1!.points,
            forUser1: true,
            submittedAnswer: List.from(battleRoom.user1!.answers)..add(submittedAnswer),
          );
        }
      } else {
        //submit answer for user2
        if (battleRoom.user2!.answers.length != questions.length) {
          _battleRoomRepository.submitAnswer(
            submittedAnswer: List.from(battleRoom.user2!.answers)..add(submittedAnswer),
            battleRoomDocumentId: battleRoom.roomId,
            points: isCorrectAnswer ? (battleRoom.user2!.points + points) : battleRoom.user2!.points,
            forUser1: false,
          );
        }
      }
    }
  }

  //currentQuestionIndex will be same as given answers length(since index start with 0 in arrary)
  int getCurrentQuestionIndex() {
    if (state is BattleRoomUserFound) {
      final currentState = (state as BattleRoomUserFound);
      int currentQuestionIndex;

      //if both users has submitted answer means currentQuestionIndex will be
      //as (answers submitted by users) + 1
      if (currentState.battleRoom.user1!.answers.length == currentState.battleRoom.user2!.answers.length) {
        currentQuestionIndex = currentState.battleRoom.user1!.answers.length;
      } else if (currentState.battleRoom.user1!.answers.length < currentState.battleRoom.user2!.answers.length) {
        currentQuestionIndex = currentState.battleRoom.user1!.answers.length;
      } else {
        currentQuestionIndex = currentState.battleRoom.user2!.answers.length;
      }

      //need to decrease index by one in order to remove index out of range error
      //after game has finished
      if (currentQuestionIndex == currentState.questions.length) {
        currentQuestionIndex--;
      }
      return currentQuestionIndex;
    }

    return 0;
  }

  //get questions in quiz battle
  List<Question> getQuestions() {
    if (state is BattleRoomUserFound) {
      return (state as BattleRoomUserFound).questions;
    }
    return [];
  }

  String getRoomId() {
    if (state is BattleRoomUserFound) {
      return (state as BattleRoomUserFound).battleRoom.roomId!;
    }
    return "";
  }

  UserBattleRoomDetails getCurrentUserDetails(String currentUserId) {
    if (state is BattleRoomUserFound) {
      if (currentUserId == (state as BattleRoomUserFound).battleRoom.user1?.uid) {
        return (state as BattleRoomUserFound).battleRoom.user1!;
      } else {
        return (state as BattleRoomUserFound).battleRoom.user2!;
      }
    }
    return UserBattleRoomDetails(answers: [], correctAnswers: 0, name: "name", profileUrl: "profileUrl", uid: "uid", points: 0);
  }

  UserBattleRoomDetails getOpponentUserDetails(String currentUserId) {
    if (state is BattleRoomUserFound) {
      if (currentUserId == (state as BattleRoomUserFound).battleRoom.user1?.uid) {
        return (state as BattleRoomUserFound).battleRoom.user2!;
      } else {
        return (state as BattleRoomUserFound).battleRoom.user1!;
      }
    }
    return UserBattleRoomDetails(points: 0, answers: [], correctAnswers: 0, name: "name", profileUrl: "profileUrl", uid: "uid");
  }

  //to close the stream subsciption
  @override
  Future<void> close() async {
    await _battleRoomStreamSubscription?.cancel();
    return super.close();
  }
}
