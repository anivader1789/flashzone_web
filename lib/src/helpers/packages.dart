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
  headline, subheading, paragraph, largeHeadline
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
      FZTextStyle.largeHeadline => const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
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

class FZButton extends StatelessWidget {
  const FZButton({super.key, 
  required this.onPressed,
  required this.text, 
  this.bgColor = Colors.transparent, 
  this.compact = false});
  final String text;
  final Color bgColor;
  final bool compact;
  final Function ()? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, 
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(bgColor),
              side: MaterialStatePropertyAll(
                BorderSide(
                  color: bgColor,
                  width: 1,
                  style: BorderStyle.solid
                  )
              ),
              shape: const MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12)
                    ),
                )
              )
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: compact? 4: 12, horizontal: 12),
              child: FZText(text: text, style: FZTextStyle.paragraph),
            ),
          );
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