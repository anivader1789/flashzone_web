
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/screens/master_view.dart';
import 'package:flutter/material.dart';

class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({super.key, required this.fullUrl});
  final String fullUrl;

  @override
  Widget build(BuildContext context) {
    return  MasterView(
      sideMenuIndex: 0,
      child: Column(
        children: [
          const SizedBox(height: 100,),
          FZErrorIndicator(text: "URL path not found: $fullUrl", mobileSize: false,),
          ]));
  }
}