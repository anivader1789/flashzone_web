import 'package:flutter/cupertino.dart';

class ButtonData {
  final String label;
  final IconData? icon;
  final Function()? onPressed;
  ButtonData({
    required this.label,
    this.icon,
    this.onPressed,
  });
}