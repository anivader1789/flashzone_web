import 'package:flashzone_web/src/model/store.dart';

class FamPageContent {
  final int themeVersion;
  
  final String? heroImageUrl;
  final String? heroHeading;
  final String? heroSubheading;
  final String? ownerHeadshotUrl;
  final List<MidSectionContent> midSections;
  final List<StoreItem>? storeItems;

  final String? galleryHeading;
  final List<String>? galleryImageUrls;


  FamPageContent({
    required this.heroImageUrl,
    required this.heroHeading,
    this.themeVersion = 1,
    this.midSections = const [],
    this.storeItems = const [],
    this.ownerHeadshotUrl,
    this.galleryHeading,
    this.galleryImageUrls = const [],
    this.heroSubheading,
  });

  static FamPageContent fromMap(Map<String, dynamic> data) {
    return FamPageContent(
      themeVersion: data['theme_version'] as int? ?? 1,
      heroImageUrl: data['hero_image_url'] as String?,
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
      storeItems: (data['store'] as List<dynamic>?)
          ?.map((e) => StoreItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      galleryHeading: data['gallery_heading'] as String?,
      galleryImageUrls: (data['gallery_image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
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

