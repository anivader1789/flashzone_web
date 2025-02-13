import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/comment.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/screens/thumbnail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommentView extends ConsumerStatefulWidget {
  const CommentView({super.key, required this.comment, required this.flash, required this.onDelete});
  final Comment? comment;
  final Flash flash;
  final Function () onDelete;

  @override
  ConsumerState<CommentView> createState() => _CommentViewState();
}

class _CommentViewState extends ConsumerState<CommentView> {
  bool _loading = false;
  bool _ownComment = false;

  @override
  void initState() {
    super.initState();
    
    _ownComment = widget.flash.user.id == ref.read(currentuser).id;
  }

  @override
  Widget build(BuildContext context) {
    if(widget.comment == null) return Container();
    if(widget.comment!.deleted) return const Center(child: FZText(text: "Comment Deleted", style: FZTextStyle.paragraph),);
    if(_loading) return const Center(child: CircularProgressIndicator(),);

    return Container(padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(8))
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(9), 
            child: ThumbnailView(link: widget.comment!.userAvatar, mobileSize: true),
            //CircleAvatar(foregroundImage: Helpers.loadImageProvider(widget.comment!.userAvatar),),
          ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FZText(text: widget.comment!.userName, style: FZTextStyle.paragraph, onTap: () => profileNavigate(context),),
                    const SizedBox(width: 5,),
                    FZText(text: "@${widget.comment!.userHandle}", style: FZTextStyle.subheading, color: Colors.grey, onTap: () => profileNavigate(context),),
                    Expanded(child: Container()),
                    if(_ownComment) FZText(color: Colors.red, text: "Delete", style: FZTextStyle.paragraph, onTap: _deleteComment),
                    const SizedBox(width: 5,),
                  ],
                ),
                const SizedBox(height: 5,),
                FZText(text: widget.comment!.content, style: FZTextStyle.headline)
              ],
            ),
          ),

        ],
      ),
    );
  }

  _deleteComment() async {
    setState(() {
      _loading = true;
    });

    final res = await ref.read(backend).deleteComment(widget.flash, widget.comment!.userId!, widget.comment!.content);

    if(res.code == SuccessCode.successful) {
      widget.onDelete();
    }
    setState(() {
      _loading = false;
    });
  }

  profileNavigate(BuildContext context) {
    print("user profile clicked");
    Navigator.pushReplacementNamed(context, "user/${widget.comment!.userId}");
    //widget.profileClicked(widget.flash.user);
  }
}