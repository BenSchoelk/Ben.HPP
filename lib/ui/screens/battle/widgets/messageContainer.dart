import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/messageCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/models/message.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'dart:ui' as ui;

class MessageContainer extends StatelessWidget {
  final bool isCurrentUser;
  final QuizTypes quizType;
  final int? opponentUserIndex;
  const MessageContainer({Key? key, this.opponentUserIndex, required this.isCurrentUser, required this.quizType}) : super(key: key);

  Widget _buildMessage(BuildContext context, MessageState messageState) {
    if (messageState is MessageFetchedSuccess) {
      //if no message has exchanged
      if (messageState.messages.isEmpty) {
        return Container();
      }
      Message message = Message.buildEmptyMessage();

      String currentUserId = context.read<UserDetailsCubit>().getUserId();

      if (quizType == QuizTypes.battle) {
        BattleRoomCubit battleRoomCubit = context.read<BattleRoomCubit>();
        if (isCurrentUser) {
          //get current user's latest message
          message = context.read<MessageCubit>().getUserLatestMessage(battleRoomCubit.getCurrentUserDetails(currentUserId).uid);
        } else {
          //get opponent user's latest message
          message = context.read<MessageCubit>().getUserLatestMessage(battleRoomCubit.getOpponentUserDetails(currentUserId).uid);
        }
      } else {
        MultiUserBattleRoomCubit battleRoomCubit = context.read<MultiUserBattleRoomCubit>();
        if (isCurrentUser) {
          //get current user's latest message
          message = context.read<MessageCubit>().getUserLatestMessage(battleRoomCubit.getUser(currentUserId)!.uid);
        } else {
          //get opponent user's latest message
          String opponentUserId = battleRoomCubit.getOpponentUsers(currentUserId)[opponentUserIndex!]!.uid;
          message = context.read<MessageCubit>().getUserLatestMessage(battleRoomCubit.getUser(opponentUserId)!.uid);
        }
      }

      return Container(
        // decoration: BoxDecoration(boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.3),
        //     spreadRadius: 5,
        //     blurRadius: 7,
        //     offset: Offset(0, 3), // changes position of shadow
        //   ),
        // ]),
        key: message.isTextMessage ? Key("textMessage") : Key("nonTextMessage"),
        padding: message.isTextMessage ? EdgeInsets.symmetric(horizontal: 15.0) : EdgeInsets.symmetric(vertical: 7.5),
        alignment: Alignment.center,
        height: 42.5,
        width: MediaQuery.of(context).size.width * (message.isTextMessage ? 0.45 : 0.4),
        child: message.isTextMessage
            ? Text(
                message.message,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary, fontSize: 13.5, height: 1.05),
              )
            : SvgPicture.asset(
                UiUtils.getEmojiPath(message.message),
                color: Theme.of(context).colorScheme.secondary,
              ),
      );
    }
    return Container();
  }

  CustomPainter _buildGroupBattleCustomPainter(BuildContext context) {
    if (isCurrentUser || opponentUserIndex == 0) {
      return MessageCustomPainter(
        triangleIsLeft: isCurrentUser,
        firstGradientColor: Theme.of(context).scaffoldBackgroundColor,
        secondGradientColor: Theme.of(context).canvasColor,
      );
    }

    return TopMessageCustomPainter(
      triangleIsLeft: opponentUserIndex == 1,
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: quizType == QuizTypes.battle
          ? MessageCustomPainter(
              triangleIsLeft: isCurrentUser,
              firstGradientColor: Theme.of(context).scaffoldBackgroundColor,
              secondGradientColor: Theme.of(context).canvasColor,
            )
          : _buildGroupBattleCustomPainter(context),
      child: BlocBuilder<MessageCubit, MessageState>(
        bloc: context.read<MessageCubit>(),
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 175),
            child: _buildMessage(context, state),
          );
        },
      ),
    );
  }
}

class TopMessageCustomPainter extends CustomPainter {
  final bool triangleIsLeft;
  final Color color;

  TopMessageCustomPainter({required this.triangleIsLeft, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();

    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    path.moveTo(size.width * (0.1), 0);
    path.lineTo(size.width * (triangleIsLeft ? 0.35 : 0.65), 0);
    path.lineTo(size.width * (triangleIsLeft ? 0.25 : 0.75), size.height - size.height * (1.3)); //75,25
    path.lineTo(size.width * (triangleIsLeft ? 0.15 : 0.85), 0); //85,15

    //
    path.lineTo(size.width * (0.9), 0);
    //add curve effect
    path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.2);
    path.lineTo(size.width, size.height * (0.8));
    //add curve
    path.quadraticBezierTo(size.width, size.height, size.width * (0.9), size.height);
    path.lineTo(size.width * (0.1), size.height);
    //add curve
    path.quadraticBezierTo(0, size.height, 0, size.height * (0.8));
    path.lineTo(0, size.height * (0.2));
    //add curve
    path.quadraticBezierTo(0, 0, size.width * (0.1), 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MessageCustomPainter extends CustomPainter {
  final bool triangleIsLeft;
  final Color firstGradientColor;

  final Color secondGradientColor;

  MessageCustomPainter({required this.triangleIsLeft, required this.firstGradientColor, required this.secondGradientColor});

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();

    Paint paint = Paint()
      ..shader = ui.Gradient.linear(Offset(size.width * (0.5), 0), Offset(size.width * (0.5), size.height), [firstGradientColor, secondGradientColor])
      ..style = PaintingStyle.fill;

    path.moveTo(size.width * (0.1), 0);
    path.lineTo(size.width * (0.9), 0);
    //add curve effect
    path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.2);
    path.lineTo(size.width, size.height * (0.8));
    //add curve
    path.quadraticBezierTo(size.width, size.height, size.width * (0.9), size.height);
    //add triangle here
    path.lineTo(size.width * (triangleIsLeft ? 0.25 : 0.75), size.height);
    //to add how long triangle will go down
    path.lineTo(size.width * (triangleIsLeft ? 0.2 : 0.8), size.height * (1.3));
    //
    path.lineTo(size.width * (triangleIsLeft ? 0.15 : 0.85), size.height);
    //
    path.lineTo(size.width * (0.1), size.height);
    //add curve
    path.quadraticBezierTo(0, size.height, 0, size.height * (0.8));
    path.lineTo(0, size.height * (0.2));
    //add curve
    path.quadraticBezierTo(0, 0, size.width * (0.1), 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
