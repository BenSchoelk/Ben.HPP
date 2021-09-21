import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/messageCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';

class MessageContainer extends StatelessWidget {
  final bool isCurrentUser;
  const MessageContainer({Key? key, required this.isCurrentUser}) : super(key: key);

  Widget _buildMessage(BuildContext context, MessageState messageState) {
    if (messageState is MessageFetchedSuccess) {
      //if no message has exchanged
      if (messageState.messages.isEmpty) {
        return Container();
      }
      String message = "";
      BattleRoomCubit battleRoomCubit = context.read<BattleRoomCubit>();
      String currentUserId = context.read<UserDetailsCubit>().getUserId();
      if (isCurrentUser) {
        //get current user's latest message
        message = context.read<MessageCubit>().getUserLatestMessage(battleRoomCubit.getCurrentUserDetails(currentUserId).uid).message;
      } else {
        //get opponent user's latest message
        message = context.read<MessageCubit>().getUserLatestMessage(battleRoomCubit.getOpponentUserDetails(currentUserId).uid).message;
      }

      return Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: 13.5, height: 1.0),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MessageCustomPainter(
        triangleIsLeft: isCurrentUser,
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        alignment: Alignment.center,
        child: BlocBuilder<MessageCubit, MessageState>(
          bloc: context.read<MessageCubit>(),
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 175),
              child: _buildMessage(context, state),
            );
          },
        ),
        height: 40,
        width: MediaQuery.of(context).size.width * (0.45),
      ),
    );
  }
}

class MessageCustomPainter extends CustomPainter {
  final bool triangleIsLeft;
  final Color color;

  MessageCustomPainter({required this.triangleIsLeft, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();

    Paint paint = Paint()
      ..color = color
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
