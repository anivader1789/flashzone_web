import 'package:flashzone_web/src/model/fam.dart';
import 'package:flashzone_web/src/screens/fam_themes/dark_simple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemedPage extends ConsumerStatefulWidget {
  const ThemedPage(this.fam, {super.key});
  final Fam fam;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ThemedPageState();
}

class _ThemedPageState extends ConsumerState<ThemedPage> {

  @override
  Widget build(BuildContext context) {
    if(widget.fam.pageContent != null) {
      switch (widget.fam.pageContent!.themeVersion) {
        case 1:
          // Return Theme Page for version 1
          return DarkSimpleThemePage(widget.fam); // Placeholder for actual theme page
        case 2:
          // Return Theme Page for version 2
          return Container(); // Placeholder for actual theme page
        default:
          // Fallback for unknown versions
          return Container(); // Placeholder for default theme page
      }
    }
    return Container();
  }
}