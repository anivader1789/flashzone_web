import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FlashCellView extends ConsumerStatefulWidget {
  const FlashCellView({super.key, required this.flash, required this.profileClicked, this.compact = false});
  final Flash flash;
  final Function (FZUser) profileClicked;
  final bool compact;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FlashCellViewState();
}

class _FlashCellViewState extends ConsumerState<FlashCellView> {
  late Map<String, bool> textsToDisplay;

  @override
  void initState() {
    super.initState();
    // final content = widget.flash.content;
    // String fts = Constants.flashtags.join("|");
    // RegExp exp = RegExp(r"\('()'\)");
    // List<String> _list =[];
    // for (var m in exp.allMatches(myString)) {
    //   _list.add(m[1].toString());
    
    // }
  }

  @override
  Widget build(BuildContext context) {
    bool collapse = MediaQuery.of(context).size.width < 900? true: false;
    return Padding(
      padding: collapse? const EdgeInsets.fromLTRB(8, 5, 8, 5):  const EdgeInsets.fromLTRB(30, 15, 30, 15),
      child: Container(
        color: Colors.white70,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildUserPanel(collapse),
            vertical(2),
            FZText(text: widget.flash.content, style: FZTextStyle.paragraph, onTap: flashNavigate, flashtagContent: true,),
            vertical(),
            if(widget.flash.imageUrl != null) Image(image: Helpers.loadImageProvider(widget.flash.imageUrl)),
            vertical(2),
            //if(!widget.compact)
              buildInteractionsView(collapse),
            
            
          ],
        ),
      ),
    );
  }

  Widget buildInteractionsView(bool collapse) {
    return Column(mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1,),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
          children: [
            IconButton(onPressed: () => print("3 dots pressed"), icon: const Icon(Icons.thumb_up_off_alt), iconSize: collapse? 18: 26, color: Constants.secondaryColor(),),
            IconButton(onPressed: flashNavigate, icon: const Icon(Icons.chat_bubble_outline), iconSize: collapse? 18: 26, color: Constants.secondaryColor(),),
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
              backgroundImage: Helpers.loadImageProvider(widget.flash.user.avatar), 
              radius: collapse? 24: 30,)
          ),
        ),
        horizontal(collapse? 1: 2),
        flashInfoView(collapse),
        const Expanded(child: SizedBox(width: double.infinity,)),
        // ignore: avoid_print
        IconButton(onPressed:() => share(context), icon: const Icon(Icons.share)),
        horizontal(collapse? 1: 3),
      ],
    );
  }

  Widget flashInfoView(bool collapse) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FZText(text: widget.flash.user.name, style: FZTextStyle.headline, onTap: profileNavigate,),
                horizontal(),
                FZText(text: widget.flash.user.username, style: collapse? FZTextStyle.smallsubheading: FZTextStyle.subheading, color: Colors.grey,),
              ],
            ),
            vertical(),
            Row(
              children: [
                FZSymbol(type: FZSymbolType.time, compact: collapse,),
                horizontal(),
                FZText(text: Helpers.getDisplayDate(widget.flash.postDate), style:collapse? FZTextStyle.smallsubheading: FZTextStyle.subheading, color: Colors.grey,),
                if(!collapse) horizontal(),
                if(!collapse) const FZSymbol(type: FZSymbolType.location),
                if(!collapse) horizontal(),
                if(!collapse) FZText(text: widget.flash.postLocation?.address ?? "Unknown", style: FZTextStyle.subheading, color: Colors.grey,),
              ],
            )
          ], 
        );
  }

  Widget vertical([int multiplier = 1]) => SizedBox(height: 5 * multiplier.toDouble(),);
  Widget horizontal([int multiplier = 1]) => SizedBox(width: 5 * multiplier.toDouble(),);

  profileNavigate() {
    print("user profile clicked");
    Navigator.pushReplacementNamed(context, "user/${widget.flash.user.id}");
    //widget.profileClicked(widget.flash.user);
  }

  flashNavigate() {
    Navigator.pushReplacementNamed(context, "flash/${widget.flash.id}");
  }

  share(BuildContext ctx) {
    final url = "${Uri.base}#flash/${widget.flash.id}";
    Clipboard.setData(ClipboardData(text: url));
    Helpers.showDialogWithMessage(ctx: ctx, msg: "Link to this flash has been copied to clipboard");
  }
}