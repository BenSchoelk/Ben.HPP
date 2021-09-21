import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/messageCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/uiUtils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageBoxContainer extends StatefulWidget {
  final VoidCallback closeMessageBox;
  MessageBoxContainer({Key? key, required this.closeMessageBox}) : super(key: key);

  @override
  _MessageBoxContainerState createState() => _MessageBoxContainerState();
}

final double tabBarHeightPercentage = 0.85;
final double messageBoxWidthPercentage = 0.775;
final double messageBoxDetailsHeightPercentage = UiUtils.questionContainerHeightPercentage - 0.05;
final double messageBoxHeightPercentage = UiUtils.questionContainerHeightPercentage - 0.03;

class _MessageBoxContainerState extends State<MessageBoxContainer> {
  late int _currentSelectedIndex = 1;

  Widget _buildTabbarTextContainer(String text, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _currentSelectedIndex = index;
        });
      },
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).backgroundColor.withOpacity(index == _currentSelectedIndex ? 1.0 : 0.5)),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * tabBarHeightPercentage,
      width: MediaQuery.of(context).size.width * messageBoxWidthPercentage,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabbarTextContainer("CHAT", 0),
          _buildTabbarTextContainer("MESSAGES", 1),
          _buildTabbarTextContainer("EMOJIES", 2),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    if (_currentSelectedIndex == 0) {
      return ChatContainer();
    } else if (_currentSelectedIndex == 1) {
      return MessagesContainer(
        closeMessageBox: widget.closeMessageBox,
      );
    }
    return EmojiesContainer(
      closeMessageBox: widget.closeMessageBox,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 7.5 + MediaQuery.of(context).size.height * (0.01),
      ),
      width: MediaQuery.of(context).size.width * messageBoxWidthPercentage,
      height: MediaQuery.of(context).size.height * messageBoxHeightPercentage,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * tabBarHeightPercentage * 0.25),
              width: MediaQuery.of(context).size.width * messageBoxWidthPercentage,
              height: MediaQuery.of(context).size.height * messageBoxDetailsHeightPercentage,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _buildTabBarView(),
              ),
            ),
          ),
          Align(alignment: Alignment.topCenter, child: _buildTabBar(context)),
        ],
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  final VoidCallback onTap;
  const SendButton({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 40.0,
        left: MediaQuery.of(context).size.width * (0.175),
        right: MediaQuery.of(context).size.width * (0.175),
      ),
      child: CustomRoundedButton(
        widthPercentage: MediaQuery.of(context).size.width * (0.4),
        backgroundColor: Theme.of(context).primaryColor,
        buttonTitle: "Send",
        titleColor: Theme.of(context).backgroundColor,
        radius: 10,
        showBorder: false,
        elevation: 5,
        height: 40,
        onTap: onTap,
      ),
    );
  }
}

class ChatContainer extends StatelessWidget {
  const ChatContainer({Key? key}) : super(key: key);

  Widget _buildMessage(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.0),
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (0.45),
        ),
        child: Column(
          children: [
            Text(" something"),
          ],
        ),
      ),
    );
  }

  /*
  Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "time",
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    Container(
                      //width: MediaQuery.of(context).size.width * (0.225),
                      child: Text(
                        "sender name",
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10.0, left: 10.0),
                alignment: Alignment.centerRight,
                //decoration: BoxDecoration(border: Border.all()),
                child: Text(" wooohoo",
                    style: TextStyle(
                      fontSize: 13,
                    )),
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
  
   */

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * tabBarHeightPercentage,
          bottom: 10,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildMessage(context);
        });
  }
}

class MessagesContainer extends StatefulWidget {
  final VoidCallback closeMessageBox;
  MessagesContainer({Key? key, required this.closeMessageBox}) : super(key: key);

  @override
  _MessagesContainerState createState() => _MessagesContainerState();
}

class _MessagesContainerState extends State<MessagesContainer> {
  int currentlySelectedMessageIndex = -1;

