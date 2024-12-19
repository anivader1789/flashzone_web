import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flutter/gestures.dart';
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

  static showDialogWithMessage({required BuildContext ctx, required String msg, String title = "FlashZone"}) {
    showDialog(context: ctx, 
          builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: <Widget>[
            FZButton(
              text: "OK", 
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              bgColor: Constants.lightColor()
            ),
          ],
        ));
  }
}

const fzSymbol = "\u2021";

enum FZTextStyle {
  headline, subheading, paragraph, largeHeadline, smallsubheading
}



class FZText extends StatelessWidget {
  const FZText({super.key, required this.text, required this.style, this.color = Colors.black, this.onTap});
  final String? text;
  final FZTextStyle style;
  final Color color;
  final Function ()? onTap;

  @override
  Widget build(BuildContext context) {
    //TODO: Figure out how to enhance text for flashtag posts
    String enhancedText = text ?? "null";

    TextStyle textStyle = switch (style) {
      FZTextStyle.headline =>  TextStyle(color: color, fontWeight: FontWeight.bold),
      FZTextStyle.largeHeadline =>  TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
      FZTextStyle.subheading =>  TextStyle(color: color, fontWeight: FontWeight.w300),
      FZTextStyle.smallsubheading =>  TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w200),
      FZTextStyle.paragraph =>  TextStyle(color: color, fontWeight: FontWeight.normal),
    };

    if(onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Text(enhancedText, style: textStyle,softWrap: true,),
        )
      );
    }

    return Text(enhancedText, style: textStyle,softWrap: true,);
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
  this.textColor = Colors.black,
  this.bgColor = Colors.transparent, 
  this.compact = false});
  final String text;
  final Color bgColor;
  final Color textColor;
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
              child: FZText(text: text, style: FZTextStyle.paragraph, color: textColor,),
            ),
          );
  }
}

class FZIconButton extends StatelessWidget {
  const FZIconButton({super.key, required this.tint, required this.icon, required this.onPressed});
  final Color tint;
  final IconData icon;
  final Function ()? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, 
    child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Icon(icon, size: 21,),
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