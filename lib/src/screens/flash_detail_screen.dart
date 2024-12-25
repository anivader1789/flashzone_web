import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/flash.dart';
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
  

  @override
  Widget build(BuildContext context) {
    if(widget.flash == null) {
      return Column(
        children: [
            backButtonRow(),
            vertical(3),
            const FZText(text: "Flash not found", style: FZTextStyle.largeHeadline, color: Colors.grey,),
        ],
      );
    }

    bool collapse = MediaQuery.of(context).size.width < 900? true: false;
    return Padding(
      padding: collapse? const EdgeInsets.fromLTRB(8, 5, 8, 5):  const EdgeInsets.fromLTRB(30, 15, 30, 15),
      child: Container(
        color: Colors.white70,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //backButtonRow(),
            vertical(3),
            buildUserPanel(collapse),
            vertical(6),
            FZText(text: widget.flash!.content, style: FZTextStyle.paragraph,),
            vertical(),
            //if(!widget.compact)
              buildInteractionsView(collapse),
            vertical(),
            commentInputView(),

            
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
                    controller: commentInputController,
                    cursorColor: Constants.primaryColor(),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: const InputDecoration(
                      hintText: 'Type your comment',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            horizontal(),
            IconButton(
              onPressed: () {
                // Implement the logic to send the message
                _addComment(commentInputController.text);
                commentInputController.clear();
              },
              //color: Constants.primaryColor(),
              icon: const Icon(Icons.send)
            ),
          ],
        );
  }

  Widget buildInteractionsView(bool collapse) {
    return Column(
      children: [
         const Divider(height: 1,),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
          children: [
            IconButton(onPressed: () => print("3 dots pressed"), icon: const Icon(Icons.thumb_up_off_alt), iconSize: collapse? 18: 26, color: Constants.secondaryColor(),),
            IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline), iconSize: collapse? 18: 26, color: Constants.secondaryColor(),),
            IconButton(onPressed: () => print("3 dots pressed"), icon: const Icon(Icons.repeat), iconSize: collapse? 18: 26, color: Constants.secondaryColor(),),
          ],
        ),
        const Divider(height: 5, thickness: 5,),
        vertical(2),
        const FZText(text: "Comments", style: FZTextStyle.paragraph),
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
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: profileNavigate, 
            child: CircleAvatar(
              backgroundImage: Helpers.loadImageProvider(widget.flash!.imageUrl), 
              radius: collapse? 24: 30,)
          ),
        ),
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
                FZText(text: widget.flash!.user.username, style: collapse? FZTextStyle.smallsubheading: FZTextStyle.subheading, color: Colors.grey,),
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
                    Navigator.pushReplacementNamed(context, "");
                  });
                }
              ),
              horizontal(),
              const FZText(text: "Flash List", style: FZTextStyle.paragraph)
            ],);
  }

  void _addComment(String text) {

  }

  profileNavigate() {
    print("user profile clicked");
    Navigator.pushReplacementNamed(context, "user/${widget.flash!.user.id}");
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

