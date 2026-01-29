class FZChatMessage  implements Comparable<FZChatMessage> {
  String? id;
  String message;
  String senderId;
  String? senderPic;
  String senderName; // Added field
  DateTime time;

  FZChatMessage({
    this.id,
    required this.message,
    required this.senderId,
    this.senderPic,
    required this.senderName, // Added field
    required this.time,
  });

  static const String collectionName = 'chat_message', 
    messageKey = 'message', senderKey = 'sender',
    senderNameKey = 'senderName', 
    senderPicKey = 'senderPic',
    timeKey = 'time'; // Added constant

  static FZChatMessage? fromDocSnapshot(String id, Map<String, dynamic>? data) {
    if (data == null) return null;

    return FZChatMessage(
      id: id,
      message: data[messageKey] as String,
      senderId: data[senderKey],
      senderPic: data[senderPicKey] as String?,
      senderName: data[senderNameKey] as String,
      time: DateTime.parse(data[timeKey] as String),
    );
  }

  Map<String, dynamic> creationObj() {
    return {
      messageKey: message,
      senderKey: senderId,
      senderPicKey: senderPic,
      senderNameKey: senderName,
      timeKey: time.toIso8601String(),
    };
  }

  @override
  int compareTo(FZChatMessage other) {
    // Latest message first
    return time.compareTo(other.time);
  }

}