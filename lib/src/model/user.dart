import 'package:flashzone_web/src/model/location.dart';

class FZUser {
  String id;
  String name, username;
  String? avatar;
  FZLocation? fzLocation;
  FZUser({required this.id, required this.name, required this.username, this.avatar, this.fzLocation});

  static FZUser dummy() {
    return FZUser(
      id: "123test", 
      name: "Dummy User", 
      username: "dummy");
  } 

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is FZUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}