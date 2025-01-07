import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/user.dart';

class CommentsList {
  String? id;
  String flashId;
  List<Comment> comments;
  CommentsList({this.id, required this.flashId, required this. comments});

  static String collection = "commentsList", idKey = "id", flashKey = "flashId", commentsKey = "comments";

  static CommentsList? fromDocSnapshot(String id, Map<String, dynamic>? data) {
    if(data == null) return null;

    return CommentsList(
      id: id,
      flashId: data[flashKey],
      comments: getComments(data[commentsKey]),
      );
  }

  Map<String, dynamic> creationObj() {
    return {
      flashKey: flashId,
      commentsKey: comments.map((e) => e.creationObj()).toList(),
    };
  }
  
  Map<String,dynamic> updateObject() {
    return {
      commentsKey: comments.map((e) => e.creationObj()).toList(),
    };
  }

  static List<Comment> getComments(List<dynamic> list) {

    List<Comment> res = List<Comment>.empty(growable: true);
    for(dynamic data in list) {
      
      final comment = Comment.newFromData(data as Map<String, dynamic>);
      if(comment != null) {
        res.add(comment);
      }
    }
    return res;
  }

  static CommentsList newFrom(String flashId) => CommentsList(flashId: flashId, comments: List<Comment>.empty(growable: true));

}
class Comment {
  String? userName, userId, userHandle, userAvatar;
  String content;
  DateTime time;
  Comment({required this.userName, required this.userId, required this.userHandle, required this.userAvatar,
  required this.content, required this.time});

  static Comment? newFromData(Map<String, dynamic>? data) {
    if(data == null) return null;

    return Comment(
      userName: data[Flash.nameKey], 
      userId: data[Flash.userIdKey], 
      userHandle: data[Flash.userhandleKey], 
      userAvatar: data[Flash.userPicKey], 
      content: data[Flash.contentKey], 
      time: DateTime.parse(data[Flash.dateKey]));
  }

  Map<String, dynamic> creationObj() {
    return {
      Flash.contentKey: content,
      Flash.nameKey: userName,
      Flash.userIdKey: userId,
      Flash.userhandleKey: userHandle,
      Flash.userPicKey: userAvatar,
      Flash.dateKey: time.toString(),
    };
  }

  static Comment newFromContent(String text, FZUser user) => Comment(
    userName: user.name, 
    userId: user.id, 
    userHandle: user.username, 
    userAvatar: user.avatar, 
    content: text, 
    time: DateTime.now());

}