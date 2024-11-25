class FZNotification {
  String text;
  NotificationType type;
  FZNotification({required this.text, required this.type});
}

enum NotificationType {
  event,admin
}