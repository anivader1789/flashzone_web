import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/fam.dart';
import 'package:flashzone_web/src/model/fam_page_content.dart';
import 'package:flashzone_web/src/model/store.dart';
import 'package:flashzone_web/src/screens/subviews/themed_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DarkSimpleThemePage extends ConsumerStatefulWidget {
  const DarkSimpleThemePage(this.fam, {super.key});
  final Fam fam; 

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DarkSimpleThemePageState();
}

class _DarkSimpleThemePageState extends ConsumerState<DarkSimpleThemePage> {

  @override
  Widget build(BuildContext context) {
    if(widget.fam.pageContent == null) {
      return Container();
    }

    FamPageContent content = widget.fam.pageContent!;
    Size screenSize = MediaQuery.of(context).size;

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
        SingleChildScrollView(
          child: Column(
            children: [
              heroSection(screenSize, content), 
              //vertical(2),
              //const FZText(text: "Helloo", style: FZTextStyle.headline,),
              midSection(screenSize, content.midSections[0]),
              //vertical(),            
              joinFamSection(screenSize, content),
              //vertical(),
              midSection(screenSize, content.midSections[1], true),
              //vertical(),
              if(content.storeItems != null && content.storeItems!.isNotEmpty)
                storeSection(screenSize, content.storeItems!),

              //vertical(),
              sendMessageSection(screenSize),
              //...content.midSections.map((section) => midSection(screenSize, section)).toList(),
              //vertical(9),
              footerSection(screenSize),
            ],
        ),
      ),
      //Top navigation bar
      ThemedNavBar(
        titleWidget: themeText(widget.fam.name, color: Colors.yellow, size: 24, weight: FontWeight.bold, italic: true), 
        actions: [
          TextButton(onPressed: () {}, child: themeText("Book a session", color: Colors.white,)),
          TextButton(onPressed: () {}, child: themeText("Contact", color: Colors.white,)),
        ], 
        userAvatar: ref.read(currentuser).avatar)
      // Container(
      //   width: screenSize.width,
      //   height: 60,
      //   color: Colors.black.withOpacity(0.7),
      //   child: Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
      //     child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         themeText(widget.fam.name, color: Colors.yellow, size: 24, weight: FontWeight.bold, italic: true),
      //         Row(
      //           children: [
      //             //TextButton(onPressed: () {}, child: themeText("About Surabhi", color: Colors.white)),
      //             //horizontal(4),
      //             TextButton(onPressed: () {}, child: themeText("Book a session", color: Colors.white,)),
      //             horizontal(4),
      //             TextButton(onPressed: () {}, child: themeText("Contact", color: Colors.white,)),
      //             horizontal(4),
      //             const Icon(CupertinoIcons.cart, color: Colors.white,),
      //             horizontal(4),
      //             CircleAvatar(
      //               foregroundImage: Helpers.loadImageProvider(ref.read(currentuser).avatar), radius: 18,
      //               ),
      //           ],
      //         )
      //       ],
      //     ),
      //   ),
      // ),
      ],
      

    );
  }

  heroSection(Size screenSize, FamPageContent content) {
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
                      themeText(content.heroHeading ?? "", size: 44, color: Colors.white),
                      const Divider(color: Colors.white70, thickness: 3.5,),
                      vertical(),
                      themeText(content.heroSubheading ?? "", italic: true, color: Color.fromARGB(255, 215, 180, 53), size: 24,),
                    ],
                  ),
                ),
              ),
            ),]
    );
  }

  midSection(Size screenSize, MidSectionContent section,[ bool imageLeftAligned = false]) {
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
  
  storeSection(Size screenSize, List<StoreItem> storeItems) {
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
          themeText("Guidance sessions with Surabhi", isPrimaryFont: false, weight: FontWeight.bold, size: 32, ),
          vertical(2),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: storeItems.map((item) => 
              Container(
                width: screenSize.width * 0.75,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Image.network(
                      item.image,
                      fit: BoxFit.cover,
                    ),),
                    horizontal(2),
                    Expanded(
                      flex: 2,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
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
                              
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            child: themeText("Book Now", color: Colors.black, ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ).toList(),
          ),
        ],
      ),
    );
  }

  sendMessageSection(Size screenSize) {
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
          themeText("Send a message", isPrimaryFont: false, weight: FontWeight.bold, size: 32, ),
          vertical(2),
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Your Message',
            ),
            maxLines: 5,
          ),
          vertical(2),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: themeText("Send", color: Colors.black, weight: FontWeight.w400 ),
          ),
        ],
      ),
    );
  }
  
  footerSection(Size screenSize) {
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
                onTap: () {},
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
      child: Row(
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