import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/local%20use/button_data.dart';
import 'package:flashzone_web/src/screens/account_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemedNavBar extends StatefulWidget {
  const ThemedNavBar({
    super.key,
    required this.titleWidget,
    required this.buttonsDataList,
    required this.userAvatar,});
  final Widget titleWidget;
  final List<ButtonData> buttonsDataList;
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

    for (var data in widget.buttonsDataList) {
      navDesktopRow.add(
        TextButton(
          onPressed: data.onPressed, 
          child: Text(data.label, style: const TextStyle(color: Colors.white),),
        )
      );
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
    List<Widget> buttonsList = [];
    for (var data in widget.buttonsDataList) {
      buttonsList.add(
        ListTile(
          leading: data.icon != null ? Icon(data.icon) : null,
          title: Text(data.label),
          onTap: () {
            _menuPopupController.hide();
            if(data.onPressed != null) {
              data.onPressed!();
            }
          },
        )
      );
    }

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...buttonsList,
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