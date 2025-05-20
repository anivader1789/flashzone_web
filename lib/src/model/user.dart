import 'dart:convert';

import 'package:flashzone_web/src/model/location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FZUser {
  String? id;
  String? name;
  String? avatar, email, bio, username;
  List<String> likes;
  FZLocation? fzLocation;
  FZUser({this.id, this.name, this.username, this.avatar, this.fzLocation, this.email, this.bio, List<String>? likesList}) : likes = likesList ?? [] ;

  static String collection = "user", nameKey = "name", usernameKey = "username", likesKey = "likes",
    avatarKey = "avatar", idKey = "id", bioKey = "bio", emailKey = "email";

  static const String interimUserId = "interim", signedOutUserId = "signedOut", awaitCodeId = "code";
  static FZUser signedOut() {
    return FZUser(
      id: signedOutUserId, 
      name: "Guest User", 
      username: "guest");
  } 

  static FZUser interim() {
    return FZUser(
      id: interimUserId, 
      name: "Loading", 
      username: "loading");
  } 

  

  Map<String,String> profileUpdateObject() {
    final Map<String,String> obj = {};
    if(name != null) obj.addEntries({nameKey : name!}.entries);
    if(email != null) obj.addEntries({emailKey : email!}.entries);
    if(username != null) obj.addEntries({usernameKey : username!}.entries);
    if(bio != null)  obj.addEntries({bioKey : bio!}.entries);
    if(avatar != null) obj.addEntries({avatarKey : avatar!}.entries);
    obj.addEntries({likesKey : jsonEncode(likes)}.entries);

    return obj;
  }

  Map<String,String> addNewUserObject() {
    final Map<String,String> obj = {};
    //if(token != null) obj.addEntries({_tokenKey : token!}.entries);
    if(name != null) obj.addEntries({nameKey : name!}.entries);
    if(email != null) obj.addEntries({emailKey : email!}.entries);
    if(username != null) obj.addEntries({usernameKey : username!}.entries);
    if(bio != null)  obj.addEntries({bioKey : bio!}.entries);
    if(avatar != null) obj.addEntries({avatarKey : avatar!}.entries);
    obj.addEntries({likesKey : jsonEncode(likes)}.entries);

    return obj;
  }

  Future<FZUser?> updateWith(Map<String,dynamic>? data, Ref ref) {
    if(data == null) {
      print("While updating user data: data is not a proper map object");
      return Future.value(this);
    }

    if(data[nameKey] != null) name = data[nameKey];
    if(data[usernameKey] != null) username = data[usernameKey];
    if(data[emailKey] != null) email = data[emailKey];
    if(data[avatarKey] != null) avatar = data[avatarKey];
    if(data[bioKey] != null) bio = data[bioKey];
    likes = getLikes(data[likesKey]);
    

    //For logic on update, see firebase_auth_service.dart
    // if(data[_tokenKey] == null) {
    //   if(token != null) {
    //     //This would be when user's token was never set but now it can be set
    //     //So return source user so it can be set in the backend
    //     ref.read(userProvider.notifier).update((state) => this);
    //     return Future.value(this);
    //   } 
    // } else {
    //   if(token == null) {
    //     //If token was not retrieved now but its already in the db
    //     token = data[_tokenKey];
    //     ref.read(userProvider.notifier).update((state) => this);
    //     //No need to update the user
    //     return Future.value(null);
    //   }
    //   if(token != data[_tokenKey]) {
    //     //This means token now is different from token earlier, so update with new one -- by returning source user
    //     ref.read(userProvider.notifier).update((state) => this);
    //     return Future.value(this);
    //   } else {
    //     //Token retrived now and from backend and both are equal - NORMAL CASE
    //     ref.read(userProvider.notifier).update((state) => this);
    //     //No need to update the user
    //     return Future.value(null);
    //   }
    // } 

    //Fallback
    //No need to update the user
    return Future.value(null);
  }

  static FZUser newSourceUserWithData(String id, Map<String,dynamic> data) {
    FZUser user = FZUser();
    user.id = id;
    if(data[nameKey] != null) user.name = data[nameKey];
    if(data[emailKey] != null) user.email = data[emailKey];
    if(data[bioKey] != null) user.bio = data[bioKey];
    if(data[usernameKey] != null) user.username = data[usernameKey];
    if(data[avatarKey] != null) user.avatar = data[avatarKey];
    user.likes = getLikes(data[likesKey]);

    return user;
  }

  static List<String> getLikes(String? data) {
    if(data == null || data.isEmpty) return List<String>.empty(growable: true);

    final array = jsonDecode(data);
    final result = List<String>.empty(growable: true);
    for(dynamic like in array) {
      if(like.runtimeType == String) {
        result.add(like);
      }
    }
    return result;
  }

  Map<String, String> compactObject() {
    final Map<String, String> obj = {};
    if (id != null) obj.addEntries({idKey: id!}.entries);
    if (name != null) obj.addEntries({nameKey: name!}.entries);
    if (username != null) obj.addEntries({usernameKey: username!}.entries);
    if (avatar != null) obj.addEntries({avatarKey: avatar!}.entries);
    return obj;
  }

  static FZUser fromCompactObject(Map<String, dynamic> data) {
    return FZUser(
      id: data[idKey],
      name: data[nameKey],
      username: data[usernameKey],
      avatar: data[avatarKey],
    );
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