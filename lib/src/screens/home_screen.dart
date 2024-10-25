import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/screens/events_feed.dart';
import 'package:flashzone_web/src/screens/main_feed.dart';
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
  flashes, post, eventToday, events
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  HomeView _currentView = HomeView.flashes;

  @override
  void initState() {
    super.initState();
    
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
        IconButton(onPressed: () => print("3 dots pressed"), icon: const Icon(Icons.forum), iconSize: 35,),
        IconButton(
          onPressed: _postClicked, 
          icon: const Icon(Icons.add_circle), 
          iconSize: 35,),
        IconButton(onPressed: () => print("3 dots pressed"), icon: const Icon(Icons.notifications), iconSize: 30,),
        CircleAvatar(backgroundImage: Helpers.loadImageProvider("assets/profile_pic_placeholder.png")),
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
              HomeView.flashes => const MainFeedListView(),
              HomeView.post => WriteFlashView(onFinished: _editingFinished,),
              HomeView.eventToday => const EventFeedView(today: true,),
              HomeView.events => const EventFeedView(today: false,),
            }),
        ],
      ),
    );
  }

  _editingFinished() {
    setState(() {
                            _currentView = HomeView.flashes;
                          });
  }

  _postClicked() {
    setState(() {
      _currentView = HomeView.post;
    });
  }
}