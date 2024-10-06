import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  static ImageProvider loadImageProvider(String? url) {
    if(url == null) {
      return const AssetImage('assets/profile_pic_placeholder.png');
    } else {
      return NetworkImage(url);
    }
  }

  static String getDisplayDate(DateTime dateTime) {
    String day = DateFormat('d MMM y').format(dateTime);
    String time = DateFormat('h:mm a').format(dateTime);
    return "$time on $day";
  }
}

const fzSymbol = "\u2021";

enum FZTextStyle {
  headline, subheading, paragraph
}



class FZText extends StatelessWidget {
  const FZText({super.key, required this.text, required this.style});
  final String text;
  final FZTextStyle style;

  @override
  Widget build(BuildContext context) {
    //TODO: Figure out how to enhance text for flashtag posts
    String enhancedText = text;

    TextStyle textStyle = switch (style) {
      FZTextStyle.headline => const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      FZTextStyle.subheading => const TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),
      FZTextStyle.paragraph => const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
    };

    return Text(enhancedText, style: textStyle,);
  }
  

  List<String?> extractFlashTags(String str) {
    final reg = RegExp(r'\u2021[a-zA-z]+\b');
    return reg.allMatches(str).map((z) => z.group(0)).toList();
  }
}

enum FZSymbolType {
  location, time
}

class FZSymbol extends StatelessWidget {
  const FZSymbol({super.key, required this.type});
  final FZSymbolType type;

  @override
  Widget build(BuildContext context) {
    IconData icon = switch (type) {
      FZSymbolType.location => Icons.pin_drop,
      FZSymbolType.time => Icons.watch_later,
    };
    
    return Icon(icon,);
  }
}