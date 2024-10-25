import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
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

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _writing = false;

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
          SizedBox(
            width: MediaQuery.of(context).size.width/4,height: 35,
            child: TextField(
                    cursorColor: Constants.primaryColor(),
                    style: const TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),),
                      hintText: 'search FlashZone',
                      fillColor: Colors.white70,
                      filled: true,
                      
                    ),
                  ),
          ),
        ],
      ), 
      actions: [
        IconButton(onPressed: () => print("3 dots pressed"), icon: const Icon(Icons.chat), iconSize: 35,),
        IconButton(
          onPressed: _editingToggle, 
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
          const SideMenuView(),
          Expanded(child: _writing? WriteFlashView(onFinished: _editingToggle,)
            : const MainFeedListView()),
        ],
      ),
    );
  }

  _editingToggle() {
    setState(() {
                            _writing = !_writing;
                          });
  }
}