import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/screens/account_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemedNavBar extends StatefulWidget {
  const ThemedNavBar({
    super.key,
    required this.titleWidget,
    required this.actions,
    required this.userAvatar,});
  final Widget titleWidget;
  final List<Widget> actions;
  final String? userAvatar;

  @override
  State<ThemedNavBar> createState() => _ThemedNavBarState();
}

class _ThemedNavBarState extends State<ThemedNavBar> {
  final _accountPopupController = OverlayPortalController();
  final _menuPopupController = OverlayPortalController();
  List<Widget> navDesktopRow = [];

  @override
  void initState() {
    super.initState();

    for (var action in widget.actions) {
      navDesktopRow.add(action);
      navDesktopRow.add(horizontal());
    }
  }
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    bool isDesktop = screenSize.width >= 800;

    return Container(
        width: screenSize.width,
        height: 60,
        color: Colors.black.withOpacity(0.7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.titleWidget,
              isDesktop ?
                Row(
                  children: [
                    ...navDesktopRow,
                    const Icon(CupertinoIcons.cart, color: Colors.white,),
                    horizontal(4),
                    ElevatedButton(
                      onPressed: _accountPopupController.toggle, 
                      style: ButtonStyle(elevation: const MaterialStatePropertyAll(0),
                        backgroundColor: MaterialStatePropertyAll(Constants.bgColor()),
                        foregroundColor: MaterialStatePropertyAll(Constants.bgColor()),
                        //padding: MaterialStatePropertyAll(EdgeInsets.zero)
                        ),
                      child: CircleAvatar(
                        foregroundImage: Helpers.loadImageProvider(widget.userAvatar), radius: 18,
                        child: OverlayPortal(
                          controller: _accountPopupController, 
                          overlayChildBuilder:  (context) => AccountScreen(onDismiss: () => _accountPopupController.hide(), mobileSize:!isDesktop,),),
                          ),),
                  ],
                )
              
              : Row(
                  children: [
                //Expanded(child: Container()),
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
                              overlayChildBuilder:  (context) => AccountScreen(onDismiss: () => _accountPopupController.hide(), mobileSize: !isDesktop,),),
                    )
                  ],
                ),
                // const IconButton(
                //   onPressed: , 
                //   icon: Icon(CupertinoIcons.bars, color: Colors.white,),
                // )
              ])
  ],),
        ),
      );
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
                ...widget.actions,
                const Divider(),
                ListTile(
                  leading: const Icon(CupertinoIcons.cart),
                  title: const Text("Cart"),
                  onTap: () {},
                ),
                ListTile(
                  leading: CircleAvatar(
                    foregroundImage: Helpers.loadImageProvider(widget.userAvatar), radius: 12,
                  ),
                  title: const Text("Account"),
                  onTap: () { 
                    _menuPopupController.hide();
                    _accountPopupController.show();
                  },
                ),
              ]
                
            ),
          ),
        ),
      ),]
    );
  }

  Widget horizontal([int multiplier = 1]) => SizedBox(width: 5 * multiplier.toDouble(),);
}