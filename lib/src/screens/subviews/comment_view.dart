import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/comment.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flutter/material.dart';

class CommentView extends StatelessWidget {
  const CommentView({super.key, required this.comment});
  final Comment? comment;

  @override
  Widget build(BuildContext context) {
    if(comment == null) return Container();

    return Container(padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: const BorderRadius.all(Radius.circular(8))
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(9), 
            child: CircleAvatar(foregroundImage: Helpers.loadImageProvider(comment!.userAvatar),),
          ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FZText(text: comment!.userName, style: FZTextStyle.paragraph, onTap: () => profileNavigate(context),),
                    const SizedBox(width: 5,),
                    FZText(text: "@${comment!.userHandle}", style: FZTextStyle.subheading, color: Colors.grey, onTap: () => profileNavigate(context),),
                  ],
                ),
                const SizedBox(height: 5,),
                FZText(text: comment!.content, style: FZTextStyle.headline)
              ],
            ),
          )
        ],
      ),
    );
  }

  profileNavigate(BuildContext context) {
    print("user profile clicked");
    Navigator.pushReplacementNamed(context, "user/${comment!.userId}");
    //widget.profileClicked(widget.flash.user);
  }
}