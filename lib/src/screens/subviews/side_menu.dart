import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//https://pub.dev/packages/easy_sidemenu

class SideMenuView extends ConsumerStatefulWidget {
  const SideMenuView({super.key, required this.menuClicked, required this.selectedIndex});
  final Function (HomeView) menuClicked;
  final int selectedIndex;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SideMenuViewState();
}

class _SideMenuViewState extends ConsumerState<SideMenuView> {

  PageController pageController = PageController();
  late SideMenuController sideMenu = SideMenuController();
  List items = List.empty(growable: true);

  @override
  void initState() {
    // Connect SideMenuController and PageController together
    // sideMenu.addListener((index) {
    //   //pageController.jumpToPage(index);
    // });
    super.initState();
    print("side menu loading with: ${widget.selectedIndex}");
    //sideMenu = SideMenuController(initialPage: widget.selectedIndex);

    populateMenuItems();
  }

  void populateMenuItems() {
    // items.add(SideMenuItem(
    //   title: 'Events',
    //   onTap: (index, _) {
        
    //   },
    //   icon: const Icon(Icons.home),
    //   badgeContent: const Text(
    //     'Live',
    //     style: TextStyle(color: Colors.white),
    //   ),
    // ));

    items.add(SideMenuItem(
      title: 'Home',
      onTap: (index, _) {
        //widget.menuClicked(HomeView.flashes);
        Navigator.pushNamed(context, "");
      },
      icon: const Icon(Icons.home),
      // badgeContent: const Text(
      //   '3',
      //   style: TextStyle(color: Colors.white),
      // ),
    ));

    items.add(SideMenuItem(
          title: 'Events',
          onTap: (index, _) {
            sideMenu.changePage(index);
            //widget.menuClicked(HomeView.eventToday);
            Navigator.pushNamed(context, "events");
          },
          icon: const Icon(Icons.event),
          // badgeContent: const Text(
          //   '2',
          //   style: TextStyle(color: Colors.white),
          // ),
        ));

    // final supermenu = SideMenuExpansionItem(
    //   title: "Events Now",
    //   icon: const Icon(Icons.kitchen),
      
    //   children: [
    //     SideMenuItem(
    //       title: 'Events Today',
    //       onTap: (index, _) {
    //         sideMenu.changePage(index);
    //         //widget.menuClicked(HomeView.eventToday);
    //         Navigator.pushReplacementNamed(context, "eventstoday");
    //       },
    //       icon: const Icon(Icons.stream),
    //       badgeContent: const Text(
    //         '2',
    //         style: TextStyle(color: Colors.white),
    //       ),
    //     ),
    //     SideMenuItem(
    //       title: 'Upcoming Events',
    //       onTap: (index, _) {
    //         sideMenu.changePage(index);
    //         //widget.menuClicked(HomeView.events);
    //         Navigator.pushReplacementNamed(context, "eventsall");
    //       },
    //       icon: const Icon(Icons.upcoming),
    //       badgeContent: const Text(
    //         '9',
    //         style: TextStyle(color: Colors.white),
    //       ),
    //     )
    //   ],
    // );

    // items.add(supermenu);


    // items.add(SideMenuItem(
    //   title: 'My FlashTags',
    //   onTap: (index, _) {
        
    //   },
    //   icon: const Icon(Icons.electric_bolt),
    // ));

    // items.add(SideMenuItem(
    //   title: 'Settings',
    //   onTap: (index, _) {
        
    //   },
    //   icon: const Icon(Icons.settings),
    // ));

    items.add(SideMenuItem(
      title: 'Terms & Conditions',
      onTap: (index, _) {
        
      },
      icon: const Icon(Icons.description),
    ));

    items.add(SideMenuItem(
      title: 'About',
      onTap: (index, _) {
        
      },
      icon: const Icon(Icons.help),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SideMenu(
        style: menuStyle(),
        // Page controller to manage a PageView
        controller: sideMenu,
        // Will shows on top of all items, it can be a logo or a Title text
        //title: const Icon(Icons.menu, size: 30,),
        // Will show on bottom of SideMenu when displayMode was SideMenuDisplayMode.open
        footer: const FZText(text: 'FlashZone Inc.', style: FZTextStyle.subheading, color: Colors.white,),
        // Notify when display mode changed
        onDisplayModeChanged: (mode) {
          //print(mode);
        },
        // List of SideMenuItem to show them on SideMenu
        items: items,
      );
  }

  SideMenuStyle menuStyle() => 
      SideMenuStyle(
          displayMode: SideMenuDisplayMode.auto,
          //decoration: BoxDecoration(),
          openSideMenuWidth: 250,
          compactSideMenuWidth: 60,
          hoverColor: Constants.lightColor(),
          selectedColor: Constants.primaryColor(),
          selectedIconColor: Colors.white,
          unselectedIconColor: Colors.white,
          backgroundColor: Constants.bgColor(),
          selectedTitleTextStyle: const TextStyle(color: Colors.white),
          unselectedTitleTextStyle: const TextStyle(color: Colors.white),
          iconSize: 20,
          itemBorderRadius: const BorderRadius.all(
            Radius.circular(5.0),
          ),
          showTooltip: true,
          showHamburger: true,
          itemHeight: 50.0,
          itemInnerSpacing: 8.0,
          itemOuterPadding: const EdgeInsets.symmetric(horizontal: 5.0),
          toggleColor: Colors.black54,

          // Additional properties for expandable items
          selectedTitleTextStyleExpandable: const TextStyle(color: Colors.white), // Adjust the style as needed
          unselectedTitleTextStyleExpandable: const TextStyle(color: Colors.white), // Adjust the style as needed
          selectedIconColorExpandable: Colors.white, // Adjust the color as needed
          unselectedIconColorExpandable: Colors.white, // Adjust the color as needed
          arrowCollapse: Colors.blueGrey, // Adjust the color as needed
          arrowOpen: Colors.lightBlueAccent, // Adjust the color as needed
          iconSizeExpandable: 24.0, // Adjust the size as needed
    );

}