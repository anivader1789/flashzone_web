import 'package:flutter/material.dart';

class NavButton extends StatelessWidget {
  const NavButton({super.key, required this.title, required this.onPressed, required this.withIcon, required this.iconType});
  final String title;
  final Function() onPressed;
  final bool withIcon;
  final int iconType; // 0: about, 1: book session, 2: store, 3: contact



  @override
  Widget build(BuildContext context) {
    if(withIcon) {
      IconData iconData;
      switch(iconType) {
        case 0:
          iconData = Icons.info_outline;
          break;
        case 1:
          iconData = Icons.calendar_month_outlined;
          break;
        case 2:
          iconData = Icons.shopping_cart_outlined;
          break;
        case 3:
          iconData = Icons.contact_mail_outlined;
          break;
        default:
          iconData = Icons.help_outline;
      }
      return TextButton.icon(
        onPressed: onPressed, 
        icon: Icon(iconData, color: Colors.black,), 
        label: Text(title, style: const TextStyle(color: Colors.black),),
      );
    } else {
    return TextButton(
      onPressed: onPressed, 
      child: Text(title, style: const TextStyle(color: Colors.white),),
    );
  }
  }
}