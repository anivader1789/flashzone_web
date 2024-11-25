import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/chat.dart';
import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.chat, required this.isUserMessage});
  final ChatMessage chat;
  final bool isUserMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      child: LayoutBuilder(
        builder: (context, constrains) {
          return Container(
            decoration: BoxDecoration(
                color: isUserMessage ? Constants.fillColor() : Constants.secondaryColor(),
                borderRadius: BorderRadius.circular(20),
              ),
            padding: const EdgeInsets.all(15),
            child: FZText(text: chat.message, style: FZTextStyle.paragraph, color: Colors.white,),
          );
        })
    );
  }
}