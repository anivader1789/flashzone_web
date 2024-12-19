import 'package:flashzone_web/src/model/location.dart';
import 'package:flashzone_web/src/model/user.dart';

class Flash {
  String? imageUrl;
  String? id;
  String content;
  FZUser user;
  DateTime postDate;
  FZLocation? postLocation;
  Flash({this.id, required this.content, required this.user, required this.postDate, this.imageUrl, this.postLocation});

  static String collectionName = "flash";
  static String imageKey = "img", contentKey = "content", userIdKey = "userId", 
  userhandleKey = "userhandle", nameKey = "username", userPicKey = "userPic", 
  dateKey = "date", addressKey = "address", geoKey = "geo";

  static Flash fromDocSnapshot(String id, Map<String, dynamic>? data) {
    if(data == null) return dummyFlash(id);

    return Flash(
      id: id,
      content: data[contentKey],
      imageUrl: data[imageKey],
      user: FZUser(id: data[userIdKey], name: data[nameKey], username: data[userhandleKey], avatar: data[userPicKey]),
      postDate: DateTime.parse(data[dateKey]) ,
      postLocation: FZLocation(address: data[addressKey], geoData: data[geoKey])
      );
  }

  Map<String, dynamic> creationObj() {
    return {
      contentKey: content,
      imageKey: imageUrl,
      nameKey: user.name,
      userIdKey: user.id,
      userhandleKey: user.username,
      userPicKey: user.avatar,
      dateKey: postDate.toString(),
      addressKey: postLocation?.address,
      geoKey: postLocation?.geoData
    };
  }

  static Flash dummyFlash(String id) {
    return Flash(content: "Content failed to load..", user: FZUser(id: "1234", name: "Error", username: "error"), postDate: DateTime.fromMicrosecondsSinceEpoch(0));
  }
}