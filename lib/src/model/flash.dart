import 'package:flashzone_web/src/model/user.dart';

class Flash {
  String? imageUrl;
  String content;
  FZUser user;
  DateTime postDate;
  String? postAddress;
  Flash({required this.content, required this.user, required this.postDate, this.postAddress, this.imageUrl});
}