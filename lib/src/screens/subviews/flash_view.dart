import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/modules/location/location_service.dart';
import 'package:flashzone_web/src/screens/thumbnail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FlashCellView extends ConsumerStatefulWidget {
  const FlashCellView({super.key, required this.flash, this.compact = false});
  final Flash flash;
  final bool compact;
  

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FlashCellViewState();
}

class _FlashCellViewState extends ConsumerState<FlashCellView> {
  late Map<String, bool> textsToDisplay;
  late Flash _flash;
  bool _loading = false;
  bool _ownFlash = false;
  double _distance = 0.0;

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
    
    _flash = widget.flash;
    GeoPoint geoPoint = (_flash!.postLocation!.geoData)['geopoint'] as GeoPoint;
      GeoPoint currentLocation = ref.read(userCurrentLocation);
      _distance = LocationService.getDistanceBetweenPoints(geoPoint, currentLocation);
      
    _ownFlash = _flash.user.id == ref.read(currentuser).id;
  }

  @override
  Widget build(BuildContext context) {
    if(_flash.deleted) {
      return const Center(child: FZText(text: "Flash deleted", style: FZTextStyle.paragraph),);
    }
    bool collapse = MediaQuery.of(context).size.width < 800? true: false;
    return Padding(
      padding: collapse? const EdgeInsets.fromLTRB(8, 5, 8, 5):  const EdgeInsets.fromLTRB(30, 15, 30, 15),
      child: Container(
        color: Colors.white70,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildUserPanel(collapse),
            vertical(2),
            FZText(text: widget.flash.content, style: FZTextStyle.paragraph, onTap: flashNavigate, context: context, flashtagContent: true,),
            vertical(),
            if(widget.flash.imageUrl != null) FZNetworkImage(url: widget.flash.imageUrl, maxWidth: MediaQuery.of(context).size.width * 0.5,),
            vertical(2),
            Helpers.flashEngagementText(_flash, flashNavigate),
            vertical(),
            //if(!widget.compact)
              buildInteractionsView(collapse),
            
            
          ],
        ),
      ),
    );
  }

  Widget buildInteractionsView(bool collapse) {
    final isLiked = ref.read(currentuser).likes.contains(widget.flash.id);
    final likeIcon = isLiked? Icons.thumb_up_alt: Icons.thumb_up_off_alt;
    return Column(mainAxisSize: MainAxisSize.min,
      children: [
        //const Divider(height: 1,),
        _loading? const CircularProgressIndicator()
        : Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
          children: [
            IconButton(onPressed: addLike, icon: Icon(likeIcon), iconSize: collapse? 18: 26, color: isLiked? Constants.altPrimaryColor(): Constants.secondaryColor(),),
            IconButton(onPressed: flashNavigate, icon: const Icon(Icons.chat_bubble_outline), iconSize: collapse? 18: 26, color: Constants.secondaryColor(),),
            IconButton(onPressed: () => {}, icon: const Icon(Icons.repeat), iconSize: collapse? 18: 26, color: Constants.secondaryColor(),),
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
        ThumbnailView(link: widget.flash.user.avatar, mobileSize: collapse),
        // MouseRegion(
        //   cursor: SystemMouseCursors.click,
        //   child: GestureDetector(
        //     onTap: profileNavigate, 
        //     child: CircleAvatar(
        //       foregroundImage: Helpers.loadImageProvider(widget.flash.user.avatar),
        //       radius: collapse? 24: 30,
        //     )
        //   ),
        // ),
        horizontal(collapse? 1: 2),
        flashInfoView(collapse),
        const Expanded(child: SizedBox(width: double.infinity,)),
        IconButton(onPressed:() => share(context), icon: const Icon(Icons.share)),
        horizontal(collapse? 1: 3),
      ],
    );
  }

  Widget flashInfoView(bool collapse) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            vertical(),
            Row(
              children: [
                FZText(text: widget.flash.user.name, style: FZTextStyle.headline, onTap: profileNavigate,),
                horizontal(),
                if(!collapse) FZText(text: "@${widget.flash.user.username}", style: collapse? FZTextStyle.smallsubheading: FZTextStyle.subheading, color: Colors.grey, onTap: profileNavigate),
              ],
            ),
            //vertical(),
            Row(
              children: [
                FZSymbol(type: FZSymbolType.time, compact: collapse,),
                horizontal(),
                FZText(text: Helpers.getDisplayDate(widget.flash.postDate), style:collapse? FZTextStyle.smallsubheading: FZTextStyle.subheading, color: Colors.grey,),
                if(!collapse) ...[
                  horizontal(),
                  const FZSymbol(type: FZSymbolType.location),
                  horizontal(),
                  FZText(text: "$_distance miles", style: FZTextStyle.subheading, color: Colors.grey,),
                ],
              ],
            ),
            //vertical(),
            Row(
              children: [
                FZSymbol(type: FZSymbolType.community, compact: collapse,),
                horizontal(),
                FZText(text: widget.flash.community, style: FZTextStyle.paragraph),
              ],
            )
          ], 
        );
  }

  _deleteFlash() async {
    setState(() {
      _loading = true;
    });

    await ref.read(backend).deleteFlash(_flash);
    setState(() {
      _loading = false;
    });
  }

  addLike() async {
    
    if(ref.read(currentuser).likes.contains(_flash.id)) {
          return;
        }
    if(isSignedOut()) return;

    _flash.likes += 1;
    ref.read(currentuser).likes.add(_flash.id!);
    setState(() { });

    final res = await ref.read(backend).updateFlash(_flash);
    if(res.code != SuccessCode.successful) {
      _flash.likes -= 1;
      setState(() { });
    } else {
      final user = ref.read(currentuser);
      user.likes.add(_flash.id!);
      await ref.read(backend).updateProfile(user);
    }
  }

  bool isSignedOut() => ref.read(currentuser).id == FZUser.signedOutUserId;

  Widget vertical([int multiplier = 1]) => SizedBox(height: 5 * multiplier.toDouble(),);
  Widget horizontal([int multiplier = 1]) => SizedBox(width: 5 * multiplier.toDouble(),);

  profileNavigate() {
    context.go(Routes.routeNameProfile(widget.flash.user.id!));
  }

  flashNavigate() {
    context.go(Routes.routeNameFlashDetails(widget.flash.id!));
  }

  share(BuildContext ctx) {
    final url = "${Uri.base}#flash/${widget.flash.id}";
    Clipboard.setData(ClipboardData(text: url));
    Helpers.showDialogWithMessage(ctx: ctx, msg: "Link to this flash has been copied to clipboard");
  }
}