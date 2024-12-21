import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/chat.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/screens/subviews/message_bubble_view.dart';
import 'package:flashzone_web/src/screens/subviews/message_cell_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessagesView extends ConsumerStatefulWidget {
  const MessagesView({super.key, required this.mobileSize});
  final bool mobileSize;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessagesViewState();
}

class _MessagesViewState extends ConsumerState<MessagesView> {
  late List<ChatThread> chatThreads;
  late List<ChatMessage> chats;
  int? selectedThreadIndex;

  @override
  void initState() {
    super.initState();
    chatThreads = List.empty(growable: true);
    chats = List.empty(growable: true);
    loadData();
  }

  loadData() {
    final msgMap = ref.read(messages);
    FZUser? firstChatUser;
    for(FZUser user in msgMap.keys) {
      firstChatUser ??= user;

      String lastMessage = msgMap[user]!.isEmpty? "" : msgMap[user]!.last.message;
      chatThreads.add(ChatThread(name: user.name!, pic: user.avatar , lastMsg: lastMessage));
    }

    if(firstChatUser != null) {
      chats.addAll(msgMap[firstChatUser]!);
      selectedThreadIndex = 0;
      print("Added chat");
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(flex: 1, child: chatListView()),
          Expanded(flex: 3, child: chatContentView())
        ],
      ),);
  }

  Widget chatListView() {
    if(chatThreads.isEmpty) {
      return Container(
        decoration: const BoxDecoration(border: Border(right: BorderSide(width: 2))),
        child: const Center(child: FZText(text: "No chats yet", style: FZTextStyle.headline),));
    }
    
    return Container(
        decoration: const BoxDecoration(border: Border(right: BorderSide(width: 2))),
        child: ListView.separated(
                  itemBuilder: (context, i) {
                    return ChatCellView(data: chatThreads[i], mobileSize: widget.mobileSize);
                  }, 
                  separatorBuilder: (_, i) => const Divider(), 
                  itemCount: chatThreads.length),
      );
           
  }

  Widget chatContentView() {
    if(selectedThreadIndex == null) {
      return const Center(child: FZText(text: "Select a conversation..", style: FZTextStyle.paragraph),);
    }

    final user = ref.read(currentuser).id;
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
                reverse: true,
                itemBuilder: (context, i) {
                  if(i == chats.length) {
                    return Container(alignment: Alignment.center, height: 45, child: const FZText(text: "Start of a conversation", style: FZTextStyle.subheading),);
                  }
                  var chat = chats[chats.length - 1 - i];
                  final ownMsg = chat.sender == user;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 1.0, 8.0, 1.0),
                    child: Row(
                      mainAxisAlignment:
                          ownMsg ? MainAxisAlignment.end : MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MessageBubble(chat: chat, isUserMessage: ownMsg),
                      ],
                    ),
                  );
                }, 
                separatorBuilder: (_, i) => Container(height: 3), 
                itemCount: chats.length+1),
        ),
        buildChatCardWithTextField()
      ]
    );
          
  }

  _sendMessage(String message) async {
    if(selectedThreadIndex == null || selectedThreadIndex == -1) return;

    ChatThread thread = chatThreads[selectedThreadIndex!];
    ChatMessage newChat = ChatMessage(sender: ref.read(currentuser).id!, message: message, receiver: thread.name, time: DateTime.now());
    setState(() {
      chats.add(newChat);
    });
    // try {
    //   final result = await ref.read(backend).sendMessage(newChat);
    //   if(result?.code != SuccessCode.successful) {
    //     setState(() {
    //       chats.remove(newChat);
    //       Helpers.showDialogWithMessage(ctx: context, msg: "Message was not sent. Please try again");
    //     });
        
    //   }
    // } catch(e) {
    //   setState(() {
    //       chats.remove(newChat);
    //       Helpers.showDialogWithMessage(ctx: context, msg: "Message was not sent. Please try again");
    //     });
    // }
  }

  Widget buildChatCardWithTextField() {
    TextEditingController textController = TextEditingController();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: textController,
                    cursorColor: Constants.primaryColor(),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2.0),
            IconButton(
              onPressed: () {
                // Implement the logic to send the message
                print('Sending Message: ${textController.text}');
                _sendMessage(textController.text);
                textController.clear();
              },
              color: Constants.primaryColor(),
              icon: const Icon(Icons.send)
            ),
          ],
        ),
      ),
    );
  }

}

