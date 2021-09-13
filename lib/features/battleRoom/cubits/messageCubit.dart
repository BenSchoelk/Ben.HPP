import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/battleRoom/battleRoomRepository.dart';
import 'package:flutterquiz/features/battleRoom/models/message.dart';

abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageAddInProgress extends MessageState {}

class MessageAddedSuccess extends MessageState {
  final Message message;
  MessageAddedSuccess(this.message);
}

class MessageAddedFailure extends MessageState {
  String errorCode;
  MessageAddedFailure(this.errorCode);
}

class MessageCubit extends Cubit<MessageState> {
  final BattleRoomRepository _battleRoomRepository;
  MessageCubit(this._battleRoomRepository) : super(MessageInitial());

  //Timer to delete message after it displayed
  Timer? messageDeleteTimer;
  //After 3 seconds message will be delete automatically
  int messageDeleteTimeInSeconds = 3;

  void addMessage({required String message, required by, required roomId, required isTextMessage}) async {
    try {
      emit(MessageAddInProgress());
      Message messageModel = Message(
        by: by,
        isTextMessage: isTextMessage,
        message: message,
        messageId: "",
        roomId: roomId,
        timestamp: Timestamp.now(),
      );
      String messageId = await _battleRoomRepository.addMessage(messageModel);

      //if there is any previous message then delete that message
      if (hasAnyMessage()) {
        //cancel timer and delete the current message
        messageDeleteTimer?.cancel();
        removeMessage();
        //need to add delay in order to make messgae animation good
        await Future.delayed(Duration(milliseconds: 350));
        _initMessageDeleteTimer();
        emit(MessageAddedSuccess(messageModel.copyWith(messageDocumentId: messageId)));
      } else {
        _initMessageDeleteTimer();
        emit(MessageAddedSuccess(messageModel.copyWith(messageDocumentId: messageId)));
      }
    } catch (e) {
      emit(MessageAddedFailure(e.toString()));
    }
  }

  void removeMessage() {
    if (state is MessageAddedSuccess) {
      _battleRoomRepository.deleteMessage((state as MessageAddedSuccess).message);
      emit(MessageAddedSuccess(Message.buildEmptyMessage()));
    }
  }

  void _initMessageDeleteTimer() {
    if (messageDeleteTimeInSeconds != 3) {
      messageDeleteTimeInSeconds = 3;
    }
    messageDeleteTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (messageDeleteTimeInSeconds == 0) {
        timer.cancel();
        removeMessage();
      } else {
        messageDeleteTimeInSeconds--;
      }
    });
  }

  bool hasAnyMessage() {
    if (state is MessageAddedSuccess) {
      return (state as MessageAddedSuccess).message.messageId.isNotEmpty;
    }
    return false;
  }

  void deleteMessages(String roomId, String by) {
    _battleRoomRepository.deleteMessagesByUserId(roomId, by);
  }

  @override
  Future<void> close() async {
    messageDeleteTimer?.cancel();
    super.close();
  }
}
