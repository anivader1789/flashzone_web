import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/chat.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/screens/account_screen.dart';
import 'package:flashzone_web/src/screens/events_feed.dart';
import 'package:flashzone_web/src/screens/main_feed.dart';
import 'package:flashzone_web/src/screens/messages_view.dart';
import 'package:flashzone_web/src/screens/notifications_list_view.dart';
import 'package:flashzone_web/src/screens/profile_view.dart';
import 'package:flashzone_web/src/screens/subviews/side_menu.dart';
import 'package:flashzone_web/src/screens/write_flash.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  
  static const routeName = '/';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();

}

enum HomeView {
  flashes, post, chat, eventToday, events, profile, notifications
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _smallScreenSize = false;
  HomeView _currentView = HomeView.flashes;
  FZUser? _userToView;
  bool _initDone = false;
  final _accountPopupController = OverlayPortalController();
  final _menuPopupController = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    
    initBackend();
  }

  void initBackend() async {
    await ref.read(backend).init();
    setState(() {
      _initDone = true;
    });
  }
 
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    _setScreenScale(width,height);

    return Scaffold(
      appBar: AppBar(
      centerTitle: false,
      iconTheme: IconThemeData(
        color: Constants.lightColor(),
      ),
      title: Row(
        children: [
          Image.asset("assets/flashzoneR.png", height: _smallScreenSize? 18: 25,),
          SizedBox(width: _smallScreenSize? 5: 15,),
          const FZText(text: "Your local social network", style: FZTextStyle.smallsubheading, color: Colors.white,)
        ],
      ), 
      actions: _smallScreenSize == true? [
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
                    overlayChildBuilder: (context) => menuViewMobile(context),
                  ),
                ),
                SizedBox(
                  child: OverlayPortal(
                          controller: _accountPopupController, 
                          overlayChildBuilder:  (context) => AccountScreen(onDismiss: () => _accountPopupController.hide(),),),
                )
              ],
            ),
          ]
        : [
        IconButton(onPressed: () => print("3 dots pressed"), icon: const Icon(Icons.room), iconSize: 30,),
        IconButton(onPressed: () => _chatClicked(), icon: const Icon(Icons.forum), iconSize: 35,),
        IconButton(
          onPressed:() => _postClicked(context), 
          icon: const Icon(Icons.add_circle), 
          iconSize: 35,),
        IconButton(onPressed: _notificationsClicked, icon: const Icon(Icons.notifications), iconSize: 30,),
        ElevatedButton(
          onPressed: _accountPopupController.toggle, 
          style: const ButtonStyle(
            backgroundColor: MaterialStatePropertyAll(Colors.grey),
            foregroundColor: MaterialStatePropertyAll(Colors.grey),
            padding: MaterialStatePropertyAll(EdgeInsets.zero)),
          child: CircleAvatar(
            backgroundImage: Helpers.loadImageProvider("assets/profile_pic_placeholder.png"),
            child: OverlayPortal(
              controller: _accountPopupController, 
              overlayChildBuilder:  (context) => AccountScreen(onDismiss: () => _accountPopupController.hide(),),),
              ),),
        //CircleAvatar(backgroundImage: Helpers.loadImageProvider("assets/profile_pic_placeholder.png")),
        const SizedBox(width: 15,),
      ],
      backgroundColor: Colors.grey,
      ),
      body: 
      Row(mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenuView(
            menuClicked: (view) {
              setState(() {
                _currentView = view;
              });
            },
          ),
          Expanded(
            child: switch (_currentView) {
              HomeView.flashes => _initDone == false? showLoading() : MainFeedListView(profileNavigate: (user) => _profileClicked(user), mobileSize: _smallScreenSize,),
              HomeView.post => WriteFlashView(onFinished: _backToFeedView,),
              HomeView.chat => MessagesView(mobileSize: _smallScreenSize,),
              HomeView.eventToday => _initDone == false? showLoading() : TodayEventFeedView(mobileSize: _smallScreenSize,),
              HomeView.events => _initDone == false? showLoading() :   AllEventFeedView(mobileSize: _smallScreenSize,),
              HomeView.notifications => _initDone == false? showLoading() : NotificationsListView(mobileSize: _smallScreenSize,),
              HomeView.profile => ProfileView(user: _userToView, backClicked: _backToFeedView, messageClicked: _messageClicked, mobileSize: _smallScreenSize,)
            }),
        ],
      ),
    );
  }

  // _accountClicked() {
    
  // }

  showLoading() {
    return Center(
      child: SizedBox(width: 70, height: 70, child: CircularProgressIndicator(color: Constants.primaryColor(),)),
    );
  }

  _backToFeedView() {
    setState(() {
      _currentView = HomeView.flashes;
    });
  }

  _postClicked(BuildContext ctx) {
    final user = ref.read(currentuser);

    if(user.id == "dummy" || user.username == null) {
      Helpers.showDialogWithMessage(ctx: ctx, msg: "Please finish creating your profile first");
      return;
    }

    setState(() {
      _currentView = HomeView.post;
    });
  }

  _profileClicked(FZUser user) {
    setState(() {
      _userToView = user;
      _currentView = HomeView.profile;
    });
  }

  _messageClicked() {
    ref.read(messages)[_userToView!] = List<ChatMessage>.empty(growable: true);
    setState(() {
      _currentView = HomeView.chat;
    });
  }

  _notificationsClicked() {
    setState(() {
      _currentView = HomeView.notifications;
    });
  }

  _chatClicked() {
    setState(() {
      _currentView = HomeView.chat;
    });
  }

  menuViewMobile(BuildContext ctx) {
    
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
                  child: const Row(children: [Icon(Icons.add_circle), FZText(text: "Post", style: FZTextStyle.paragraph)],)),
                const Divider(),
                ElevatedButton(
                  style: menuButtonStyle(),
                  onPressed: () { 
                    _menuPopupController.hide();
                    _chatClicked(); 
                  }, 
                  child: const Row(children: [Icon(Icons.forum), FZText(text: "Messages", style: FZTextStyle.paragraph)],)),
                const Divider(),
                ElevatedButton(
                  style: menuButtonStyle(),
                  onPressed: () { 
                    _menuPopupController.hide();
                    _notificationsClicked(); 
                  }, 
                  child: const Row(children: [Icon(Icons.notifications), FZText(text: "Notifications", style: FZTextStyle.paragraph)],)),
                const Divider(),
                ElevatedButton(
                  style: menuButtonStyle(),
                  onPressed: () { 
                    _menuPopupController.hide();
                    _accountPopupController.show(); 
                  }, 
                  child: const Row(children: [Icon(Icons.person), FZText(text: "Account", style: FZTextStyle.paragraph)],)),
              ],
            ),
          ),
        ),
      ),]
    );
  }

  _setScreenScale(double width, double height) {
    if(height < 720 || width < 480) {
      setState(() {
        _smallScreenSize = true;
      });
    } else {
      setState(() {
        _smallScreenSize = false;
      });
    }
  }

  menuButtonStyle() => const ButtonStyle(
                    overlayColor: MaterialStatePropertyAll(Colors.white),
                    surfaceTintColor:  MaterialStatePropertyAll(Colors.white),
                    elevation: MaterialStatePropertyAll(0)
                  );
}