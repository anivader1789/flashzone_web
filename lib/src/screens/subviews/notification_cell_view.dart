import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/notification.dart';
import 'package:flutter/material.dart';

class NotificationCellView extends StatelessWidget {
  const NotificationCellView({super.key, required this.notif, required this.bgColor});
  final FZNotification notif;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: bgColor,
      child: Row(
        children: [
          horizontal(),
          Icon(icon(notif.type), color: Constants.primaryColor(), size: 34,),
          horizontal(),
          FZText(text: notif.text, style: FZTextStyle.headline)
        ],
      ),

    );
  }

  vertical([double multiple = 1]) {
    return SizedBox(height: 15 * multiple,);
  }

  horizontal([double multiple = 1]) {
    return SizedBox(width: 15 * multiple,);
  }

  IconData icon(NotificationType type) {
    return switch (type) {
      NotificationType.event => Icons.event,
      NotificationType.admin => Icons.alarm,
    };
  }
}