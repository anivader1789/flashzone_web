import 'package:flashzone_web/src/model/location.dart';
import 'package:flashzone_web/src/model/user.dart';

class Flash {
  String? imageUrl;
  String? id;
  String content;
  FZUser user;
  DateTime postDate;
  FZLocation? postLocation;
  int likes, comments;
  bool deleted;

  Flash({this.id, 
  required this.content, 
  required this.user, 
  required this.postDate, 
  this.imageUrl, 
  this.postLocation,
  this.likes = 0,
  this.comments = 0,
  this.deleted = false}
  );

  static String collectionName = "flash";
  static String imageKey = "img", contentKey = "content", userIdKey = "userId", 
  userhandleKey = "userhandle", nameKey = "username", userPicKey = "userPic", 
  dateKey = "date", addressKey = "address", geoKey = "geo",
  commentsKey = "comments", likesKey = "likes";

  static Flash fromDocSnapshot(String id, Map<String, dynamic>? data) {
    if(data == null) return dummyFlash(id);

    return Flash(
      id: id,
      content: data[contentKey],
      imageUrl: data[imageKey],
      user: FZUser(id: data[userIdKey], name: data[nameKey], username: data[userhandleKey], avatar: data[userPicKey]),
      postDate: DateTime.parse(data[dateKey]) ,
      postLocation: FZLocation(address: data[addressKey], geoData: data[geoKey]),
      likes: data[likesKey] ?? 0,
      comments: data[commentsKey] ?? 0,
      );
  }

  Map<String, dynamic> creationObj() {
    return {
      likesKey: likes,
      commentsKey: comments,
    };
  }

  Map<String, dynamic> updateObj() {
    return {
      contentKey: content,
      imageKey: imageUrl,
      nameKey: user.name,
      userIdKey: user.id,
      userhandleKey: user.username,
      userPicKey: user.avatar,
      dateKey: postDate.toString(),
      addressKey: postLocation?.address,
      geoKey: postLocation?.geoData,
      likesKey: likes,
      commentsKey: comments,

    };
  }

  static Flash dummyFlash(String id) {
    return Flash(content: "Content failed to load..", user: FZUser(id: "1234", name: "Error", username: "error"), postDate: DateTime.fromMicrosecondsSinceEpoch(0));
  }


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is Flash && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

