import 'dart:async';

import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/chat_message.dart';
import 'package:flashzone_web/src/model/fam.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FamChatScreen extends ConsumerStatefulWidget {
  const FamChatScreen({super.key, required this.famId, required this.mobileSize});
  final String famId;
  final bool mobileSize;

  static const routeName = 'famChat';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FamChatScreenState();
}

class _FamChatScreenState extends ConsumerState<FamChatScreen> {
  final List<FZChatMessage> _chats = [];
  TextEditingController _chatInputController = TextEditingController();
  String? _groupId;
  Fam? fam;
  bool _loading = false;

  StreamSubscription? chatStreamSubscription;

  @override
  void initState() {
    super.initState();

    
    loadFam();
  }

  loadFam() async {
    setState(() {
      _loading = true;
    });
    fam = await ref.read(backend).fetchFam(widget.famId);
    setState(() {
      _loading = false;
    });
    if(fam == null) {
          return;
        }

    String userId = ref.read(currentuser).id!;
    if(fam!.members.contains(userId) || fam!.admins.contains(userId)) {
      loadChats();
    }
    
    
  }

  loadChats() async {
    

    try {
      _groupId = await ref.read(backend).getOrCreateRefForFamChat(famId: fam!.id!);
      if (_groupId == null) return;
      var chats = await ref.read(backend).getChats(_groupId!, limit: 50);
      setState(() {
        _chats.clear();
        _chats.addAll(chats);
      });
    } catch (e) {
      // Handle error
    }
    
    chatStreamSubscription = ref.read(backend).chatStream(fam!.id!, 10).listen((newMessages) {
      final existingIds = _chats.map((m) => m.id).toSet();
      final messagesToAdd = newMessages.where((m) => !existingIds.contains(m.id)).toList();

      setState(() {
        _chats.addAll(messagesToAdd);
      });
    });
  }

  @override
  void dispose() {
    chatStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(_loading) {
      return FZLoadingIndicator(text: "Loading chat messages", mobileSize: widget.mobileSize);
    }

    final user = ref.watch(currentuser);
    
    if(user.isSignedOut) {
      return FZErrorIndicator(text: "You have to Sign in to view this page", mobileSize: widget.mobileSize);
    } else if(fam == null) {
      return FZErrorIndicator(text: "Fam Error", mobileSize: widget.mobileSize);
    } else if(fam!.members.contains(user.id) == false && fam!.admins.contains(user.id) == false) {
      return FZErrorIndicator(text: "Oops. Access to private chat is restricted to fam members only", mobileSize: widget.mobileSize);
    }

    

    return Column(
      children: [
        Container(
          height: 60,
          color: Constants.secondaryColor(),
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // IconButton(
              //   icon: const Icon(Icons.arrow_back, color: Colors.white,),
              //   onPressed: () => Navigator.pop(context),
              // ),
              FZText(
                text: "#${fam!.name}", 
                style: FZTextStyle.headline, 
                color: Colors.white,
                onTap: () {
                  Navigator.pushNamed(context, "fams/${widget.famId}");
                },),
              const SizedBox(width: 15,),
              const FZText(text: "-- private chat room", style: FZTextStyle.paragraph, color: Colors.white,)
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
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            reverse: true,
            itemBuilder: (context, i) {
              var chat = _chats[i];
              return Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 1.0, 8.0, 1.0),
                child: chatItemView(chat),
              );
            }, 
            separatorBuilder: (_, i) => Container(height: 3), 
            itemCount: _chats.length),
        ),
        Container(
          padding: const EdgeInsets.all(8),

          child: TextField(
            controller: _chatInputController,
            
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Constants.secondaryColor(),
                  width: 2),
                borderRadius: BorderRadius.circular(21)
              ),
              hintText: 'Type a message',
              suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendChatMessage,
              ),
            ),
          ),
        ),
      ],
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
      child: Wrap(
                  alignment: isOwner? WrapAlignment.end: WrapAlignment.start,
                  children: [
                    isOwner || widget.mobileSize
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
                      mobileSize: widget.mobileSize,
                    ),
                  ],
                ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.chat, required this.isUserMessage, required this.mobileSize});
  final FZChatMessage chat;
  final bool isUserMessage;
  final bool mobileSize;

  @override
  Widget build(BuildContext context) {
    return Container(
              decoration: BoxDecoration(
                color: isUserMessage ? Constants.bgColor() : Constants.secondaryColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if(isUserMessage == false) FZText(text: "${chat.senderName}:", style: FZTextStyle.headline, color: Colors.white,),
                  FZText(text: chat.message, style: FZTextStyle.paragraph, color: Colors.white,),
                ],
              ),
        );
   
  }
}