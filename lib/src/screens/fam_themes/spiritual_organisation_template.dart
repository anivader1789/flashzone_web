import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/model/fam.dart';
import 'package:flashzone_web/src/model/fam_page_content.dart';
import 'package:flashzone_web/src/model/store.dart';
import 'package:flashzone_web/src/model/local%20use/button_data.dart';
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

class SpiritualOrganisationTemplate extends ConsumerStatefulWidget {
  const SpiritualOrganisationTemplate(this.fam, {super.key});
  final Fam fam;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SpiritualOrganisationTemplateState();
}

class _SpiritualOrganisationTemplateState
    extends ConsumerState<SpiritualOrganisationTemplate>
    with TickerProviderStateMixin {
  final _enrollPopupControllersList = <OverlayPortalController>[];
  final _chatPopupController = OverlayPortalController();
  final _loginPopupController = OverlayPortalController();
  final _galleryImagePopupController = OverlayPortalController();
  FZUser? organizationAdmin;
  String? selectedGalleryImage;
  List<FZUser> communityMembers = [];
  late TabController _heroImageController;
  late List<Widget> pageViews;
  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    
    // Initialize TabController with dynamic length based on hero images
    final content = widget.fam.pageContent;
    final heroImageCount = content is FamPageContent && content.heroImageUrls?.isNotEmpty == true
        ? content.heroImageUrls!.length
        : 3;
    
    _heroImageController = TabController(length: heroImageCount, vsync: this);
    _startHeroImageSlideshow();

    // Initialize popup controllers for courses
    if (content is FamPageContent && content.storeItems != null) {
      for (var _ in content.storeItems!) {
        _enrollPopupControllersList.add(OverlayPortalController());
      }
    }

    loadAdminUser();
    loadCommunityMembers();
  }

  void _startHeroImageSlideshow() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _heroImageController.length > 0) {
        _heroImageController.animateTo(
          (_heroImageController.index + 1) % _heroImageController.length,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startHeroImageSlideshow();
      }
    });
  }

  loadAdminUser() async {
    // Check if admins list is not empty before accessing
    if (widget.fam.admins.isEmpty) {
      return;
    }
    
    organizationAdmin =
        await ref.read(backend).fetchRemoteUser(widget.fam.admins[0]);
    setState(() {});
  }

  loadCommunityMembers() async {
    if (widget.fam.members.isEmpty) {
      // Use dummy members if list is empty
      communityMembers = _getDummyMembers();
    } else {
      // Load actual members
      // final backend = ref.read(backend);
      // final loadedMembers = <FZUser>[];
      
      // for (String memberId in widget.fam.members) {
      //   try {
      //     final user = await backend.fetchRemoteUser(memberId);
      //     if (user != null) {
      //       loadedMembers.add(user);
      //     }
      //   } catch (e) {
      //     // Skip members that can't be loaded
      //   }
      // }
      
      // communityMembers = loadedMembers;
    }
    setState(() {});
  }

  List<FZUser> _getDummyMembers() {
    return [
      FZUser(id: "dummy1", name: "Sarah Johnson", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah"),
      FZUser(id: "dummy2", name: "Michael Chen", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Michael"),
      FZUser(id: "dummy3", name: "Emily Davis", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Emily"),
      FZUser(id: "dummy4", name: "James Wilson", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=James"),
      FZUser(id: "dummy5", name: "Lisa Anderson", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Lisa"),
      FZUser(id: "dummy6", name: "David Martinez", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=David"),
      FZUser(id: "dummy7", name: "Jessica Brown", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Jessica"),
      FZUser(id: "dummy8", name: "Robert Taylor", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Robert"),
      FZUser(id: "dummy9", name: "Amanda Garcia", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Amanda"),
      FZUser(id: "dummy10", name: "Christopher Lee", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Christopher"),
    ];
  }

  @override
  void dispose() {
    _heroImageController.dispose();
    // for (var controller in _enrollPopupControllersList) {
    //   controller.dispose();
    // }
    // _chatPopupController.dispose();
    // _loginPopupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.fam.pageContent;
    if (content == null || content is! FamPageContent) {
      return Center(
        child: themeText("Content not available",
            color: Colors.black, size: 20),
      );
    }

    Size screenSize = MediaQuery.of(context).size;
    bool isMobile = screenSize.width < 800;

    pageViews = [
      heroSectionWithSlideshow(screenSize, content, isMobile),
      aboutSection(screenSize, isMobile, content),
      missionSection(screenSize, isMobile, content),
      courseCatalogSection(screenSize, isMobile, content),
      gallerySection(screenSize, isMobile, content),
      communitySection(screenSize, isMobile),
      contactSection(screenSize),
      footerSection(screenSize, content),
    ];

    return Stack(
      children: [
        ScrollablePositionedList.builder(
          itemCount: pageViews.length,
          itemScrollController: itemScrollController,
          itemBuilder: (context, index) {
            return pageViews[index];
          },
        ),
        // Top navigation bar
        ThemedNavBar(
          titleWidget: themeText(
            widget.fam.name,
            color: Color(int.parse('0xff${widget.fam.primaryColor}')),
            size: 24,
            weight: FontWeight.bold,
            italic: true,
          ),
          buttonsDataList: [
            ButtonData(
              label: "Our Mission",
              onPressed: () {
                itemScrollController.scrollTo(
                  index: 2,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                );
              },
              icon: Icons.flag,
            ),
            ButtonData(
              label: "Our Courses",
              onPressed: () {
                itemScrollController.scrollTo(
                  index: 5,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                );
              },
              icon: Icons.school,
            ),
            ButtonData(
              label: "Gallery",
              onPressed: () {
                itemScrollController.scrollTo(
                  index: 4,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                );
              },
              icon: Icons.collections,
            ),
            ButtonData(
              label: "Community",
              onPressed: () {
                itemScrollController.scrollTo(
                  index: 5,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                );
              },
              icon: Icons.people,
            ),
            ButtonData(
              label: "Contact Us",
              onPressed: () {
                itemScrollController.scrollTo(
                  index: 6,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                );
              },
              icon: Icons.chat,
            ),
          ],
          user: ref.read(currentuser),
          famAdmin: organizationAdmin,
        ),
        OverlayPortal(
          controller: _loginPopupController,
          overlayChildBuilder: (context) => AccountScreen(
            onDismiss: () => _loginPopupController.hide(),
            mobileSize: false,
          ),
          child: Container(),
        ),
        OverlayPortal(
          controller: _galleryImagePopupController,
          overlayChildBuilder: (context) => _buildGalleryImagePopup(),
          child: Container(),
        )
      ],
    );
  }

  Widget heroSectionWithSlideshow(
      Size screenSize, FamPageContent content, bool isMobileView) {
    final imageUrls = content.heroImageUrls?.isNotEmpty == true
        ? content.heroImageUrls!
        : [
            'https://via.placeholder.com/1200x600?text=Spiritual+Journey',
            'https://via.placeholder.com/1200x600?text=Inner+Peace',
            'https://via.placeholder.com/1200x600?text=Growth'
          ];

    return SizedBox(
      height: screenSize.height,
      child: Stack(
        children: [
          TabBarView(
            controller: _heroImageController,
            physics: const NeverScrollableScrollPhysics(),
            children: imageUrls
                .map((url) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(url),
                        ),
                      ),
                    ))
                .toList(),
          ),
          // Dark overlay
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                themeText(
                  content.heroHeading ?? widget.fam.name,
                  size: isMobileView ? 32 : 56,
                  color: Colors.white,
                  weight: FontWeight.w700,
                  centered: true,
                ),
                const SizedBox(height: 20),
                themeText(
                  content.heroSubheading ?? "Welcome to our spiritual community",
                  italic: true,
                  color: Colors.white70,
                  size: isMobileView ? 16 : 24,
                  centered: true,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    itemScrollController.scrollTo(
                      index: 2,
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(int.parse('0xff${widget.fam.primaryColor}')),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: themeText(
                    "Check out Community",
                    color: Colors.black,
                    weight: FontWeight.w600,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          // Slide indicators
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  imageUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _heroImageController.index == index
                          ? Color(int.parse('0xff${widget.fam.primaryColor}'))
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget aboutSection(
      Size screenSize, bool isMobileView, FamPageContent content) {
    if (content.aboutHeading == null && content.aboutDescription == null) {
      return Container();
    }

    Widget imageWidget = content.aboutImageUrl != null
        ? Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(content.aboutImageUrl ?? ""),
              ),
            ),
            height: 400,
          )
        : Container();

    Widget textSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        themeText(
          content.aboutHeading ?? "About Us",
          isPrimaryFont: false,
          weight: FontWeight.bold,
          size: 36,
          color: Colors.black,
        ),
        const SizedBox(height: 20),
        themeText(
          content.aboutDescription ?? "",
          isPrimaryFont: false,
          size: 16,
          color: Colors.black87,
        ),
        // if (content.organizationMissionStatement != null) ...[
        //   const SizedBox(height: 30),
        //   themeText(
        //     "Our Mission",
        //     isPrimaryFont: false,
        //     weight: FontWeight.bold,
        //     size: 24,
        //     color: Colors.black,
        //   ),
        //   const SizedBox(height: 10),
        //   themeText(
        //     content.organizationMissionStatement ?? "",
        //     isPrimaryFont: false,
        //     size: 16,
        //     color: Colors.black87,
        //   ),
        // ]
      ],
    );

    if (content.aboutImageUrl == null) {
      return Container(
        width: screenSize.width,
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.05,
          horizontal: screenSize.width * 0.1,
        ),
        child: textSection,
      );
    }

    if (isMobileView) {
      return Container(
        width: screenSize.width,
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: screenSize.height * 0.05,
          horizontal: screenSize.width * 0.08,
        ),
        child: Column(
          children: [
            imageWidget,
            const SizedBox(height: 30),
            textSection,
          ],
        ),
      );
    }

    return Container(
      width: screenSize.width,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.05,
        horizontal: screenSize.width * 0.1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: imageWidget,
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 1,
            child: textSection,
          ),
        ],
      ),
    );
  }

  Widget missionSection(Size screenSize, bool isMobileView, FamPageContent content) {
    if (content.organizationMissionStatement == null || content.organizationMissionStatement!.isEmpty) {
      return Container();
    }

    Widget textSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        themeText(
          "Our Mission",
          isPrimaryFont: false,
          weight: FontWeight.bold,
          size: 36,
          color: Colors.white,
        ),
        const SizedBox(height: 20),
        themeText(
          content.organizationMissionStatement ?? "",
          isPrimaryFont: false,
          size: 16,
          color: Colors.white70,
        ),
      ],
    );

    return Container(
      width: screenSize.width,
      color: Colors.black87,
      padding: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.05,
        horizontal: screenSize.width * 0.1,
      ),
      child: isMobileView
          ? Column(
              children: [
                textSection,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: textSection,
                ),
              ],
            ),
    );
  }

  Widget courseCatalogSection(Size screenSize, bool isMobileView,
      FamPageContent content) {
    if (content.storeItems == null || content.storeItems!.isEmpty) {
      return Container();
    }

    return Container(
      width: screenSize.width,
      color: const Color(0xFFF5F5F5),
      padding: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.05,
        horizontal: screenSize.width * 0.1,
      ),
      child: Column(
        children: [
          themeText(
            content.storeTitle,
            isPrimaryFont: false,
            weight: FontWeight.bold,
            size: 36,
            color: Colors.black,
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: content.storeItems!.asMap().entries.map((entry) {
              final int itemIndex = entry.key;
              final StoreItem item = entry.value;

              return SizedBox(
                width: isMobileView
                    ? screenSize.width * 0.85
                    : screenSize.width * 0.4,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(item.image),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            themeText(
                              item.title,
                              isPrimaryFont: false,
                              weight: FontWeight.bold,
                              size: 22,
                              color: Colors.black,
                            ),
                            const SizedBox(height: 10),
                            themeText(
                              item.subtitle,
                              isPrimaryFont: false,
                              weight: FontWeight.w600,
                              size: 16,
                              color: Color(int.parse('0xff${widget.fam.primaryColor}')),
                            ),
                            const SizedBox(height: 12),
                            themeText(
                              item.description,
                              isPrimaryFont: false,
                              size: 14,
                              color: Colors.black87,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                themeText(
                                  "${item.currency} ${item.price}",
                                  isPrimaryFont: false,
                                  weight: FontWeight.bold,
                                  size: 20,
                                  color: Color(int.parse('0xff${widget.fam.primaryColor}')),
                                ),
                                if (organizationAdmin != null)
                                  ElevatedButton(
                                    onPressed: () {
                                      if (ref.read(currentuser).isSignedOut) {
                                        _loginPopupController.show();
                                      } else if (itemIndex <
                                          _enrollPopupControllersList.length) {
                                        _enrollPopupControllersList[itemIndex]
                                            .show();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(int.parse('0xff${widget.fam.primaryColor}')),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: themeText(
                                      item.cta,
                                      color: Colors.black,
                                      weight: FontWeight.w600,
                                    ),
                                  )
                                else
                                  ElevatedButton(
                                    onPressed: null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: themeText(
                                      item.cta,
                                      color: Colors.white,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                            if (organizationAdmin != null)
                              OverlayPortal(
                                controller: _enrollPopupControllersList[
                                    itemIndex % _enrollPopupControllersList.length],
                                overlayChildBuilder: (context) =>
                                    BookSessionView(
                                  onBookingComplete: (bookingItem) {
                                    if (itemIndex <
                                        _enrollPopupControllersList.length) {
                                      _enrollPopupControllersList[itemIndex]
                                          .hide();
                                    }
                                  },
                                  onCancel: () {
                                    if (itemIndex <
                                        _enrollPopupControllersList.length) {
                                      _enrollPopupControllersList[itemIndex]
                                          .hide();
                                    }
                                  },
                                  providerUser: organizationAdmin!,
                                  providerFamId: widget.fam.id!,
                                  providerName: widget.fam.name,
                                  bookingDuration: item.sessionDuration ?? "60",
                                  title: item.title,
                                  description: item.description,
                                  price: item.price,
                                  currency: item.currency,
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget gallerySection(Size screenSize, bool isMobileView, FamPageContent content) {
    if (content.galleryImageUrls == null || content.galleryImageUrls!.isEmpty) {
      return Container();
    }

    return Container(
      width: screenSize.width,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.05,
        horizontal: screenSize.width * 0.1,
      ),
      child: Column(
        children: [
          themeText(
            content.galleryHeading ?? "Gallery",
            isPrimaryFont: false,
            weight: FontWeight.bold,
            size: 36,
            color: Colors.black,
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobileView ? 2 : 4,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: content.galleryImageUrls!.length,
            itemBuilder: (context, index) {
              final imageUrl = content.galleryImageUrls![index];
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    selectedGalleryImage = imageUrl;
                    _galleryImagePopupController.show();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(imageUrl),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget communitySection(Size screenSize, bool isMobileView) {
    return Container(
      width: screenSize.width,
      color: const Color(0xFFF5F5F5),
      padding: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.05,
        horizontal: screenSize.width * 0.1,
      ),
      child: Column(
        children: [
          themeText(
            "Join Our Community",
            isPrimaryFont: false,
            weight: FontWeight.bold,
            size: 36,
            color: Colors.black,
          ),
          const SizedBox(height: 40),
          // Horizontal scrollable list of members
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: communityMembers.length,
              itemBuilder: (context, index) {
                final member = communityMembers[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(int.parse('0xff${widget.fam.primaryColor}')),
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            member.avatar ?? 'https://api.dicebear.com/7.x/avataaars/svg?seed=default',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.person),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 100,
                        child: Text(
                          member.name ?? 'Member',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 40),
          // Join community button
          ElevatedButton(
            onPressed: () {
              // Handle join community action
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your interest!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(int.parse('0xff${widget.fam.primaryColor}')),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: themeText(
              "Join Community",
              color: Colors.black,
              weight: FontWeight.w600,
              size: 16,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget contactSection(Size screenSize) {
    bool isMobile = screenSize.width <= 800;

    return Container(
      width: screenSize.width,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.05,
        horizontal: screenSize.width * 0.1,
      ),
      child: Column(
        children: [
          themeText(
            "Contact Us",
            isPrimaryFont: false,
            weight: FontWeight.bold,
            size: 36,
            color: Colors.black,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: screenSize.width * 0.7,
            child: themeText(
              "Have any questions? Press the button below to send a direct message to our community admins. We'll get back to you within 1 week.",
              isPrimaryFont: false,
              size: 16,
              color: Colors.black87,
              centered: true,
            ),
          ),
          const SizedBox(height: 40),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if (ref.read(currentuser).isSignedOut) {
                  _loginPopupController.show();
                } else {
                  _chatPopupController.toggle();
                }
              },
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(int.parse('0xff${widget.fam.primaryColor}')),
                          Color(int.parse('0xff${widget.fam.primaryColor}'))
                              .withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(CupertinoIcons.chat_bubble,
                            color: Colors.black, size: 18),
                        const SizedBox(width: 12),
                        themeText(
                          "Send Message",
                          color: Colors.black,
                          size: 16,
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                  OverlayPortal(
                    controller: _chatPopupController,
                    overlayChildBuilder: (context) => FamDMScreen(
                      receipientUser: organizationAdmin,
                      onDismiss: () => _chatPopupController.hide(),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget footerSection(Size screenSize, FamPageContent content) {
    bool isMobile = screenSize.width <= 800;

    Widget flashzoneSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          'assets/flashzoneR.png',
          height: 40,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        themeText(
          "This is a community site, a member on communities' platform Flashzone. To see other communities in your area, visit Flashzone.",
          color: Colors.white,
          size: 14,
          isPrimaryFont: false,
        ),
      ],
    );

    Widget organizationSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        themeText(
          widget.fam.name,
          color: Colors.white,
          size: 22,
          weight: FontWeight.bold,
        ),
        const SizedBox(height: 16),
        themeText(
          content.organizationDescription ?? "Welcome to our spiritual community",
          color: Colors.white,
          size: 14,
          isPrimaryFont: false,
        ),
        const SizedBox(height: 24),
        // Social Media Links
        Wrap(
          spacing: 16,
          children: [
            if (content.ytLink != null)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    await launchUrlString(
                      content.ytLink!,
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: Image.asset(
                    'assets/yt_logo_fullcolor_white_digital.png',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            if (content.instagramUrl != null)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    await launchUrlString(
                      content.instagramUrl!,
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            if (content.facebookUrl != null)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    await launchUrlString(
                      content.facebookUrl!,
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: const Icon(
                    Icons.people,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            if (content.linkedinUrl != null)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    await launchUrlString(
                      content.linkedinUrl!,
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: const Icon(
                    Icons.business,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
          ],
        ),
      ],
    );

    return Container(
      width: double.infinity,
      color: Colors.black87,
      padding: EdgeInsets.symmetric(
        vertical: 60,
        horizontal: screenSize.width * 0.1,
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                flashzoneSection,
                const SizedBox(height: 40),
                const Divider(
                  thickness: 2,
                  color: Colors.white24,
                ),
                const SizedBox(height: 40),
                organizationSection,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: flashzoneSection,
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 2,
                  child: organizationSection,
                ),
              ],
            ),
    );
  }

  Text themeText(
    String text, {
    Color color = Colors.black,
    double size = 16,
    bool isPrimaryFont = true,
    FontWeight weight = FontWeight.normal,
    bool centered = false,
    bool italic = false,
  }) {
    return Text(
      text,
      textAlign: centered ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontFamily: isPrimaryFont ? 'Merriweather' : 'PlayfairDisplay',
        fontSize: size,
        fontWeight: weight,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        color: color,
      ),
    );
  }

  Widget _buildGalleryImagePopup() {
    return GestureDetector(
      onTap: () => _galleryImagePopupController.hide(),
      child: Container(
        color: Colors.black.withOpacity(0.9),
        child: Stack(
          children: [
            Center(
              child: Image.network(
                selectedGalleryImage ?? '',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => _galleryImagePopupController.hide(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