  Widget _buildMessages() {
    return ListView.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * tabBarHeightPercentage,
          bottom: 100,
        ),
        itemCount: predefinedMessages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * (0.05),
              vertical: 10,
            ),
            child: CustomRoundedButton(
              onTap: () {
                setState(() {
                  currentlySelectedMessageIndex = index;
                });
              },
              widthPercentage: MediaQuery.of(context).size.width * (0.4),
              backgroundColor: currentlySelectedMessageIndex == index ? Theme.of(context).primaryColor : Theme.of(context).backgroundColor,
              buttonTitle: predefinedMessages[index],
              titleColor: currentlySelectedMessageIndex == index ? Theme.of(context).backgroundColor : Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              radius: 10,
              showBorder: false,
              height: 40,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: _buildMessages(),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: SendButton(onTap: () {
              if (currentlySelectedMessageIndex != -1) {
                MessageCubit messageCubit = context.read<MessageCubit>();
                BattleRoomCubit battleRoomCubit = context.read<BattleRoomCubit>();
                UserDetailsCubit userDetailsCubit = context.read<UserDetailsCubit>();
                messageCubit.addMessage(
                  message: predefinedMessages[currentlySelectedMessageIndex],
                  by: userDetailsCubit.getUserId(),
                  roomId: battleRoomCubit.getRoomId(),
                  isTextMessage: true,
                );
                widget.closeMessageBox();
              }
            })),
      ],
    );
  }
}

class EmojiesContainer extends StatefulWidget {
  final VoidCallback closeMessageBox;
  EmojiesContainer({Key? key, required this.closeMessageBox}) : super(key: key);

  @override
  _EmojiesContainerState createState() => _EmojiesContainerState();
}

class _EmojiesContainerState extends State<EmojiesContainer> {
  int currentlySelectedEmojiIndex = -1;

  Widget _buildEmojies() {
    return GridView.builder(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * tabBarHeightPercentage,
          left: MediaQuery.of(context).size.width * (0.05),
          right: MediaQuery.of(context).size.width * (0.05),
          bottom: 100,
        ),
        itemCount: 15,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 15.0,
        ),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() {
                currentlySelectedEmojiIndex = index;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: index == currentlySelectedEmojiIndex ? Theme.of(context).primaryColor : Theme.of(context).backgroundColor,
              ),
              child: Center(child: Text("$index")),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: _buildEmojies(),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: SendButton(onTap: () {
              widget.closeMessageBox();
            })),
      ],
    );
  }
}

class ChatMessagePainter extends CustomPainter {
  bool isLeft;
  Color color;
  ChatMessagePainter({required this.isLeft, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();

    Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (isLeft) {
      path.moveTo(size.width * (0.1), 0);
      path.lineTo(size.width * (0.9), 0);

      //add top-right curve effect
      path.quadraticBezierTo(size.width, 0, size.width, size.height * 0.2);

      path.lineTo(size.width, size.height * (0.8));
      //add bottom-right curve
      path.quadraticBezierTo(size.width, size.height, size.width * (0.9), size.height);
      path.lineTo(size.width * (0.125), size.height);

      //add botom left shape
      path.lineTo(size.width * (0.025), size.height * (1.175));
      path.quadraticBezierTo(-10, size.height * (1.275), 0, size.height * (0.8));

      //add left-top curve
      path.lineTo(0, size.height * (0.2));
      path.quadraticBezierTo(0, 0, size.width * (0.1), 0);
      canvas.drawPath(path, paint);
    } else {
      //

      path.moveTo(size.width * (0.1), 0);
      path.quadraticBezierTo(0, 0, 0, size.height * (0.2));
      path.lineTo(0, size.height * (0.8));

      path.quadraticBezierTo(0, size.height, size.width * (0.1), size.height);
      path.lineTo(size.width * (0.875), size.height);

      //add bottom right shape
      //path.quadraticBezierTo(x1, y1, x2, y2);
      path.lineTo(size.width * (0.975), size.height * (1.175));
      path.quadraticBezierTo(size.width + 10, size.height * (1.275), size.width, size.height * (0.8));

      path.lineTo(size.width, size.height * (0.2));
      path.quadraticBezierTo(size.width, 0, size.width * (0.9), 0);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
