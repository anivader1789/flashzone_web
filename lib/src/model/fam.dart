import 'package:flashzone_web/src/model/fam_page_content.dart';
import 'package:flashzone_web/src/model/location.dart';

class Fam {
  String? id;
  String name;
  String description;
  String? imageUrl;
  DateTime createdAt;
  List<String> admins;
  List<String> members;
  List<String> adminRequests;
  List<String> memberRequests;
  FamPageContent? pageContent;
  String community; // New field

  FZLocation? location;

  Fam({
    this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.createdAt,
    this.location,
    required this.admins,
    required this.members,
    required this.adminRequests,
    required this.memberRequests,
    this.pageContent,
    this.community = "Spirituality", // Default value
  });

  static const String collectionName = 'fams', 
    nameKey = 'name', descriptionKey = 'description',
    imageUrlKey = 'image_url', createdAtKey = 'created_at',
    communityKey = 'community',
    adminsKey = 'admins',
    membersKey = 'members',
    locationKey = 'location', addressKey = "address", geoKey = "geo",
    adminRequestsKey = 'admin_requests',
    memberRequestsKey = 'member_requests',
    pageContentKey = 'page_content';

  static Fam fromDocSnapshot(String id, Map<String, dynamic>? data) {
    if (data == null) {
      return Fam(
        name: "Error",
        description: "Error",
        imageUrl: null,
        createdAt: DateTime.now(),
        admins: [], 
        members: [], 
        adminRequests: [], 
        memberRequests: [],
        community: "Spirituality", // Default value
      );
    } 

    return Fam(
      id: id,
      name: data[nameKey] as String,
      description: data[descriptionKey] as String,
      imageUrl: data[imageUrlKey] as String?,
      createdAt: DateTime.parse(data[createdAtKey]),
      location: FZLocation(address: data[addressKey], geoData: data[geoKey]),
      admins: List<String>.from(data[adminsKey] ?? []), 
      members: List<String>.from(data[membersKey] ?? []), 
      adminRequests: List<String>.from(data[adminRequestsKey] ?? []),
      memberRequests: List<String>.from(data[memberRequestsKey] ?? []),
      pageContent: FamPageContent.fromMap(
        Map<String, dynamic>.from(data[pageContentKey] ?? {}),
      ),
      community: data[communityKey] ?? "Spirituality", // Read from data or default
    );
  }

  Map<String, dynamic> creationObj() {
    return {
      nameKey: name,
      descriptionKey: description,
      imageUrlKey: imageUrl,
      createdAtKey: createdAt.toString(),
      adminsKey: admins,
      membersKey: members,
      addressKey: location?.address,
      geoKey: location?.geoData,
      adminRequestsKey: adminRequests,
      memberRequestsKey: memberRequests,
      communityKey: community, // New field
    };
  }

  Map<String, dynamic> updateObj() {
    return {
      nameKey: name,
      descriptionKey: description,
      imageUrlKey: imageUrl,
      membersKey: members,
      adminRequestsKey: adminRequests, 
      memberRequestsKey: memberRequests, 
      communityKey: community, // New field
    };
  }

  void requestMembership(String userId) {
    if (!admins.contains(userId) && !members.contains(userId)) {
      memberRequests.add(userId);
    }
  }

  void requestAdminStatus(String userId) {
    if (!admins.contains(userId)) {
      adminRequests.add(userId);
    }
  }

  void acceptMembership(String userId) {
    if (memberRequests.contains(userId)) {
      memberRequests.remove(userId);
      members.add(userId);
    }
  }

  void acceptAdminStatus(String userId) {
    if (adminRequests.contains(userId)) {
      adminRequests.remove(userId);
      admins.add(userId);
    }
  }

  void rejectMembership(String userId) {
    if (memberRequests.contains(userId)) {
      memberRequests.remove(userId);
    }
  }

  void rejectAdminStatus(String userId) {
    if (adminRequests.contains(userId)) {
      adminRequests.remove(userId);
    }
  }

  void removeMember(String userId) {
    if (members.contains(userId)) {
      members.remove(userId);
    }
  }

  void removeAdmin(String userId) {
    if (admins.contains(userId)) {
      admins.remove(userId);
    }
  }



  factory Fam.fromJson(Map<String, dynamic> json) {
    return Fam(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      admins: List<String>.from(json['admins'] ?? []), 
      members: List<String>.from(json['members'] ?? []), 
      adminRequests: List<String>.from(json['admin_requests'] ?? []), 
      memberRequests: List<String>.from(json['member_requests'] ?? []), 
      pageContent: json['page_content'] != null
          ? FamPageContent.fromMap(
              Map<String, dynamic>.from(json['page_content']))
          : null,
      community: json[communityKey] ?? "Spirituality", // New field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'created_at': createdAt.toString(),
      'admins': admins, 
      'members': members, 
      'admin_requests': adminRequests,
      'member_requests': memberRequests,
      'community': community, // New field
    };
  }
}