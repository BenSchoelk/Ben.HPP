import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/battleRoom/battleRoomRepository.dart';
import 'package:flutterquiz/features/battleRoom/models/message.dart';

abstract class OpponentMessageState {}

class OpponentMessageFetchedSuccess extends OpponentMessageState {
  final Message message;
  OpponentMessageFetchedSuccess(this.message);
}

class OpponentMessageCubit extends Cubit<OpponentMessageState> {
  final BattleRoomRepository _battleRoomRepository;
  OpponentMessageCubit(this._battleRoomRepository) : super(OpponentMessageFetchedSuccess(Message.buildEmptyMessage()));

  late StreamSubscription streamSubscription;

  //Timer to delete message after it displayed
  Timer? messageDeleteTimer;
  //After 3 seconds message will be delete automatically
  int messageDeleteTimeInSeconds = 3;

  void initOpponentMessagesListener(String roomId, String opponentId) {
    streamSubscription = _battleRoomRepository
        .subscribeToOpponentMessages(
      roomId: roomId,
      by: opponentId,
    )
        .listen((event) async {
      addOpponentMessage(event);
    }, onError: (e) {});
  }

  //to add message
  void addOpponentMessage(Message message) async {
    //if messgae is not empty message
    if (message.messageId.isNotEmpty) {
      if (hasAnyOpponentMessage()) {
        //If any message arrvies with in three seconds
        //then we need to delete the current message
        messageDeleteTimer?.cancel();
        removeOpponentMessage();
        //need to give delay to make animation looks good
        await Future.delayed(Duration(milliseconds: 350)); //message animaiton duration + 50
        _initMessageDeleteTimer();
        emit(OpponentMessageFetchedSuccess(message));
      } else {
        //add message
        _initMessageDeleteTimer();
        emit(OpponentMessageFetchedSuccess(message));
      }
    }
  }

  void removeOpponentMessage() {
    emit(OpponentMessageFetchedSuccess(Message.buildEmptyMessage()));
  }

  void _initMessageDeleteTimer() {
    if (messageDeleteTimeInSeconds != 3) {
      messageDeleteTimeInSeconds = 3;
    }
    messageDeleteTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (messageDeleteTimeInSeconds == 0) {
        timer.cancel();
        removeOpponentMessage();
      } else {
        messageDeleteTimeInSeconds--;
      }
    });
  }

  bool hasAnyOpponentMessage() {
    //if messageId is not empty means one message exist
    return (state as OpponentMessageFetchedSuccess).message.messageId.isNotEmpty;
  }

  @override
  Future<void> close() async {
    streamSubscription.cancel();
    messageDeleteTimer?.cancel();
    super.close();
  }
}
