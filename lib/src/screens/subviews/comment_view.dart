import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/comment.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/screens/thumbnail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
 // bool _ownComment = false;

  // @override
  // void initState() {
  //   super.initState();
    
    
  //   setState(() {
      
  //   });
  // }

  @override
  Widget build(BuildContext context) {
   // _ownComment = widget.comment?.userId == ref.read(currentuser).id;

    if(widget.comment == null) return Container();
    if(widget.comment!.deleted) return const Center(child: FZText(text: "Comment Deleted", style: FZTextStyle.paragraph),);
    if(_loading) return const Center(child: CircularProgressIndicator(),);

    final user = ref.watch(currentuser);

    bool mobileSize = MediaQuery.of(context).size.width < 800;

    return Container(padding: EdgeInsets.all(mobileSize? 4: 11),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(8))
      ),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.all(mobileSize? 3: 9), 
            child: ThumbnailView(link: widget.comment!.userAvatar, mobileSize: mobileSize, mobileRadius: 16,),
            //CircleAvatar(foregroundImage: Helpers.loadImageProvider(widget.comment!.userAvatar),),
          ),
          if(mobileSize) const SizedBox(width: 5,),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    
                    FZText(text: widget.comment!.userName, style: FZTextStyle.paragraph, onTap: () => profileNavigate(context),),
                    if(!mobileSize) const SizedBox(width: 5,),
                    if(!mobileSize) FZText(text: "@${widget.comment!.userHandle}", style: FZTextStyle.subheading, color: Colors.grey, onTap: () => profileNavigate(context),),
                    Expanded(child: Container()),
                    deleteButton(mobileSize, widget.comment?.userId == user.id),
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

  deleteButton(bool mobileSize, bool shouldShow) {
    if(!shouldShow) return const SizedBox.shrink();

    if(mobileSize) {
      return IconButton(onPressed: _deleteComment, icon: const Icon(Icons.delete, size: 18, color: Colors.red,));
    } else {
      return FZText(color: Colors.red, text: "Delete", style: FZTextStyle.subheading, onTap: _deleteComment);
    }
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
    context.go(Routes.routeNameProfile(widget.comment!.userId!));
    //widget.profileClicked(widget.flash.user);
  }
}