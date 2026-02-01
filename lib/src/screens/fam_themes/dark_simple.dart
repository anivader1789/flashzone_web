import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/model/fam.dart';
import 'package:flashzone_web/src/model/fam_page_content.dart';
import 'package:flashzone_web/src/model/local%20use/button_data.dart';
import 'package:flashzone_web/src/model/store.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/screens/account_screen.dart';
import 'package:flashzone_web/src/screens/fam_dm_screen.dart';
import 'package:flashzone_web/src/screens/purchase%20screens/book_session_view.dart';
import 'package:flashzone_web/src/screens/subviews/themed_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DarkSimpleThemePage extends ConsumerStatefulWidget {
  const DarkSimpleThemePage(this.fam, {super.key});
  final Fam fam; 

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DarkSimpleThemePageState();
}

class _DarkSimpleThemePageState extends ConsumerState<DarkSimpleThemePage> {
  //final _bookSessionPopupController = OverlayPortalController();
  final _ctaPopupControllersList = <OverlayPortalController>[];
  final _chatPopupController = OverlayPortalController();
  final _loginPopupController = OverlayPortalController();
  //final _checkoutPopupController = OverlayPortalController();
  //final _cartPopupController = OverlayPortalController();
  FZUser? famAdmin;

  late List<Widget> pageViews;
  final ItemScrollController itemScrollController = ItemScrollController();
  
  @override
  void initState() {
    super.initState();
    for (var item in widget.fam.pageContent?.storeItems ?? []) {
      _ctaPopupControllersList.add(OverlayPortalController());
    }



    loadAdminUser();
  }

  buildPageViews() {
    
  }

