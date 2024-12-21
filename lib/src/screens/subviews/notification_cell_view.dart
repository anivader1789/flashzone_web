import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/notification.dart';
import 'package:flutter/material.dart';

class NotificationCellView extends StatelessWidget {
  const NotificationCellView({super.key, required this.notif, required this.bgColor, required this.mobileSize});
  final FZNotification notif;
  final Color bgColor;
  final bool mobileSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: bgColor,
      child: Row(
        children: [
          horizontal(mobileSize? 1: 3),
          Icon(icon(notif.type), color: Constants.primaryColor(), size: mobileSize? 24: 34,),
          horizontal(mobileSize? 1: 3),
          Expanded(child: FZText(text: notif.text, style: mobileSize? FZTextStyle.paragraph: FZTextStyle.headline))
        ],
      ),

    );
  }

  vertical([double multiple = 1]) {
    return SizedBox(height: 5 * multiple,);
  }

  horizontal([double multiple = 1]) {
    return SizedBox(width: 5 * multiple,);
  }

  IconData icon(NotificationType type) {
    return switch (type) {
      NotificationType.event => Icons.event,
      NotificationType.admin => Icons.alarm,
    };
  }
}