import 'dart:convert';

class ChatMessage {
  String sender, receiver;
  String message;
  DateTime time;
  ChatMessage({required this.sender, required this.receiver, required this.message, required this.time});

  static List<String> keys = ["sender", "receiver", "message", "time"];

  String json() {
    return jsonEncode({
      keys[0]: sender,
      keys[1]: receiver,
      keys[2]: message,
      keys[3]: time.toString()
    });
  }

  static ChatMessage chatFromJson(String jsonStr){
    Map json = jsonDecode(jsonStr);
    return ChatMessage(sender: json[keys[0]], receiver: json[keys[1]], message: json[keys[2]], time: json[keys[3]]);
  }
}

class ChatThread {
  String name, lastMsg;
  String? pic;
  ChatThread({required this.name, this.pic, required this.lastMsg});
}