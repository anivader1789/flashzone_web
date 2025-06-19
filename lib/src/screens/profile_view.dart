import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/screens/master_view.dart';
import 'package:flashzone_web/src/screens/subviews/flash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key, required this.userId});
  final String? userId;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  List<Flash> _flashes = List.empty(growable: true);
  bool _loading = false;
  FZUser? _user;
  

  void loadUser() async {
    if(widget.userId == null) return;
    setState(() {
      _loading = true;
    });
    _user = await ref.read(backend).fetchRemoteUser(widget.userId!);

    setState(() {
      _loading = false;
    });

    loadUserFlashes();
  }

  void loadUserFlashes() {
    final allFlashes = ref.read(flashes);
    for(final flash in allFlashes) {
      if (flash.user.name == _user!.name) {
        _flashes.add(flash);
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    bool mobileSize = MediaQuery.of(context).size.width < 800;
    return MasterView(
      onInitDone: () {
        Future(() => loadUser());
      },
      child: childView(mobileSize), 
      sideMenuIndex: 0);
    
  }

  childView(bool mobileSize) {
    if(_loading) {
      return FZLoadingIndicator(text: "Loading this user's data", mobileSize: mobileSize);
    }

    if(_user == null) {
      return const Center(child: FZText(text: "User could not be loaded", style: FZTextStyle.largeHeadline, color: Colors.grey,),);
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          //backButtonRow(),
          vertical(mobileSize? 4: 2),
          Row(
            children: [
              horizontal(),
              CircleAvatar(
                backgroundImage: Helpers.loadImageProvider(_user!.avatar),
                radius: mobileSize? 24: 40,
              ),
              horizontal(),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FZText(text: _user!.name, style: mobileSize? FZTextStyle.headline: FZTextStyle.largeHeadline),
                    //vertical(),
                    FZText(text: "@${_user!.username}", style: FZTextStyle.paragraph),
                    vertical(),
                    
                  ],
                ),
              ),
              // widget.mobileSize?
              //   IconButton(onPressed: widget.messageClicked, icon: const Icon(Icons.chat_bubble,))
              // : FZButton(
              //   onPressed: widget.messageClicked, 
              //   text: "Message", 
              //   bgColor: Constants.primaryColor(),
              //   textColor: Colors.white,),
              horizontal()
            ],
          ),
          vertical(),
          FZText(text: _user!.bio, style: FZTextStyle.paragraph),
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
    return SizedBox(height: 10 * multiple,);
  }

  horizontal([double multiple = 1]) {
    return SizedBox(width: 10 * multiple,);
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
                                compact: true,
                            ),
                          );
                        },
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
                    context.go(Routes.routeNameHome());
                  });
                }
              ),
              horizontal(),
              const FZText(text: "Flash List", style: FZTextStyle.paragraph)
            ],);
  }

}