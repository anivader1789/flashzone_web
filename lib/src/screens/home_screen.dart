import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/cool_widgets.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/chat.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/screens/account_screen.dart';
import 'package:flashzone_web/src/screens/admin_eventcreationscreen.dart';
import 'package:flashzone_web/src/screens/event_detail_view.dart';
import 'package:flashzone_web/src/screens/events_feed.dart';
import 'package:flashzone_web/src/screens/fam_chat_screen.dart';
import 'package:flashzone_web/src/screens/fam_edit_screen.dart';
import 'package:flashzone_web/src/screens/fam_list_screen.dart';
import 'package:flashzone_web/src/screens/fam_screen.dart';
import 'package:flashzone_web/src/screens/flash_detail_screen.dart';
import 'package:flashzone_web/src/screens/main_feed.dart';
import 'package:flashzone_web/src/screens/messages_view.dart';
import 'package:flashzone_web/src/screens/notifications_list_view.dart';
import 'package:flashzone_web/src/screens/profile_view.dart';
import 'package:flashzone_web/src/screens/subviews/side_menu.dart';
import 'package:flashzone_web/src/screens/write_flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final initialised = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.route});
  final String? route;
  
  static const routeName = '/';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();

}

enum HomeView {
  flashes, post, chat, eventToday, events, eventDetails, 
  profile, notifications, flashDetail, loading, admineventcreate,
  famsList,famPage,famAddNew,famChat
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _smallScreenSize = false;
  HomeView _currentView = HomeView.loading;
  FZUser? _userToView;
  String? _flashId, _profileId, _eventId, _famId;
  Flash? _flashtoView;
  int _sideMenuDefaultSelected = 0;
  final _accountPopupController = OverlayPortalController();
  final _menuPopupController = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    
    setup();
    //goToRoute();
  }

  void setup() async {
    if(ref.read(initialised) == false) {
      await ref.read(backend).init();
      ref.read(initialised.notifier).update((state) => true);
      ref.read(backend).getNearbyFams(70, forceRemote: true);
    }
    goToRoute();
  }

  void goToRoute() async {
    final route = widget.route;
    //Based on the route, we will set the current view
    //and the flashId if needed
    //This is a bit of a hack, but we need to set the current view
    //based on the route, so we can show the correct view
    

    if(route == null || route == "") {
      _currentView = HomeView.flashes;
    } else if(route.contains("flash")) {
      _flashId = route.substring(6);
      print("Trying to load flash: $_flashId");
      if(_flashId != null && _flashId!.isNotEmpty) {
        final flashesRef = ref.read(flashes);
        if(flashesRef.isNotEmpty) {
          _flashtoView = flashesRef.firstWhere((element) => element.id == _flashId);
        }

        _flashtoView ??= await ref.read(backend).fetchFlash(_flashId!);
        _currentView = HomeView.flashDetail;
      } else {
        _currentView = HomeView.flashes;
      }
    } else if(route.contains("user")) {
      _profileId = route.substring(5);

      _currentView = HomeView.profile;
    } else if(route.contains("eventstoday")) {

      _currentView = HomeView.eventToday;
    } else if(route.contains("events")) {
      if(route.length > 7) {
        _eventId = route.substring(7);
        print("Trying to load event: $_eventId");
        if(_eventId != null && _eventId!.isNotEmpty) {

          _currentView = HomeView.eventDetails;
        } else {
          _currentView = HomeView.events;
        }
      } else {
        _currentView = HomeView.events;
      }

      _sideMenuDefaultSelected = 1;
      print("changed side menu index to: $_sideMenuDefaultSelected");
      
    } else if(route.contains(FamChatScreen.routeName)) {
      if(route.length > 8) {
        _famId = route.substring(8);
        if(_famId != null && _famId!.isNotEmpty) {

          _currentView = HomeView.famChat;
        } else {
          _currentView = HomeView.famsList;
        }
      }
    } else if(route.contains("fams")) {
      if(route.length > 5) {
        _famId = route.substring(5);
        if(_famId != null && _famId!.isNotEmpty) {

          _currentView = HomeView.famPage;
        } else {
          _currentView = HomeView.famsList;
        }
      } else {
        _currentView = HomeView.famsList;
      }

      _sideMenuDefaultSelected = 2;
      print("changed side menu index to: $_sideMenuDefaultSelected");
      
    } else if(route.contains(FamEditScreen.routeName)) {

      _currentView = HomeView.famAddNew;
    }  else if(route.contains(NotificationsListView.routeName)) {

      _currentView = HomeView.notifications;
    } else if(route.contains(WriteFlashView.routeName)) {

      _currentView = HomeView.post;
    } else if(route.contains(AdminEventCreation.routeName)) {

      _currentView = HomeView.admineventcreate;
    } 
  }
 
  @override
  Widget build(BuildContext context) {
    //bool initDone = ref.watch(initialised);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    _setScreenScale(width,height);

    final _user = ref.watch(currentuser);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      centerTitle: false,
      iconTheme: IconThemeData(
        color: Constants.primaryColor(),
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
                    overlayChildBuilder: (context) => menuViewMobile(context, _user),
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
            foregroundImage: Helpers.loadImageProvider(_user.avatar), radius: 18,
            child: OverlayPortal(
              controller: _accountPopupController, 
              overlayChildBuilder:  (context) => AccountScreen(onDismiss: () => _accountPopupController.hide(),),),
              ),),
        //CircleAvatar(backgroundImage: Helpers.loadImageProvider("assets/profile_pic_placeholder.png")),
        const SizedBox(width: 15,),
      ],
      backgroundColor: Constants.bgColor(),
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
            selectedIndex: _sideMenuDefaultSelected,
          ),
          // Expanded(
          //   child: switch (_currentView) {
          //     HomeView.flashes => initDone == false? showLoading() : MainFeedListView(profileNavigate: (user) => _profileClicked(user), mobileSize: _smallScreenSize,),
          //     HomeView.post => WriteFlashView(onFinished: _backToFeedView,),
          //     HomeView.chat => MessagesView(mobileSize: _smallScreenSize,),
          //     HomeView.eventToday => initDone == false? showLoading() : TodayEventFeedView(mobileSize: _smallScreenSize,),
          //     HomeView.events => initDone == false? showLoading() : EventFeedView(mobileSize: _smallScreenSize,),
          //     HomeView.famsList => initDone == false? showLoading() : FamListScreen(mobileSize: _smallScreenSize,),
          //     HomeView.famPage => initDone == false? showLoading() : FamHomeScreen(famId: _famId!, mobileSize: _smallScreenSize,),
          //     HomeView.famChat => initDone == false? showLoading() : FamChatScreen(famId: _famId!, mobileSize: _smallScreenSize,),
          //     HomeView.famAddNew => initDone == false? showLoading() : FamEditScreen(mobileSize: _smallScreenSize,),
          //     HomeView.notifications => initDone == false? showLoading() : NotificationsListView(mobileSize: _smallScreenSize,),
          //     HomeView.profile => ProfileView(userId: _profileId, backClicked: _backToFeedView, messageClicked: _messageClicked, mobileSize: _smallScreenSize,),
          //     HomeView.flashDetail => initDone == false? showLoading() : FlashDetailScreen(flash: _flashtoView, compact: _smallScreenSize),
          //     HomeView.eventDetails => initDone == false? showLoading() : EventDetailsView(eventId: _eventId, mobileSize: _smallScreenSize),
          //     HomeView.admineventcreate => const AdminEventCreation(),
          //     HomeView.loading => showLoading()
          //   }),
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

    if(user.id == FZUser.signedOutUserId) {
      Helpers.showDialogWithMessage(ctx: ctx, msg: "You have to sign into an account to post a flash");
      return;
    }

    if(user.username == null) {
      Helpers.showDialogWithMessage(ctx: ctx, msg: "Please finish creating your profile by clicking on the account button on top right");
      return;
    }

    context.go(Routes.routeNamePost());
    
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
    
  }

  _chatClicked() {
    setState(() {
      _currentView = HomeView.chat;
    });
  }

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
                        FZText(text: user.name, style: FZTextStyle.paragraph)],)),
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