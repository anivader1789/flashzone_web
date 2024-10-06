import 'package:flashzone_web/src/model/location.dart';

class FZUser {
  String name, username;
  String? avatar;
  FZLocation? fzLocation;
  FZUser({required this.name, required this.username, this.avatar, this.fzLocation});
}