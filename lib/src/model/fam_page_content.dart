import 'package:flashzone_web/src/model/store.dart';

class FamPageContent {
  final int themeVersion;
  
  // Hero section fields
  final String? heroImageUrl;
  final List<String>? heroImageUrls; // For slideshow (spiritual org template)
  final String? heroHeading;
  final String? heroSubheading;
  
  // Social media & links
  final String? ytLink;
  final String? instagramUrl;
  final String? facebookUrl;
  final String? twitterUrl;
  final String? linkedinUrl;
  final String? websiteUrl;
  
  // About section fields
  final String? aboutHeading;
  final String? aboutDescription;
  final String? aboutImageUrl;
  
  // Organization fields
  final String? organizationDescription;
  final String? organizationMissionStatement;
  
  // Existing fields
  final String? ownerHeadshotUrl;
  final List<MidSectionContent> midSections;
  final List<StoreItem>? storeItems;
  final String storeTitle;
  final String? galleryHeading;
  final List<String>? galleryImageUrls;


  FamPageContent({
    required this.heroImageUrl,
    required this.heroHeading,
    required this.ytLink,
    this.themeVersion = 1,
    this.midSections = const [],
    this.storeItems = const [],
    this.ownerHeadshotUrl,
    this.galleryHeading,
    this.galleryImageUrls = const [],
    this.storeTitle = "Store",
    this.heroSubheading,
    this.heroImageUrls,
    this.instagramUrl,
    this.facebookUrl,
    this.twitterUrl,
    this.linkedinUrl,
    this.websiteUrl,
    this.aboutHeading,
    this.aboutDescription,
    this.aboutImageUrl,
    this.organizationDescription,
    this.organizationMissionStatement,
  });

  static FamPageContent fromMap(Map<String, dynamic> data) {
    return FamPageContent(
      themeVersion: data['theme_version'] as int? ?? 1,
      heroImageUrl: data['hero_image_url'] as String?,
      ytLink: data['yt_link'] as String?,
      heroHeading: data['hero_heading'] as String?,
      heroSubheading: data['hero_subheading'] as String?,
      ownerHeadshotUrl: data['owner_headshot_url'] as String?,
      midSections: (data['mid_sections'] as List<dynamic>?)
          ?.map((e) => MidSectionContent(
                imageUrl: e['image_url'] as String?,
                heading: e['heading'] as String,
                description: e['description'] as String,
              ))
          .toList() ??
          [],
      storeTitle: data['store_title'] as String? ?? "Store",
      storeItems: (data['store'] as List<dynamic>?)
          ?.map((e) => StoreItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      galleryHeading: data['gallery_heading'] as String?,
      galleryImageUrls: (data['gallery_image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      // New fields for spiritual org template
      heroImageUrls: (data['hero_image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      instagramUrl: data['instagram_url'] as String?,
      facebookUrl: data['facebook_url'] as String?,
      twitterUrl: data['twitter_url'] as String?,
      linkedinUrl: data['linkedin_url'] as String?,
      websiteUrl: data['website_url'] as String?,
      aboutHeading: data['about_heading'] as String?,
      aboutDescription: data['about_description'] as String?,
      aboutImageUrl: data['about_image_url'] as String?,
      organizationDescription: data['organization_description'] as String?,
      organizationMissionStatement: data['organization_mission_statement'] as String?,
    );
  }

}

class MidSectionContent {
    final String? imageUrl;
    final String heading;
    final String description;
    const MidSectionContent({
        this.imageUrl,
        required this.heading,
        required this.description,
    });
}

