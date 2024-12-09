import 'package:flashzone_web/src/model/location.dart';
import 'package:flashzone_web/src/model/user.dart';

class Flash {
  String? imageUrl;
  String content;
  FZUser user;
  DateTime postDate;
  String? postAddress;
  FZLocation? postLocation;
  Flash({required this.content, required this.user, required this.postDate, this.postAddress, this.imageUrl, this.postLocation});

  static String collectionName = "flash";
}