import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/screens/subviews/flash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key, required this.user, required this.backClicked, required this.messageClicked});
  final FZUser? user;
  final Function () backClicked;
  final Function () messageClicked;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  List<Flash> _flashes = List.empty(growable: true);
  
  @override
  void initState() {
    super.initState();
    
    final allFlashes = ref.read(flashes);
    for(final flash in allFlashes) {
      if (flash.user.name == widget.user!.name) {
        _flashes.add(flash);
      }
    }

  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft, 
            height: 50,
            child: FZIconButton(tint: Colors.grey, icon: Icons.arrow_back, onPressed: widget.backClicked),
          ),
          vertical(),
          Row(
            children: [
              horizontal(),
              CircleAvatar(
                backgroundImage: Helpers.loadImageProvider(widget.user!.avatar),
                radius: 40,
              ),
              horizontal(),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FZText(text: widget.user!.name, style: FZTextStyle.largeHeadline),
                    vertical(),
                    FZText(text: widget.user!.username, style: FZTextStyle.paragraph),
                    vertical(),
                    
                  ],
                ),
              ),
              FZButton(onPressed: widget.messageClicked, text: "Message", bgColor: Constants.fillColor(), textColor: Colors.white,),
              horizontal()
            ],
          ),
          vertical(),
          const Divider(),
          vertical(),
          const FZText(text: "Activity", style: FZTextStyle.headline),
          vertical(),
          Expanded(child: buildFlashesView(),),
          
        ],
      ),
    );
  }

  vertical([double multiple = 1]) {
    return SizedBox(height: 15 * multiple,);
  }

  horizontal([double multiple = 1]) {
    return SizedBox(width: 15 * multiple,);
  }
  
  buildFlashesView() {
    return  ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 5,),
                        itemCount: _flashes.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            //onTap: () => ,
                            child: FlashCellView(
                                flash: _flashes[index],
                                profileClicked: (user) {},
                                compact: true,
                            ),
                          );
                        },
                      );
  }
}