import 'package:flashzone_web/src/model/user.dart';

class MessageRef {
  String groupId;
  FZUser? sender;
  FZUser? receiver;
  String? famId;
  List<String>? userIds;
  MessageRef({
    required this.groupId,
    this.sender,
    this.receiver,
    this.famId,
    this.userIds,
  });

  static const String groupIdKey = "groupId", senderKey = "sender", receiverKey = "receiver", userIdsKey = "userIds", 
    famIdKey = "famId";

  static MessageRef? fromDataSnapshot(String id, Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }

    return MessageRef(
      groupId: id,
      sender: json[senderKey] != null ? FZUser.fromCompactObject(json[senderKey]) : null,
      receiver: json[receiverKey] != null ? FZUser.fromCompactObject(json[receiverKey]) : null,
      famId: json[famIdKey],
    );
  }
}