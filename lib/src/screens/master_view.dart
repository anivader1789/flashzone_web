import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/cool_widgets.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/screens/account_screen.dart';
import 'package:flashzone_web/src/screens/home_screen.dart';
import 'package:flashzone_web/src/screens/subviews/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MasterView extends ConsumerStatefulWidget {
  const MasterView({super.key, required this.child, this.onInitDone, required this.sideMenuIndex});
  final Widget child;
  final Function ()? onInitDone;
  final int sideMenuIndex;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MasterViewState();
}

class _MasterViewState extends ConsumerState<MasterView> {
  bool _initDone = false;
  final _accountPopupController = OverlayPortalController();
  final _menuPopupController = OverlayPortalController();
  
  @override
  void initState() {
    super.initState();
    
    setup();
  }

  void setup() async {
    if(ref.read(initialised) == false) {
      await ref.read(backend).init();
      ref.read(initialised.notifier).update((state) => true);
      ref.read(backend).getNearbyFams(70, forceRemote: true);
    }

    setState(() {
      if(widget.onInitDone != null) {
        widget.onInitDone!();
      }
      _initDone = true;
    });
    
    
  }

  
  @override
  Widget build(BuildContext context) {
    bool smallScreenSize = MediaQuery.of(context).size.width < 800;
    final user = ref.watch(currentuser);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      centerTitle: false,
      iconTheme: IconThemeData(
        color: Constants.primaryColor(),
      ),
      title: Row(
        children: [
          Image.asset("assets/flashzoneR.png", height: smallScreenSize? 18: 25,),
          SizedBox(width: smallScreenSize? 5: 15,),
          const FZText(text: "Your local social network", style: FZTextStyle.smallsubheading, color: Colors.white,)
        ],
      ), 
      actions: smallScreenSize == true? [
            Stack(
              children: [
                IconButton(
                  iconSize: 30, 
                  icon: const Icon(Icons.menu), 
                  onPressed: _menuPopupController.toggle,),
                Positioned(
                  top: 60,
                  child: OverlayPortal(
                    controller: _menuPopupController, 
                    overlayChildBuilder: (context) => menuViewMobile(context, user),
                  ),
                ),
                SizedBox(
                  child: OverlayPortal(
                          controller: _accountPopupController, 
                          overlayChildBuilder:  (context) => AccountScreen(onDismiss: () => _accountPopupController.hide(), mobileSize: smallScreenSize,),),
                )
              ],
            ),
          ]
        : [
        RoundedBadge(onClick: () {}, title: 'Get Started', icon: const Icon(Icons.help),),
        //const SizedBox(width:10),
        //RoundedBadge(onClick: _chatClicked, title: 'Messages', icon: const Icon(Icons.forum),),
        const SizedBox(width:10),
        //IconButton(onPressed: () => _chatClicked(), icon: const Icon(Icons.forum), iconSize: 35,),
        RoundedBadge(onClick: () => _postClicked(context), title: 'New flash', icon: const Icon(Icons.add_circle),),
        const SizedBox(width:10),
        // IconButton(
        //   onPressed:() => _postClicked(context), 
        //   icon: const Icon(Icons.add_circle), 
        //   iconSize: 35,),
        RoundedBadge(onClick: _notificationsClicked, title: 'Notification', icon: const Icon(Icons.notifications),),
        //IconButton(onPressed: _notificationsClicked, icon: const Icon(Icons.notifications), iconSize: 30,),
        ElevatedButton(
          onPressed: _accountPopupController.toggle, 
          style: ButtonStyle(elevation: const MaterialStatePropertyAll(0),
            backgroundColor: MaterialStatePropertyAll(Constants.bgColor()),
            foregroundColor: MaterialStatePropertyAll(Constants.bgColor()),
            //padding: MaterialStatePropertyAll(EdgeInsets.zero)
            ),
          child: CircleAvatar(
            foregroundImage: Helpers.loadImageProvider(user.avatar), radius: 18,
            child: OverlayPortal(
              controller: _accountPopupController, 
              overlayChildBuilder:  (context) => AccountScreen(onDismiss: () => _accountPopupController.hide(), mobileSize: smallScreenSize,),),
              ),),
        //CircleAvatar(backgroundImage: Helpers.loadImageProvider("assets/profile_pic_placeholder.png")),
        const SizedBox(width: 15,),
      ],
      backgroundColor: Constants.bgColor(),
      ),
      body: Row(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SideMenuView(
            menuClicked: (view) {
              
            },
            selectedIndex: widget.sideMenuIndex,
          ),
          Expanded(
            child: _initDone? widget.child: FZLoadingIndicator(text: "Loading", mobileSize: smallScreenSize,),)
        ],
      )
      
       
    );
  }

  _postClicked(BuildContext ctx) {
    final user = ref.read(currentuser);
    bool smallScreenSize = MediaQuery.of(context).size.width < 800;

    if(user.id == FZUser.signedOutUserId) {
      Helpers.showDialogWithMessage(ctx: ctx, msg: "You have to sign into an account to post a flash");
      return;
    }

    if(user.username == null) {
      final msg = smallScreenSize?
          "Please finish creating your profile by clicking on the hamburger symbol on the top right corner and then by clicking on your name"
        : "Please finish creating your profile by clicking on the account button on top right";
      Helpers.showDialogWithMessage(ctx: ctx, msg: msg);
      return;
    }

    context.go(Routes.routeNamePost());
    
  }

  // _profileClicked(FZUser user) {
  //   setState(() {
  //     _userToView = user;
  //     _currentView = HomeView.profile;
  //   });
  // }

  // _messageClicked() {
  //   ref.read(messages)[_userToView!] = List<ChatMessage>.empty(growable: true);
  //   setState(() {
  //     _currentView = HomeView.chat;
  //   });
  // }

  _notificationsClicked() {
    context.go(Routes.routeNameNotifications());
    
  }

  // _chatClicked() {
  //   setState(() {
  //     _currentView = HomeView.chat;
  //   });
  // }

  menuViewMobile(BuildContext ctx, FZUser user) {
    
    return Stack(
      children: [ 
      Positioned.fill(
            child: GestureDetector(
              onTap: () => _menuPopupController.hide(),
              child: Container(
                color: const Color.fromARGB(200, 0, 0, 0),
              ),
            )
        ),
      
      Positioned(
        top: 50,right: 0,
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(9)),
          ),
          child: IntrinsicWidth(
            child: Column(mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: menuButtonStyle(),
                  onPressed: () { 
                    _menuPopupController.hide();
                    _postClicked(ctx); 
                  }, 
                  child: Row(children: [Icon(Icons.add_circle, color: Constants.altPrimaryColor(),), const SizedBox(width: 5,), const FZText(text: "Post", style: FZTextStyle.paragraph)],)),
                // const Divider(),
                // ElevatedButton(
                //   style: menuButtonStyle(),
                //   onPressed: () { 
                //     _menuPopupController.hide();
                //     _chatClicked(); 
                //   }, 
                //   child:  Row(children: [Icon(Icons.forum, color: Constants.altPrimaryColor(),), const SizedBox(width: 5,), const FZText(text: "Messages", style: FZTextStyle.paragraph)],)),
                const Divider(),
                ElevatedButton(
                  style: menuButtonStyle(),
                  onPressed: () { 
                    _menuPopupController.hide();
                    _notificationsClicked(); 
                  }, 
                  child:  Row(children: [Icon(Icons.notifications, color: Constants.altPrimaryColor(),), const SizedBox(width: 5,), const FZText(text: "Notifications", style: FZTextStyle.paragraph)],)),
                const Divider(),
                ElevatedButton(
                  style: menuButtonStyle(),
                  onPressed: () { 
                    _menuPopupController.hide();
                    _accountPopupController.show(); 
                  }, 
                  child: (user.id == FZUser.signedOutUserId || user.id == FZUser.interimUserId)
                    ?  Row(children: [Icon(Icons.person, color: Constants.altPrimaryColor(),), const SizedBox(width: 5,), const FZText(text: "Account", style: FZTextStyle.paragraph)],)
                    : Row(
                      children: [
                        CircleAvatar(foregroundImage: Helpers.loadImageProvider(user.avatar), radius: 11,), 
                        const SizedBox(width: 5,),
                        FZText(text: user.username ?? user.name, style: FZTextStyle.paragraph)],)),
              ],
            ),
          ),
        ),
      ),]
    );
  }

  menuButtonStyle() => const ButtonStyle(
                    overlayColor: MaterialStatePropertyAll(Colors.white),
                    surfaceTintColor:  MaterialStatePropertyAll(Colors.white),
                    elevation: MaterialStatePropertyAll(0)
                  );
}