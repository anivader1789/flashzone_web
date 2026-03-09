import 'package:flashzone_web/src/model/course.dart';

class SocialMediaLinks {
  final String? youtubeUrl;
  final String? instagramUrl;
  final String? facebookUrl;
  final String? twitterUrl;
  final String? linkedinUrl;
  final String? websiteUrl;

  SocialMediaLinks({
    this.youtubeUrl,
    this.instagramUrl,
    this.facebookUrl,
    this.twitterUrl,
    this.linkedinUrl,
    this.websiteUrl,
  });

  static SocialMediaLinks fromMap(Map<String, dynamic> data) {
    return SocialMediaLinks(
      youtubeUrl: data['youtube_url'] as String?,
      instagramUrl: data['instagram_url'] as String?,
      facebookUrl: data['facebook_url'] as String?,
      twitterUrl: data['twitter_url'] as String?,
      linkedinUrl: data['linkedin_url'] as String?,
      websiteUrl: data['website_url'] as String?,
    );
  }
}

class SpiritualPageContent {
  final int themeVersion;
  final List<String> heroImageUrls;
  final String? heroHeading;
  final String? heroSubheading;
  final String? aboutHeading;
  final String? aboutDescription;
  final String? aboutImageUrl;
  final List<Course>? courses;
  final String courseTitle;
  final String? organizationDescription;
  final String? organizationMissionStatement;
  final SocialMediaLinks socialMediaLinks;

  SpiritualPageContent({
    required this.heroImageUrls,
    this.themeVersion = 1,
    this.heroHeading,
    this.heroSubheading,
    this.aboutHeading,
    this.aboutDescription,
    this.aboutImageUrl,
    this.courses,
    this.courseTitle = "Our Courses",
    this.organizationDescription,
    this.organizationMissionStatement,
    required this.socialMediaLinks,
  });

  static SpiritualPageContent fromMap(Map<String, dynamic> data) {
    return SpiritualPageContent(
      themeVersion: data['theme_version'] as int? ?? 1,
      heroImageUrls: (data['hero_image_urls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      heroHeading: data['hero_heading'] as String?,
      heroSubheading: data['hero_subheading'] as String?,
      aboutHeading: data['about_heading'] as String?,
      aboutDescription: data['about_description'] as String?,
      aboutImageUrl: data['about_image_url'] as String?,
      courseTitle: data['course_title'] as String? ?? "Our Courses",
      courses: (data['courses'] as List<dynamic>?)
          ?.map((e) => Course.fromMap(e as Map<String, dynamic>))
          .toList(),
      organizationDescription: data['organization_description'] as String?,
      organizationMissionStatement: data['organization_mission_statement'] as String?,
      socialMediaLinks: SocialMediaLinks.fromMap(
        data['social_media_links'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
