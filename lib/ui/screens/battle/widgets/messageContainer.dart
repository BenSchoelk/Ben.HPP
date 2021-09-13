import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/battleRoom/cubits/messageCubit.dart';

class MessageContainer extends StatelessWidget {
  const MessageContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MessageCustomPainter(
        triangleIsLeft: true,
        color: Theme.of(context).primaryColor,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        alignment: Alignment.center,
        child: BlocBuilder<MessageCubit, MessageState>(
          bloc: context.read<MessageCubit>(),
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 175),
              child: state is MessageFetchedSuccess
                  ? state.messages.isEmpty
                      ? Container()
                      : Text(
                          state.messages.last.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).backgroundColor,
                          ),
                        )
                  : Container(),
            );
          },
        ),
        height: 30,
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
    path.lineTo(size.width * (triangleIsLeft ? 0.35 : 0.65), size.height);
    //to add how long triangle will go down
    path.lineTo(size.width * (triangleIsLeft ? 0.25 : 0.75), size.height * (1.3)); //75,25
    path.lineTo(size.width * (triangleIsLeft ? 0.15 : 0.85), size.height); //85,15
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
