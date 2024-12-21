import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/chat.dart';
import 'package:flutter/material.dart';

class ChatCellView extends StatelessWidget {
  const ChatCellView({super.key, required this.data, required this.mobileSize});
  final ChatThread data;
  final bool mobileSize;

  @override
  Widget build(BuildContext context) {
    return Container(
                    padding: const EdgeInsets.fromLTRB(8.0, 1.0, 8.0, 1.0),
                    // decoration: BoxDecoration(
                    //   border: Border.all(width: 1)
                    // ),
                    child: mobileSize? 
                      Column(children: [
                        CircleAvatar(
                          foregroundImage: Helpers.loadImageProvider(data.pic),
                        ),
                        const SizedBox(height: 5,),
                        FZText(text: data.name, style: FZTextStyle.paragraph),
                      ],)
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          foregroundImage: Helpers.loadImageProvider(data.pic),
                        ),
                        const SizedBox(width: 5,),
                        Column(
                          children: [
                            FZText(text: data.name, style: FZTextStyle.headline),
                            const SizedBox(height: 5,),
                            FZText(text: data.lastMsg, style: FZTextStyle.paragraph),
                          ],
                        )
                      ],
                    ),
                  );
  }
}