import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/chat_message.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/screens/subviews/message_bubble_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FamDMScreen extends ConsumerStatefulWidget {
  const FamDMScreen({super.key, required this.receipientUser,  required this.onDismiss});
  final FZUser? receipientUser;
  final Function () onDismiss;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FamDMScreenState();
}

class _FamDMScreenState extends ConsumerState<FamDMScreen> {
  final List<FZChatMessage> _chats = [];
  TextEditingController _chatInputController = TextEditingController();
  String? _groupId;
  
  @override
  void initState() {
    super.initState();

    
    loadChats();
  }

  loadChats() async {
    if(widget.receipientUser == null) return;

    try {
        //See if a chat with this recepient already exists
        _groupId = await ref.read(backend).findPersonalChat(
          sender: ref.read(currentuser),
          receiver: widget.receipientUser!,
        );


        if(_groupId != null) {
          ref.read(backend).chatStream(_groupId!, 10).listen((newMessages) {

            final existingIds = _chats.map((m) => m.id).toSet();
            final messagesToAdd = newMessages.where((m) => !existingIds.contains(m.id)).toList();
            messagesToAdd.sort();
            _chats.addAll(messagesToAdd);
            setState(() {
                  });

          });
        }

        
      
    } catch (e) {
      // Handle error
      print("Error occured getting chats: ${e.toString()}");
    }
    
    
    
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                color: const Color.fromARGB(200, 0, 0, 0),
              ),
            )
        ),
        containerView(),
      ],
    );
  }

  containerView() {
    if(widget.receipientUser == null) {
      return Container(
        margin: const EdgeInsets.all(50),
        padding: const EdgeInsets.all(5),
        //color: Colors.white,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              color: Constants.bgColor(),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => widget.onDismiss(),
                  ),
                  const FZText(text: "User not found", style: FZTextStyle.headline),
                ],
              ),
            ),
            const FZText(text: "The user you are trying to chat with does not exist.", style: FZTextStyle.headline),
          ],
        ),
      );
    }


    Size screenSize = MediaQuery.of(context).size;
      bool isMobileScreen = screenSize.width <= 800;
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: isMobileScreen ? screenSize.width * 0.1 : screenSize.width * 0.2, 
          vertical: isMobileScreen ? screenSize.height * 0.15 : screenSize.height * 0.25,),
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => widget.onDismiss(),
                ),
                FZText(text: widget.receipientUser!.name, style: FZTextStyle.headline),
              ],
            ),
          ),
          Expanded(
            child: chatView(),
          ),
        ],
      ),
    );
  }

  chatView() {
    return Container(
      color: Colors.white,
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
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Constants.bgColor(), width: 2)
              ),
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
    _groupId ??= await ref.read(backend).initiatePersonalChat(
            sender: ref.read(currentuser),
            receiver: widget.receipientUser!,
          );

    if (_groupId == null) return;

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
    // setState(() {
    //   _chats.add(chat);
    // });
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
                    FZMessageBubble(
                      chat: chat,
                      isUserMessage: isOwner,
                    ),
                  ],
                ),
    );
  }
}