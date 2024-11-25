import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    bool collapse = MediaQuery.of(context).size.width < 900? true: false;
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
      child: Container(
        color: Colors.white70,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildUserPanel(collapse),
            vertical(6),
            FZText(text: widget.flash.content, style: FZTextStyle.paragraph),
            vertical(),
            if(!widget.compact)
              buildInteractionsView(),
            
            
          ],
        ),
      ),
    );
  }

  Widget buildInteractionsView() {
    return Column(
      children: [
        const Divider(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
          children: [
            IconButton(onPressed: () => print("3 dots pressed"), icon: const Icon(Icons.thumb_up_off_alt), iconSize: 30, color: Constants.secondaryColor(),),
            IconButton(onPressed: () => print("3 dots pressed"), icon: const Icon(Icons.chat_bubble_outline), iconSize: 30, color: Constants.secondaryColor(),),
            IconButton(onPressed: () => print("3 dots pressed"), icon: const Icon(Icons.favorite_border), iconSize: 30, color: Constants.secondaryColor(),),
          ],
        ),
        const Divider(),
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
              backgroundImage: Helpers.loadImageProvider(widget.flash.imageUrl), 
              radius: 30,)
          ),
        ),
        horizontal(2),
        flashInfoView(collapse),
        const Expanded(child: SizedBox(width: double.infinity,)),
        // ignore: avoid_print
        IconButton(onPressed: () => print("3 dots pressed"), icon: const Icon(Icons.more_vert)),
        horizontal(3),
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
                FZText(text: widget.flash.user.username, style: FZTextStyle.subheading, color: Colors.grey,),
              ],
            ),
            vertical(),
            Row(
              children: [
                const FZSymbol(type: FZSymbolType.time),
                horizontal(),
                FZText(text: Helpers.getDisplayDate(widget.flash.postDate), style: FZTextStyle.subheading, color: Colors.grey,),
                if(!collapse) horizontal(),
                if(!collapse) const FZSymbol(type: FZSymbolType.location),
                if(!collapse) horizontal(),
                if(!collapse) FZText(text: widget.flash.postAddress ?? "Unknown", style: FZTextStyle.subheading, color: Colors.grey,),
              ],
            )
          ], 
        );
  }

  Widget vertical([int multiplier = 1]) => SizedBox(height: 5 * multiplier.toDouble(),);
  Widget horizontal([int multiplier = 1]) => SizedBox(width: 5 * multiplier.toDouble(),);

  profileNavigate() {
    print("user profile clicked");
    widget.profileClicked(widget.flash.user);
  }
}