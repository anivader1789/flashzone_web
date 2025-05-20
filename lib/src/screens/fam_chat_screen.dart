import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/chat_message.dart';
import 'package:flashzone_web/src/model/fam.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FamChatScreen extends ConsumerStatefulWidget {
  const FamChatScreen({super.key, required this.fam});
  final Fam fam;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FamChatScreenState();
}

class _FamChatScreenState extends ConsumerState<FamChatScreen> {
  final List<FZChatMessage> _chats = [];
  TextEditingController _chatInputController = TextEditingController();
  String? _groupId;

  @override
  void initState() {
    super.initState();
    
  }

  loadChats() async {
    try {
      _groupId = await ref.read(backend).getOrCreateRefForFamChat(famId: widget.fam.id!);
      if (_groupId == null) return;
      var chats = await ref.read(backend).getChats(_groupId!, limit: 50);
      setState(() {
        _chats.clear();
        _chats.addAll(chats);
      });
    } catch (e) {
      // Handle error
    }
    

    ref.read(backend).chatStream(widget.fam.id!, 10).listen((newMessages) {
      final existingIds = _chats.map((m) => m.id).toSet();
      final messagesToAdd = newMessages.where((m) => !existingIds.contains(m.id)).toList();

      setState(() {
        _chats.addAll(messagesToAdd);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Constants.bgColor(),
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              FZText(text: widget.fam.name, style: FZTextStyle.headline),
            ],
          ),
        ),
        Expanded(
          child: chatView(),
        ),
      ],
    );
  }

  chatView() {
    return Container(
      color: Constants.bgColor(),
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              reverse: true,
              itemBuilder: (context, i) {
                var chat = _chats[_chats.length - 1 - i];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 1.0, 8.0, 1.0),
                  child: chatItemView(chat),
                );
              }, 
              separatorBuilder: (_, i) => Container(height: 3), 
              itemCount: _chats.length),
          ),
          TextField(
            controller: _chatInputController,
            decoration: InputDecoration(
              hintText: 'Type a message',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendChatMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _sendChatMessage() async {
    String message = _chatInputController.text.trim();
    if (message.isEmpty) return;
    _chatInputController.clear();

    var chat = FZChatMessage(
      message: message,
      senderId: ref.read(currentuser).id!,
      senderPic: ref.read(currentuser).avatar,
      senderName: ref.read(currentuser).name!,
      time: DateTime.now(),
    );
    setState(() {
      _chats.add(chat);
    });
    await ref.read(backend).sendMessage(chat, _groupId!);
  }

  chatItemView(FZChatMessage chat) {
    bool isOwner = chat.senderId == ref.read(currentuser).id;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
                  mainAxisAlignment:
                      isOwner ? MainAxisAlignment.end : MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isOwner
                        ? const SizedBox()
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundImage: chat.senderPic != null ? NetworkImage(chat.senderPic!) : const AssetImage('assets/profile_pic_placeholder.png') as ImageProvider<Object>,
                            ),
                          ),
                    MessageBubble(
                      chat: chat,
                      isUserMessage: isOwner,
                    ),
                  ],
                ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.chat, required this.isUserMessage});
  final FZChatMessage chat;
  final bool isUserMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 250),
      child: LayoutBuilder(
        builder: (context, constrains) {
          return Container(
              decoration: BoxDecoration(
                color: isUserMessage ? Constants.primaryColor() : Constants.secondaryColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  FZText(text: isUserMessage? "You": chat.senderName, style: FZTextStyle.headline),
                  FZText(text: chat.message, style: FZTextStyle.paragraph, color: Colors.white,),
                ],
              ),
        );
        }
      ),
    );
  }
}