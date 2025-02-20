import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/comment.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/screens/subviews/comment_view.dart';
import 'package:flashzone_web/src/screens/thumbnail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlashDetailScreen extends ConsumerStatefulWidget {
  const FlashDetailScreen({super.key, required this.flash, required this.compact});
  final Flash? flash;
  final bool compact;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FlashDetailScreenState();
}

class _FlashDetailScreenState extends ConsumerState<FlashDetailScreen> {
  final commentInputController = TextEditingController();
  CommentsList? _commentsList;
  Flash? _flash;
  bool _commentPosting = false;
  bool _loading = false;
  bool _ownFlash = false;

  @override
  void initState() {
    super.initState();

    _flash = widget.flash;

    if(_flash != null) {
      _ownFlash = _flash!.user.id == ref.read(currentuser).id;
    } else {
      _ownFlash = false;
    }
    
    
    loadComments();
  }

  loadComments() async {
    if(_flash == null) return;

    final res = await ref.read(backend).fetchFlashComments(_flash!.id!);
    if(res != null) {
      setState(() {
        _commentsList = res;
      });
      
    }
  }
  

  @override
  Widget build(BuildContext context) {
    if(widget.flash == null) {
      return FZErrorIndicator(text: "Flash not found", mobileSize: widget.compact);
    }

    if(widget.flash!.deleted) {
      return const Center(child: FZText(text: "Flash deleted", style: FZTextStyle.paragraph),);
    }

    if(_loading) {
      return const Center(child: CircularProgressIndicator(),);
    }

    bool collapse = MediaQuery.of(context).size.width < 900? true: false;
    return SingleChildScrollView(
      child: Container(
        color: Colors.white70,
        padding: collapse? const EdgeInsets.fromLTRB(8, 5, 8, 5):  const EdgeInsets.fromLTRB(30, 15, 30, 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
          children: [
            //backButtonRow(),
            vertical(3),
            buildUserPanel(collapse),
            vertical(6),
            FZText(text: _flash!.content, flashtagContent: true, style: FZTextStyle.paragraph,),
            vertical(),
            if(_flash!.imageUrl != null) FZNetworkImage(url: _flash!.imageUrl, maxWidth: MediaQuery.of(context).size.width * (collapse? 0.8: 0.5),),
            vertical(2),
            Helpers.flashEngagementText(_flash!),
            vertical(2),
            //if(!widget.compact)
            buildInteractionsView(collapse),
            vertical(2),
            commentInputView(),
            vertical(2),
            const Divider(thickness: 2,),
            vertical(),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
              child: commentListView(),),
            
            
          ],
        ),
      ),
    );
    
  }

  commentInputView() {
    return Row(
          children: [
            horizontal(),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: TextField(
                    enabled: isSignedOut()? false: true,
                    textCapitalization: TextCapitalization.sentences,
                    controller: commentInputController,
                    cursorColor: Constants.primaryColor(),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: isSignedOut()? 'Please sign in to comment': 'Type your comment',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            horizontal(),
            _commentPosting? const CircularProgressIndicator()
            : IconButton(
              onPressed: () {
                // Implement the logic to send the message
                _addComment();
                commentInputController.clear();
              },
              //color: Constants.primaryColor(),
              icon: const Icon(Icons.send)
            ),
          ],
        );
  }

  commentListView() {
    if(_commentsList == null) return Container();

    return ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 5,),
                        itemCount: _commentsList!.comments.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            //onTap: () => ,
                            child: CommentView(
                                comment: _commentsList!.comments[index],
                                flash: widget.flash!,
                                onDelete: () {
                                  setState(() {
                                    _commentsList!.comments.removeAt(index);
                                  });
                                },
                            ),
                          );
                        },
                      );
  }

  Widget buildInteractionsView(bool collapse) {
    final isLiked = ref.read(currentuser).likes.contains(widget.flash!.id);
    final likeIcon = isLiked? Icons.thumb_up_alt: Icons.thumb_up_off_alt;
    return Column(
      children: [
         //const Divider(height: 1,),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
          children: [
            IconButton(onPressed: _addLikeNumber, icon: Icon(likeIcon), iconSize: collapse? 18: 26, color: isLiked? Constants.altPrimaryColor(): Constants.secondaryColor(),),
            IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline), iconSize: collapse? 18: 26, color: Constants.secondaryColor(),),
            IconButton(onPressed: () => print("3 dots pressed"), icon: const Icon(Icons.repeat), iconSize: collapse? 18: 26, color: Constants.secondaryColor(),),
            if(_ownFlash) IconButton(onPressed: _deleteFlash, icon: const Icon(Icons.delete), iconSize: collapse? 18: 26, color: Constants.secondaryColor(),),
          ],
        ),
        const Divider(height: 5, thickness: 5,),
        vertical(2),
        Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(26, 255, 255, 255),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
        ),
        vertical(),
      ],
    );
  }

  Widget buildUserPanel(bool collapse) {
    return Row(mainAxisSize: MainAxisSize.max,
      children: [
        ThumbnailView(link: widget.flash!.user.avatar, mobileSize: collapse),
        // MouseRegion(
        //   cursor: SystemMouseCursors.click,
        //   child: GestureDetector(
        //     onTap: profileNavigate, 
        //     child: CircleAvatar(
        //       backgroundImage: Helpers.loadImageProvider(widget.flash!.user.avatar), 
        //       radius: collapse? 24: 30,)
        //   ),
        // ),
        horizontal(collapse? 1: 2),
        flashInfoView(collapse),
        const Expanded(child: SizedBox(width: double.infinity,)),
        // ignore: avoid_print
        IconButton(onPressed: () => share(context), icon: const Icon(Icons.share)),
        horizontal(collapse? 1: 3),
      ],
    );
  }

  Widget flashInfoView(bool collapse) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FZText(text: widget.flash!.user.name, style: FZTextStyle.headline, onTap: profileNavigate,),
                horizontal(),
                FZText(text: "@${widget.flash!.user.username}", style: collapse? FZTextStyle.smallsubheading: FZTextStyle.subheading, color: Colors.grey,),
              ],
            ),
            vertical(),
            Row(
              children: [
                FZSymbol(type: FZSymbolType.time, compact: collapse,),
                horizontal(),
                FZText(text: Helpers.getDisplayDate(widget.flash!.postDate), style:collapse? FZTextStyle.smallsubheading: FZTextStyle.subheading, color: Colors.grey,),
                if(!collapse) horizontal(),
                if(!collapse) const FZSymbol(type: FZSymbolType.location),
                if(!collapse) horizontal(),
                if(!collapse) FZText(text: widget.flash!.postLocation?.address ?? "Unknown", style: FZTextStyle.subheading, color: Colors.grey,),
              ],
            )
          ], 
        );
  }

  backButtonRow() {
    return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              horizontal(),
              IconButton(
                color: Colors.grey, 
                icon: const Icon(Icons.arrow_back), 
                onPressed: () {
                  setState(() {
                    Navigator.pushNamed(context, "");
                  });
                }
              ),
              horizontal(),
              const FZText(text: "Flash List", style: FZTextStyle.paragraph)
            ],);
  }

  _deleteFlash() async {
    setState(() {
      _loading = true;
    });

    await ref.read(backend).deleteFlash(widget.flash!);
    setState(() {
      _loading = false;
    });
  }

  void _addComment() async {
    if(isSignedOut()) return;

    String text = commentInputController.text;
    if(text.isEmpty) return;

    setState(() {
      _commentPosting = true;
    });

    final commentsList = _commentsList ?? CommentsList.newFrom(widget.flash!.id!);

    commentsList.comments.add(Comment.newFromContent(text, ref.read(currentuser)));
    final res = await ref.read(backend).setFlashComments(commentsList);
    if(res.code == SuccessCode.successful) {
      _commentsList = res.returnedObject;
      _addCommentNumber();
    }

    setState(() {
      _commentPosting = false;
    });
  }

  _addCommentNumber() async {
    if(_flash == null) return;
    

    _flash!.comments += 1;
    setState(() { });

    final res = await ref.read(backend).updateFlash(_flash!);
    if(res.code != SuccessCode.successful) {
      _flash!.comments -= 1;
      setState(() { });
    }
  }

  _addLikeNumber() async {
    if(_flash == null) return;
    if(isSignedOut()) return;

    if(ref.read(currentuser).likes.contains(_flash!.id)) {
      return;
    }

    _flash!.likes += 1;
    ref.read(currentuser).likes.add(_flash!.id!);
    setState(() { });

    final res = await ref.read(backend).updateFlash(_flash!);
    if(res.code != SuccessCode.successful) {
      _flash!.likes -= 1;
      setState(() { });
    } else {
      final user = ref.read(currentuser);
      user.likes.add(_flash!.id!);
      await ref.read(backend).updateProfile(user);
    }
  }

  bool isSignedOut() => ref.read(currentuser).id == FZUser.signedOutUserId;

  profileNavigate() {
    Navigator.pushNamed(context, "user/${widget.flash!.user.id}");
    //widget.profileClicked(widget.flash.user);
  }

  share(BuildContext ctx) {
    final url = "${Uri.base}#flash/${widget.flash!.id}";
    Clipboard.setData(ClipboardData(text: url));
    Helpers.showDialogWithMessage(ctx: ctx, msg: "Link to this flash has been copied to clipboard");
  }

  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);
}

