import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/message_ref.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/screens/dm_screen.dart';
import 'package:flashzone_web/src/screens/thumbnail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DMListScreen extends ConsumerStatefulWidget {
  const DMListScreen({super.key, this.receipientUser, required this.isMobileSize});
  final FZUser? receipientUser;
  final bool isMobileSize;
  
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DMListScreenState();
}

class _DMListScreenState extends ConsumerState<DMListScreen> {
  final List<MessageRef> _chats = List.empty(growable: true);
  FZUser? _receipientUserToLoad;
  MessageRef? _messageRefToLoad;

  @override
  void initState() {
    super.initState();
    if(widget.receipientUser != null) {
      _receipientUserToLoad = widget.receipientUser;
    }
  }


  @override
  Widget build(BuildContext context) {
    if(widget.isMobileSize) {
      if(_receipientUserToLoad != null) {
        return DMScreen(
          receipientUser: widget.receipientUser!,
          messageRef: _messageRefToLoad,
          onBackPressed: () {
            setState(() {
              _receipientUserToLoad = null;
            });
          },
        );
      } else {
        return chatsListView();
      }
    }

    return Padding(padding: const EdgeInsets.all(8),
    child: Row(
      children: [
        Expanded(flex: 1, child: chatsListView()),
        Expanded(flex: 3, child: dmView())
      ],
    ),);
  }

  dmView() {
    if(_receipientUserToLoad == null) {
      return const Center(child: FZText(text: "Select a chat to start messaging", style: FZTextStyle.headline,));
    }
    return DMScreen(
      receipientUser: _receipientUserToLoad!,
      messageRef: _messageRefToLoad,
      onBackPressed: () {
        setState(() {
          _receipientUserToLoad = null;
          _messageRefToLoad = null;

        });
      },
    );
  }

  chatsListView() {
    return ListView.builder(
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        return chatItemView(chat);
      },
    );
  }

  chatItemView(MessageRef msgRef) {
    FZUser otherUser = msgRef.sender!.id == ref.read(currentuser).id! ? msgRef.receiver! : msgRef.sender!;

    return GestureDetector(
      onTap: () {
        setState(() {
          _receipientUserToLoad = otherUser;
          _messageRefToLoad = msgRef;
        });
      },
      child: Row(
        children: [
          ThumbnailView(link: otherUser.avatar),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FZText(text: otherUser.name, style: FZTextStyle.headline, onTap: () => context.go(Routes.routeNameProfile(otherUser.id!)),),
               // const SizedBox(height: 4.0),
               // Text(ref.lastMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}