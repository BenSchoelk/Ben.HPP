import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/battleRoom/battleRoomRepository.dart';
import 'package:flutterquiz/features/battleRoom/models/message.dart';

abstract class MessageState {}

class MessageInitial extends MessageState {}

class MessageAddInProgress extends MessageState {}

class MessageFetchedSuccess extends MessageState {
  final List<Message> messages;
  MessageFetchedSuccess(this.messages);
}

class MessageAddedFailure extends MessageState {
  String errorCode;
  MessageAddedFailure(this.errorCode);
}

class MessageCubit extends Cubit<MessageState> {
  final BattleRoomRepository _battleRoomRepository;
  MessageCubit(this._battleRoomRepository) : super(MessageFetchedSuccess(List<Message>.from([])));

  late StreamSubscription streamSubscription;

  //subscribe to messages stream
  void subscribeToMessages(String roomId) {
    streamSubscription = _battleRoomRepository.subscribeToMessages(roomId: roomId).listen((message) {
      if (message.messageId.isNotEmpty) {
        final messages = List<Message>.from((state as MessageFetchedSuccess).messages);
        messages.add(message);
        emit(MessageFetchedSuccess(messages));
      }
    });
  }

  void addMessage({required String message, required by, required roomId, required isTextMessage}) async {
    try {
      Message messageModel = Message(
        by: by,
        isTextMessage: isTextMessage,
        message: message,
        messageId: "",
        roomId: roomId,
        timestamp: Timestamp.now(),
      );
      await _battleRoomRepository.addMessage(messageModel);
    } catch (e) {
      emit(MessageAddedFailure(e.toString()));
    }
  }

  void deleteMessages(String roomId, String by) {
    _battleRoomRepository.deleteMessagesByUserId(roomId, by);
  }

  @override
  Future<void> close() async {
    streamSubscription.cancel();
    super.close();
  }
}