  loadAdminUser() async {
    famAdmin = await ref.read(backend).fetchRemoteUser(widget.fam.admins[0]);
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {

    if(widget.fam.pageContent == null) {
      return Container();
    }

    FamPageContent content = widget.fam.pageContent!;
    Size screenSize = MediaQuery.of(context).size;
    bool isMobile = screenSize.width < 800;

    pageViews = [
              heroSection(screenSize, content, isMobile), 
              //vertical(2),
              //const FZText(text: "Helloo", style: FZTextStyle.headline,),
              midSection(screenSize, isMobile, content.midSections[0]),
              //vertical(),            
              joinFamSection(screenSize, content),
              //vertical(),
              midSection(screenSize, isMobile, content.midSections[1], true),
              //vertical(),
              if(content.storeItems != null && content.storeItems!.isNotEmpty)
                storeSection(screenSize, isMobile, content.storeItems!),

              //vertical(),
              sendMessageSection(screenSize),
              //...content.midSections.map((section) => midSection(screenSize, section)).toList(),
              //vertical(9),
              footerSection(screenSize),
            ];

    return Stack(
      children: [
        //FZNetworkImage(url: content.heroImageUrl, maxWidth: screenSize.width),
         Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(content.heroImageUrl ?? ""),
            ),
          ),
          height: screenSize.height,
        ),
        ScrollablePositionedList.builder(
          itemCount: pageViews.length, 
          itemScrollController: itemScrollController,
          itemBuilder: (context, index) {
            return pageViews[index];
          },),
      //   SingleChildScrollView(
      //     child: Column(
      //       children: [
      //         heroSection(screenSize, content, isMobile), 
      //         //vertical(2),
      //         //const FZText(text: "Helloo", style: FZTextStyle.headline,),
      //         midSection(screenSize, isMobile, content.midSections[0]),
      //         //vertical(),            
      //         joinFamSection(screenSize, content),
      //         //vertical(),
      //         midSection(screenSize, isMobile, content.midSections[1], true),
      //         //vertical(),
      //         if(content.storeItems != null && content.storeItems!.isNotEmpty)
      //           storeSection(screenSize, isMobile, content.storeItems!),

      //         //vertical(),
      //         sendMessageSection(screenSize),
      //         //...content.midSections.map((section) => midSection(screenSize, section)).toList(),
      //         //vertical(9),
      //         footerSection(screenSize),
      //       ],
      //   ),
      // ),
      //Top navigation bar
      ThemedNavBar(
        titleWidget: themeText(widget.fam.name, color: Colors.yellow, size: 24, weight: FontWeight.bold, italic: true), 
        buttonsDataList: [
          ButtonData(
            label: "Book a session", 
            onPressed: () {
              if(content.storeItems != null && content.storeItems!.isNotEmpty) {
                itemScrollController.scrollTo(index: 4, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
              }
            }, 
            icon: Icons.book_online,),
          ButtonData(
            label: "Send a message", 
            onPressed: () {
              itemScrollController.scrollTo(index: 5, duration: const Duration(seconds: 1), curve: Curves.easeInOut);
            }, 
            icon: Icons.chat,),
        ], 
        user: ref.read(currentuser),
        famAdmin: famAdmin,),

        OverlayPortal(
          controller: _loginPopupController, 
          overlayChildBuilder: (context) => AccountScreen(onDismiss: () => _loginPopupController.hide(), mobileSize: false,),
          child:  Container(),)
      ],
      

    );
  }

  heroSection(Size screenSize, FamPageContent content, bool isMobileView) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              opacity: 0.35,
              fit: BoxFit.cover,
              image: NetworkImage(content.heroImageUrl ?? ""),
            ),
          ),
          height: screenSize.height,
        ),
        Container(
              width: screenSize.width,
              height: screenSize.height * 0.9,
              color: Colors.transparent,
              //color: Colors.black,
              child: Center(
                child: IntrinsicWidth(
                  child: Column(
                    children: [
                      SizedBox(height: screenSize.height * 0.6,),
                      themeText(content.heroHeading ?? "", size: isMobileView? 24: 44, color: Colors.white),
                      const Divider(color: Colors.white70, thickness: 3.5,),
                      vertical(),
                      themeText(content.heroSubheading ?? "", italic: true, color: Color.fromARGB(255, 215, 180, 53), size: isMobileView? 16: 24,),
                    ],
                  ),
                ),
              ),
            ),]
    );
  }

  midSection(Size screenSize, bool isMobileView, MidSectionContent section,[ bool imageLeftAligned = false]) {
    Widget imageWidget = Container(
          decoration: BoxDecoration(
            //color: Colors.black,
            image: DecorationImage(
              //opacity: 0.35,
              fit: BoxFit.cover,
              image: NetworkImage(section.imageUrl ?? ""),
            ),
          ),
          height: 450,
        );

    Widget textSection = Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            vertical(),
            themeText(section.heading, isPrimaryFont: false, weight: FontWeight.bold, size: 32, ),
                vertical(),
                themeText(section.description, isPrimaryFont: false),
          ],
        );
    if(section.imageUrl == null) {
      return Container(
        width: screenSize.width,
        color: Colors.white,
        padding: EdgeInsets.only(
          top: screenSize.height * 0.05, 
          bottom: screenSize.height * 0.02, 
          left: screenSize.width * 0.1, 
          right: screenSize.width * 0.1),
        child: textSection,
      );
    }

    if(isMobileView) {
      return Container(
      width: screenSize.width,
      color: Colors.white,
      padding: EdgeInsets.only(
        top: screenSize.height * 0.05, 
        bottom: screenSize.height * 0.02, 
        left: screenSize.width * 0.1, 
        right: screenSize.width * 0.1),
      child: Column(
        children: [
          imageWidget,
          vertical(4),
          textSection,
        ],
      ),
    );
    }

    if(imageLeftAligned) {
      return Container(
      width: screenSize.width,
      color: Colors.white,
      padding: EdgeInsets.only(
        top: screenSize.height * 0.05, 
        bottom: screenSize.height * 0.02, 
        left: screenSize.width * 0.1, 
        right: screenSize.width * 0.1),
      child: Row(
        children: [
          Expanded(flex: 1,
            child: 
            imageWidget
            ),
          horizontal(6),
          Expanded(
            flex: 2,
            child: textSection,
          ),
          
          horizontal(3),
        ],
      ),
    );
    }

    return Container(
      width: screenSize.width,
      color: Colors.white,
      padding: EdgeInsets.only(
        top: screenSize.height * 0.05, 
        bottom: screenSize.height * 0.02, 
        left: screenSize.width * 0.1, 
        right: screenSize.width * 0.1),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: textSection,
          ),
          
          horizontal(6),
          Expanded(flex: 1,
            child: imageWidget,
            ),
          horizontal(3),
        ],
      ),
    );
  }

  joinFamSection(Size screenSize, FamPageContent content) {
    Widget contentSection = Column(
        children: [
          vertical(4),
          themeText("Join our community today!", size: 28, color: Colors.white, weight: FontWeight.w700,),
          vertical(),
          themeText("Become a member of our vibrant community and unlock exclusive benefits, resources, and connections. Join us today and be part of something special!", 
            size: 18, color: Colors.white, weight: FontWeight.w600, centered: true,),
          vertical(3),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: themeText("Join Now", color: Colors.black, weight: FontWeight.w400 ),
          ),
          vertical(2),
        ],
      );

    //if(content.ownerHeadshotUrl == null || content.ownerHeadshotUrl!.isEmpty) {
      return Container(
            width: screenSize.width *0.8,
            color: const Color.fromARGB(72, 0, 0, 0),
            padding: EdgeInsets.only(top: screenSize.height * 0.05, bottom: screenSize.height * 0.04),
            child: contentSection,
          );
    //}
    

    // Widget imageWidget = 
    // Image.network(
    //   content.ownerHeadshotUrl ?? "",
    //   // You can also add other properties like fit, width, height, etc.
    //   fit: BoxFit.contain,
    //   width: 90,
    // );
    // Container(
    //       decoration: BoxDecoration(
    //         color: Colors.transparent,
    //         image: DecorationImage(
    //           //opacity: 0.35,
    //           fit: BoxFit.cover,
    //           image: NetworkImage(content.ownerHeadshotUrl ?? ""),
    //         ),
    //       ),
    //       height: 90,
    //     );    

    // return Container(
    //         width: screenSize.width,
    //         color: Colors.transparent,
    //         padding: EdgeInsets.only(top: screenSize.height * 0.02),
    //         child: Row(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
                
    //             horizontal(3),
    //             Expanded(
    //               flex: 3,
    //               child: contentSection,
    //             ),
    //             horizontal(3),
    //             Expanded(
    //               flex: 1,
    //               child: imageWidget,
    //             ),
    //             horizontal(9),
    //           ],
    //         ),
    //       );
  }
  
  storeSection(Size screenSize, bool isMobileView, List<StoreItem> storeItems) {
    if(storeItems.isEmpty || famAdmin == null) {
      return Container();
    }

    return Container(
      width: screenSize.width,
      color: Colors.black,
      padding: EdgeInsets.only(
        top: screenSize.height * 0.05, 
        bottom: screenSize.height * 0.02, 
        left: screenSize.width * 0.1, 
        right: screenSize.width * 0.1),
      child: Column(
        children: [
          vertical(2),
          themeText(widget.fam.pageContent!.storeTitle ?? "Guidance sessions", isPrimaryFont: false, weight: FontWeight.bold, size: 32, color: Colors.white ),
          vertical(4),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: storeItems.asMap().entries.map((entry) {
              final int itemIndex = entry.key;
              final StoreItem item = entry.value;

              Widget detailsAndCtaSection = Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisSize: MainAxisSize.min,
                        children: [
                          themeText(item.title, isPrimaryFont: false, weight: FontWeight.bold, size: 28, color: Colors.yellow),
                          vertical(),
                          themeText(item.subtitle, isPrimaryFont: false, weight: FontWeight.bold, size: 22, color: Colors.yellow),
                          vertical(),
                          themeText(item.description, isPrimaryFont: false, size: 14 , color: Colors.yellow),
                          vertical(),
                          themeText("${item.currency} ${item.price} ", isPrimaryFont: false, weight: FontWeight.bold, size: 21, color: Colors.yellow),
                          vertical(2),
                          ElevatedButton(
                            onPressed: () {
                              if(ref.read(currentuser).isSignedOut) {
                                _loginPopupController.show();
                                
                              } else if (itemIndex < _ctaPopupControllersList.length) {
                                _ctaPopupControllersList[itemIndex].show();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            child: 
                              OverlayPortal(
                                controller: _ctaPopupControllersList[itemIndex], 
                                overlayChildBuilder: ((context) => BookSessionView(
                                  onBookingComplete: (item) {
                                    if (itemIndex < _ctaPopupControllersList.length) _ctaPopupControllersList[itemIndex].hide();
                                  }, onCancel: () {
                                    if (itemIndex < _ctaPopupControllersList.length) _ctaPopupControllersList[itemIndex].hide();
                                  }, 
                                  providerUser: famAdmin!, 
                                  providerFamId: widget.fam.id!, 
                                  providerName: widget.fam.name, 
                                  bookingDuration: item.sessionDuration ?? "60", 
                                  title: item.title, 
                                  description: item.description, 
                                  price: item.price, 
                                  currency: item.currency)),
                                child: themeText(item.cta, color: Colors.black, ),
                                  )
                             
                          ),
                        ],
                      );

              Widget itemImage = Image.network(
                item.image,
                fit: BoxFit.cover,
              );

              return Container(
                width: screenSize.width * 0.75,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isMobileView ? Column(mainAxisSize: MainAxisSize.min,
                  children: [
                    itemImage,
                    vertical(2),
                    detailsAndCtaSection,
                  ],
                ) :
                 Row(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: itemImage,),
                    horizontal(2),
                    Expanded(
                      flex: 2,
                      child: detailsAndCtaSection,
                    ),
                  ],
                ),
              );
            }
            ).toList(),
          ),
        ],
      ),
    );
  }

  sendMessageSection(Size screenSize) {
    bool isMobile = screenSize.width <= 800;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if(ref.read(currentuser).isSignedOut) {
            _loginPopupController.show();
             
          } else {
            _chatPopupController.toggle();
          }

           
        },
        child: Stack(
          children: [
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.1,
                  vertical: 40,),
              child: Container(
                
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 32),
                decoration: BoxDecoration(
                  color: Constants.primaryColor(),
                  borderRadius: BorderRadius.circular(21), 
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.chat_bubble, color: Colors.black, size: 20,),
                    horizontal(),
                    themeText("Send me a message", color: Colors.black, size: 20, weight: FontWeight.bold,),
                  ],
                ),
              ),
            ),
            OverlayPortal(
              controller: _chatPopupController, 
              overlayChildBuilder: (context) =>  FamDMScreen(
                receipientUser: famAdmin, 
                onDismiss: () => _chatPopupController.hide()),)
          ]),
      ),);

    // return Container(
    //   width: screenSize.width,
    //   color: Colors.white,
    //   padding: EdgeInsets.only(
    //     top: screenSize.height * 0.05, 
    //     bottom: screenSize.height * 0.02, 
    //     left: screenSize.width * 0.1, 
    //     right: screenSize.width * 0.1),
    //   child: Column(
    //     children: [
    //       themeText("Send a message", isPrimaryFont: false, weight: FontWeight.bold, size: 32, ),
    //       vertical(2),
    //       const TextField(
    //         decoration: InputDecoration(
    //           border: OutlineInputBorder(),
    //           labelText: 'Your Message',
    //         ),
    //         maxLines: 5,
    //       ),
    //       vertical(2),
    //       ElevatedButton(
    //         onPressed: () {},
    //         style: ElevatedButton.styleFrom(
    //           backgroundColor: Colors.amber,
    //           padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    //         ),
    //         child: themeText("Send", color: Colors.black, weight: FontWeight.w400 ),
    //       ),
    //     ],
    //   ),
    // );
  }
  
  footerSection(Size screenSize) {
    bool isMobile = screenSize.width <= 800;

    Widget fzSection = Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/flashzoneR.png',
                //width: 250,
                height: 40,
                fit: BoxFit.contain,
              ),
              vertical(2),
              themeText("This is a community site, a member on communities' platform Flashzone. To see other communities in your area, click here..",  
              color: Colors.white,
              size: 16,
              isPrimaryFont: false,),
            ],
          );

    Widget famSection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              themeText("Surabhi's community", color: Colors.white, size: 20, weight: FontWeight.bold,),
              vertical(),
              themeText("I would like to thank you for visiting my website. Please feel free to get in touch with me regarding your life problems. Become part of my community and grow together with others on the path", color: Colors.white, size: 16, isPrimaryFont: false,),
              vertical(),
              //themeText("Email:surabhimishra@gmail.com", color: Colors.white, size: 16, isPrimaryFont: false,),
              vertical(5),
              InkWell(
                onTap: () async {
                  //Go to link
                  await launchUrlString(widget.fam.pageContent?.ytLink ?? "", mode: LaunchMode.externalApplication);
                },
                child: Image.asset(
                  'assets/yt_logo_fullcolor_white_digital.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
              )
          //vertical(2),
        ],
      );
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: EdgeInsets.only(top: 45, bottom: 45, left: screenSize.width * 0.1, right: screenSize.width * 0.1),
      child: isMobile?
       Column(children: [
        vertical(),
        fzSection,
        vertical(3),
        const Divider(thickness: 3, color: Colors.white,),
        vertical(3),
        famSection
       ],)
       :
       Row(
        children: [
          Expanded(flex: 2, child: fzSection),
          Expanded(flex: 1, child: Container()),
          Expanded(flex: 2, child: famSection),]
    )
    );
  }

  Text themeText(
    String text, {
      Color color = Colors.black, 
      double size = 21, 
      bool isPrimaryFont = true,
      FontWeight weight = FontWeight.normal, 
      bool centered = false,
      bool italic = false}) {
    return Text(
      text,
      textAlign: centered ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontFamily: isPrimaryFont? 'Merriweather': 'PlayfairDisplay',
        fontSize: size,

        fontWeight: weight,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        color: color,
      ),
    );
  }

  Widget vertical([int multiplier = 1]) => SizedBox(height: 5 * multiplier.toDouble(),);
  Widget horizontal([int multiplier = 1]) => SizedBox(width: 5 * multiplier.toDouble(),);
}