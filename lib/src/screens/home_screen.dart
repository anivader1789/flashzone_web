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
import 'package:flutter/material.dart';
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
  HomeView _currentView = HomeView.flashes;
  FZUser? _userToView;
  bool _initDone = false;
  final _accountPopupController = OverlayPortalController();

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
    return Scaffold(
      appBar: AppBar(
      centerTitle: false,
      iconTheme: IconThemeData(
        color: Constants.lightColor(),
      ),
      title: Row(
        children: [
          Image.asset("assets/flashzoneR.png", height: 25,),
          const SizedBox(width: 15,),
          const FZText(text: "Your local social network", style: FZTextStyle.smallsubheading, color: Colors.white,)
        ],
      ), 
      actions: [
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
              HomeView.flashes => _initDone? MainFeedListView(profileNavigate: (user) => _profileClicked(user),): showLoading(),
              HomeView.post => WriteFlashView(onFinished: _backToFeedView,),
              HomeView.chat => const MessagesView(),
              HomeView.eventToday => const TodayEventFeedView(),
              HomeView.events => const AllEventFeedView(),
              HomeView.notifications => const NotificationsListView(),
              HomeView.profile => ProfileView(user: _userToView, backClicked: _backToFeedView, messageClicked: _messageClicked,)
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
}