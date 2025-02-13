class FZNotification {
  String text;
  NotificationType type;
  FZNotification({required this.text, required this.type});

  static const collection = "notifications", typeKey = "type", textKey = "text";

  static FZNotification? fromDocSnapshot(Map<String, dynamic>? data) {
    if(data == null) return null;

    return FZNotification(
      text: data[textKey],
      type: getType(data[typeKey]),
      );
  }

  static NotificationType getType(String? val) {
    if(val == null) return NotificationType.admin;
    
    return switch (val) {
      "admin" => NotificationType.admin,
      "event" => NotificationType.event,
      _ => NotificationType.admin
    };
  }
}

enum NotificationType {
  event,admin
}